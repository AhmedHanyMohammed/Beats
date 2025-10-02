import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'analysis.dart';
import '../../../../routes/routes.dart'; // added
import '../../../../routes/ai_service.dart'; // new import
import '../../../../routes/message_handler.dart';
import '../../../../routes/local_storage.dart';

enum Gender { male, female }

class NewAnalysisHandler extends ChangeNotifier {
  // Singleton pattern to allow Stateless page to hold persistent state.
  NewAnalysisHandler._internal();
  static final NewAnalysisHandler instance = NewAnalysisHandler._internal();
  factory NewAnalysisHandler() => instance;

  final ImagePicker _picker = ImagePicker();

  Gender gender = Gender.male;
  int age = 60; // slider initial
  final Map<String, bool> conditions = {
    'Congestive heart failure': false,
    'Hypertension': false,
    'Diabetes mellitus': false,
    'Stroke/TIA/thromboembolism': false,
    'Vascular disease': false,
  };

  XFile? ecgFile;
  String? ecgLabel;
  bool busy = false;

  int? aiResponseId;
  int? sessionRecordId;
  Map<String, dynamic>? sessionRecordResponse;
  String? errorMessage;

  // AI result fields (free-form)
  String? aiText;
  String? aiModel;
  String? aiRequestId;

  // AI structured fields
  String? apixabanRecommendation; // 'yes' | 'no'
  String? justification;
  List<String>? comprehensiveAnalysis;
  String? interpretationSummary;

  void setGender(Gender g) {
    if (gender == g) return;
    gender = g;
    notifyListeners();
  }

  void setAge(int v) {
    if (v == age) return;
    age = v;
    notifyListeners();
  }

  void toggleCondition(String key, bool value) {
    if (!conditions.containsKey(key)) return;
    conditions[key] = value;
    notifyListeners();
  }

  Future<void> captureECG() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        ecgFile = picked;
        ecgLabel = 'Captured: ${_fileName(picked)}';
      } else {
        ecgLabel = 'Capture cancelled';
      }
    } catch (e, st) {
      ecgLabel = 'Capture failed';
      MessageHandler.devLog(e, st);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> selectECG() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      // Allow any file type from documents/files, not only images
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.any,
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.single;
        if ((f.path ?? '').isNotEmpty) {
          ecgFile = XFile(f.path!);
          ecgLabel = 'Selected: ${f.name}';
        } else {
          ecgLabel = 'Selection failed (no path)';
        }
      } else {
        ecgLabel = 'Selection cancelled';
      }
    } catch (e, st) {
      ecgLabel = 'Selection failed';
      MessageHandler.devLog(e, st);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  String? validateReady() {
    if (ecgFile == null) return 'Please capture or select an ECG first.';
    if (age < 0 || age > 150) return 'Invalid age.';
    return null;
  }

  int get cha2ds2VascScore => _computeCha2ds2VascScore();

  int _computeCha2ds2VascScore() {
    int score = 0;
    // Age
    if (age >= 75) {
      score += 2;
    } else if (age >= 65) {
      score += 1;
    }
    // Sex (female)
    if (gender == Gender.female) score += 1;
    // Conditions
    if (conditions['Congestive heart failure'] == true) score += 1;
    if (conditions['Hypertension'] == true) score += 1;
    if (conditions['Diabetes mellitus'] == true) score += 1;
    if (conditions['Stroke/TIA/thromboembolism'] == true) score += 2;
    if (conditions['Vascular disease'] == true) score += 1;
    return score;
  }

  Map<String, dynamic> buildPayload() {
    final map = <String, dynamic>{
      'patientAge': age,
      'patientSex': gender == Gender.male ? 'Male' : 'Female',
      'chf': conditions['Congestive heart failure'] ?? false,
      'htn': conditions['Hypertension'] ?? false,
      'dm': conditions['Diabetes mellitus'] ?? false,
      'stroke': conditions['Stroke/TIA/thromboembolism'] ?? false,
      'vascular': conditions['Vascular disease'] ?? false,
      'cha2ds2VascScore': _computeCha2ds2VascScore(),
      if (sessionRecordId != null) 'sessionRecordId': sessionRecordId,
      if (sessionRecordResponse != null) 'sessionRecord': sessionRecordResponse,
      // ECG file meta (not part of Swagger DTO, but useful for next step)
      if (ecgFile != null) 'ecgFilePath': ecgFile!.path,
      if (ecgFile != null) 'ecgFileName': _fileName(ecgFile!),
      // AI (free-form)
      if (aiText != null) 'aiText': aiText,
      if (aiModel != null) 'aiModel': aiModel,
      if (aiRequestId != null) 'aiRequestId': aiRequestId,
      // AI (structured)
      if (apixabanRecommendation != null) 'apixabanRecommendation': apixabanRecommendation,
      if (justification != null) 'justification': justification,
      if (comprehensiveAnalysis != null) 'comprehensiveAnalysis': comprehensiveAnalysis,
      if (interpretationSummary != null) 'interpretationSummary': interpretationSummary,
    };
    return map;
  }

  String _fileName(XFile f) {
    return f.name.isNotEmpty ? f.name : f.path.split(Platform.pathSeparator).last;
  }

  Future<void> analyze(BuildContext context) async {
    final err = validateReady();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (busy) return;
    busy = true;
    errorMessage = null;
    aiText = null;
    aiModel = null;
    aiRequestId = null;
    apixabanRecommendation = null;
    justification = null;
    comprehensiveAnalysis = null;
    interpretationSummary = null;
    notifyListeners();
    try {
      // 1) Call AI service with the current patient data (structured fields)
      final aiPayload = {
        'patientAge': age,
        'patientSex': gender == Gender.male ? 'Male' : 'Female',
        'chf': conditions['Congestive heart failure'] ?? false,
        'htn': conditions['Hypertension'] ?? false,
        'dm': conditions['Diabetes mellitus'] ?? false,
        'stroke': conditions['Stroke/TIA/thromboembolism'] ?? false,
        'vascular': conditions['Vascular disease'] ?? false,
        'cha2ds2VascScore': _computeCha2ds2VascScore(),
      };
      try {
        final ai = await AiService.analyzePatientStructured(
          aiPayload,
          ecgFileName: ecgFile != null ? _fileName(ecgFile!) : null,
        );
        apixabanRecommendation = ai.apixabanRecommendation;
        justification = ai.justification;
        comprehensiveAnalysis = ai.comprehensiveAnalysis;
        interpretationSummary = ai.interpretationSummary;
        aiModel = ai.model;
        aiRequestId = ai.requestId;
        // For backward display if needed
        aiText = ai.rawText;
      } catch (e, st) {
        // Keep flow but surface the error gently
        errorMessage = MessageHandler.friendly(e);
        MessageHandler.devLog(e, st);
        if (context.mounted) {
          MessageHandler.showErrorSnackbar(context, 'AI analysis failed: ${errorMessage ?? ''}'.trim());
        }
      }

      // 2) Create a SessionRecord in your backend (do not block UI if unreachable)
      try {
        final res = await ApiRoutes
            .createSessionRecord(
              aiResponseId: aiResponseId ?? 0,
              patientAge: age,
              patientSex: gender == Gender.male ? 'Male' : 'Female',
              chf: conditions['Congestive heart failure'],
              htn: conditions['Hypertension'],
              dm: conditions['Diabetes mellitus'],
              stroke: conditions['Stroke/TIA/thromboembolism'],
              vascular: conditions['Vascular disease'],
              cha2ds2VascScore: _computeCha2ds2VascScore(),
            )
            .timeout(const Duration(seconds: 10));
        sessionRecordResponse = res;
        sessionRecordId = res?['id'] as int?;
      } catch (e, st) {
        // Non-fatal: proceed to analysis page even if backend is down
        MessageHandler.devLog(e, st);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved locally. Backend is unreachable at the moment.')),
          );
        }
      }

      // 3) Build payload & navigate to Analysis page, passing AI info
      final payload = buildPayload();
      // Save locally (non-blocking)
      try {
        await LocalStorage.instance.saveFromPayload(
          payload: payload,
          apixabanRecommendation: apixabanRecommendation,
          justification: justification,
          comprehensiveAnalysis: comprehensiveAnalysis,
          interpretationSummary: interpretationSummary,
          aiModel: aiModel,
          aiRequestId: aiRequestId,
        );
      } catch (e, st) {
        MessageHandler.devLog('Local save failed: $e', st);
      }
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisPage(
              payload: payload,
              aiText: aiText,
              aiModel: aiModel,
              aiRequestId: aiRequestId,
              apixabanRecommendation: apixabanRecommendation,
              justification: justification,
              comprehensiveAnalysis: comprehensiveAnalysis,
              interpretationSummary: interpretationSummary,
            ),
          ),
        );
      }
    } catch (e, st) {
      errorMessage = MessageHandler.friendly(e);
      MessageHandler.devLog(e, st);
      if (context.mounted) {
        MessageHandler.showErrorSnackbar(context, 'Analysis failed: ${errorMessage ?? ''}'.trim());
      }
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
