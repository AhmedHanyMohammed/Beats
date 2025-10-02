import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Lightweight client to call a Chat Completions compatible endpoint.
///
/// Configuration is taken from --dart-define values at build/run time:
/// - AI_API_BASE_URL (e.g. https://models.inference.ai.azure.com or https://api.openai.com)
/// - AI_API_PATH (e.g. /v1/chat/completions)
/// - AI_API_KEY  (the bearer token)
/// - AI_MODEL    (e.g. copilot-gpt-5, gpt-4o, gpt-4o-mini)
/// - AI_TIMEOUT_SECONDS (default 30)
class AiService {
  AiService._();

  static final String _baseUrl = const String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: 'https://models.inference.ai.azure.com',
  );
  static final String _path = const String.fromEnvironment(
    'AI_API_PATH',
    defaultValue: '/v1/chat/completions',
  );
  static final String _apiKey = const String.fromEnvironment('AI_API_KEY', defaultValue: '');
  static final String _model = const String.fromEnvironment('AI_MODEL', defaultValue: 'copilot-gpt-5');
  static final int _timeoutSeconds = int.tryParse(const String.fromEnvironment('AI_TIMEOUT_SECONDS', defaultValue: '30')) ?? 30;

  static Uri _uri() {
    final trimmedBase = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final full = '$trimmedBase$_path';
    return Uri.parse(full);
  }

  // Choose correct auth header based on provider.
  static Map<String, String> _authHeaders() {
    // Azure AI Inference uses 'api-key' header, OpenAI uses Authorization: Bearer
    final isAzureInference = _baseUrl.contains('azure.com') || _baseUrl.contains('models.inference.ai');
    if (isAzureInference) {
      return {
        'api-key': _apiKey,
      };
    }
    return {
      'Authorization': 'Bearer $_apiKey',
    };
  }

  /// Calls the chat completion API with a structured prompt built from [patientData].
  /// Returns [AiResult] with the best-effort parsed text.
  static Future<AiResult> analyzePatient(Map<String, dynamic> patientData) async {
    if (_apiKey.isEmpty) {
      throw Exception('AI_API_KEY is not set. Provide it via --dart-define=AI_API_KEY=...');
    }

    final prompt = _buildPrompt(patientData);

    final payload = {
      'model': _model,
      'temperature': 0.2,
      'messages': [
        {
          'role': 'system',
          'content': 'You are a cardiology assistant. Provide a concise, educational summary of ECG-related risk considerations based on the provided demographic and comorbidity data. Avoid diagnosis; include a short, clear next-steps list. Keep it under 160 words.'
        },
        {
          'role': 'user',
          'content': prompt,
        }
      ],
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ..._authHeaders(),
    };

    final client = http.Client();
    try {
      final res = await client
          .post(_uri(), headers: headers, body: json.encode(payload))
          .timeout(Duration(seconds: _timeoutSeconds));

      if (res.statusCode < 200 || res.statusCode > 299) {
        final detail = _bestErrorDetail(res.body);
        throw HttpException('AI error ${res.statusCode}${detail.isNotEmpty ? ': ' + detail : ''}');
      }

      final decoded = json.decode(res.body);
      final text = _extractText(decoded);
      final id = _extractId(decoded);
      return AiResult(
        text: text?.trim().isNotEmpty == true ? text!.trim() : 'No content returned from AI.',
        model: _model,
        requestId: id,
        raw: decoded,
      );
    } on SocketException catch (e) {
      throw Exception('Network error calling AI: ${e.message}');
    } on HttpException {
      rethrow;
    } on FormatException catch (e) {
      throw Exception('AI response parsing error: ${e.message}');
    } on TimeoutException catch (_) {
      throw Exception('AI request timed out after $_timeoutSeconds seconds');
    } finally {
      client.close();
    }
  }

  /// Structured analysis returning specific fields expected by the UI.
  /// If the provider supports strict JSON via response_format, it is requested.
  static Future<AiStructuredResult> analyzePatientStructured(
    Map<String, dynamic> patientData, {
    String? ecgFileName,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('AI_API_KEY is not set. Provide it via --dart-define=AI_API_KEY=...');
    }

    final sys = 'You are a careful, non-diagnostic cardiology assistant. '
        'Return STRICT JSON only. No prose outside JSON. '
        'Fields: apixaban_recommendation ("yes"|"no"), justification (string, 1-3 sentences), '
        'comprehensive_analysis (array of concise bullet strings), interpretation_summary (string). '
        'Base on demographics and comorbidities; do not fabricate ECG waveform findings. '
        'If an ECG image/file is not actually analyzed, avoid claiming image-derived features.';

    final user = _buildPrompt(patientData) +
        (ecgFileName != null ? '\n\nAn ECG file is provided by the user: "$ecgFileName" (not parsed in this sandbox). Focus on what can be inferred responsibly without direct waveform analysis.' : '');

    final payload = {
      'model': _model,
      'temperature': 0.2,
      // Some providers accept this OpenAI-style flag for strict JSON.
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': sys},
        {'role': 'user', 'content': user},
      ],
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ..._authHeaders(),
    };

    final client = http.Client();
    try {
      final res = await client
          .post(_uri(), headers: headers, body: json.encode(payload))
          .timeout(Duration(seconds: _timeoutSeconds));

      if (res.statusCode < 200 || res.statusCode > 299) {
        final detail = _bestErrorDetail(res.body);
        throw HttpException('AI error ${res.statusCode}${detail.isNotEmpty ? ': ' + detail : ''}');
      }

      final decoded = json.decode(res.body);
      final id = _extractId(decoded);
      final rawText = _extractText(decoded) ?? '';

      // Try to parse JSON strictly
      Map<String, dynamic>? jsonObj;
      if (rawText.trim().startsWith('{')) {
        jsonObj = _tryDecodeJson(rawText);
      } else {
        // Attempt to locate a JSON object within the text
        final first = rawText.indexOf('{');
        final last = rawText.lastIndexOf('}');
        if (first >= 0 && last > first) {
          jsonObj = _tryDecodeJson(rawText.substring(first, last + 1));
        }
      }

      final parsed = _parseStructured(jsonObj);

      return AiStructuredResult(
        apixabanRecommendation: parsed.apixabanRecommendation,
        justification: parsed.justification,
        comprehensiveAnalysis: parsed.comprehensiveAnalysis,
        interpretationSummary: parsed.interpretationSummary,
        model: _model,
        requestId: id,
        rawText: rawText,
        rawResponse: decoded,
      );
    } on SocketException catch (e) {
      throw Exception('Network error calling AI: ${e.message}');
    } on HttpException {
      rethrow;
    } on FormatException catch (e) {
      throw Exception('AI response parsing error: ${e.message}');
    } on TimeoutException catch (_) {
      throw Exception('AI request timed out after $_timeoutSeconds seconds');
    } finally {
      client.close();
    }
  }

  static _StructuredFields _parseStructured(Map<String, dynamic>? obj) {
    String? rec;
    String? just;
    List<String>? comp;
    String? summary;

    if (obj != null) {
      final r = obj['apixaban_recommendation'];
      if (r is String) {
        final v = r.trim().toLowerCase();
        if (v == 'yes' || v == 'no') rec = v;
      }
      final j = obj['justification'];
      if (j is String && j.trim().isNotEmpty) just = j.trim();
      final c = obj['comprehensive_analysis'];
      if (c is List) {
        comp = c.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      final s = obj['interpretation_summary'];
      if (s is String && s.trim().isNotEmpty) summary = s.trim();
    }

    return _StructuredFields(rec, just, comp, summary);
  }

  static Map<String, dynamic>? _tryDecodeJson(String s) {
    try {
      final v = json.decode(s);
      return v is Map<String, dynamic> ? v : null;
    } catch (_) {
      return null;
    }
  }

  static String _buildPrompt(Map<String, dynamic> d) {
    final age = d['patientAge'];
    final sex = d['patientSex'];
    final chf = d['chf'] == true ? 'Yes' : 'No';
    final htn = d['htn'] == true ? 'Yes' : 'No';
    final dm = d['dm'] == true ? 'Yes' : 'No';
    final stroke = d['stroke'] == true ? 'Yes' : 'No';
    final vascular = d['vascular'] == true ? 'Yes' : 'No';
    final score = d['cha2ds2VascScore'];

    return [
      'Patient summary:',
      '- Age: $age',
      '- Sex: $sex',
      '- Conditions:',
      '  • CHF: $chf',
      '  • Hypertension: $htn',
      '  • Diabetes: $dm',
      '  • Prior Stroke/TIA/Thromboembolism: $stroke',
      '  • Vascular disease: $vascular',
      '- CHA2DS2-VASc score: $score',
      '',
      'Task: Provide a brief, non-diagnostic educational note on what this data may imply for ECG interpretation and stroke risk context. Include 3-5 bullet recommendations for next steps (monitoring or follow-up). Do not mention that you are an AI. Use clear, patient-friendly language.'
    ].join('\n');
  }

  static String _bestErrorDetail(String body) {
    final t = body.trim();
    if (t.isEmpty) return '';
    try {
      final obj = json.decode(t);
      if (obj is Map) {
        final m = obj['message'] ?? obj['error'] ?? obj['detail'] ?? obj['title'];
        if (m is String) return m;
        if (obj['errors'] != null) return obj['errors'].toString();
      }
      return t;
    } catch (_) {
      return t;
    }
  }

  /// Extract text robustly from OpenAI-compatible or generic shapes.
  static String? _extractText(dynamic obj) {
    try {
      if (obj is Map<String, dynamic>) {
        // OpenAI chat.completions
        final choices = obj['choices'];
        if (choices is List && choices.isNotEmpty) {
          final first = choices.first;
          final message = first is Map ? first['message'] : null;
          if (message is Map && message['content'] is String) {
            return message['content'] as String;
          }
          // Some providers return content at top level of choice
          final content = first['content'];
          if (content is String) return content;
        }
        // Azure/GitHub experimental shapes
        if (obj['output_text'] is String) return obj['output_text'];
        if (obj['content'] is String) return obj['content'];
      }
    } catch (_) {}
    return null;
  }

  static String? _extractId(dynamic obj) {
    try {
      if (obj is Map<String, dynamic>) {
        if (obj['id'] is String) return obj['id'] as String;
        if (obj['request_id'] is String) return obj['request_id'] as String;
      }
    } catch (_) {}
    return null;
  }
}

class AiResult {
  final String text;
  final String? model;
  final String? requestId;
  final dynamic raw;
  AiResult({required this.text, this.model, this.requestId, this.raw});
}

class AiStructuredResult {
  final String? apixabanRecommendation; // 'yes' | 'no'
  final String? justification;
  final List<String>? comprehensiveAnalysis;
  final String? interpretationSummary;
  final String? model;
  final String? requestId;
  final String? rawText;
  final dynamic rawResponse;

  const AiStructuredResult({
    required this.apixabanRecommendation,
    required this.justification,
    required this.comprehensiveAnalysis,
    required this.interpretationSummary,
    this.model,
    this.requestId,
    this.rawText,
    this.rawResponse,
  });
}

class _StructuredFields {
  final String? apixabanRecommendation;
  final String? justification;
  final List<String>? comprehensiveAnalysis;
  final String? interpretationSummary;
  const _StructuredFields(
    this.apixabanRecommendation,
    this.justification,
    this.comprehensiveAnalysis,
    this.interpretationSummary,
  );
}
