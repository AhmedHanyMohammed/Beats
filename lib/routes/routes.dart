import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiRoutes {
  ApiRoutes._();

  // Base URL of your Swagger API.
  static const String _apiBase = 'https://api.test.eye-ecg.eye-apps.com';

  static final http.Client _client = http.Client();
  static String? _authToken;

  // Headers helper
  static Map<String, String> _jsonHeaders({bool withAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    if (withAuth && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Fallback form headers
  static Map<String, String> _formHeaders({bool withAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };
    if (withAuth && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static Uri _api(String path, [Map<String, String>? query]) {
    return Uri.parse('$_apiBase$path').replace(queryParameters: query);
  }

  // Smart POST: try JSON, fallback to x-www-form-urlencoded for 400/415/422
  static Future<http.Response> _postSmart(
    String path,
    Map<String, dynamic> data, {
    bool withAuth = false,
  }) async {
    final uri = _api(path);
    // 1) Try JSON
    final res1 = await _client.post(
      uri,
      headers: _jsonHeaders(withAuth: withAuth),
      body: json.encode(data),
    );
    if (res1.statusCode >= 200 && res1.statusCode <= 299) return res1;

    // 2) Fallback to form if common client-side issues appear
    if (res1.statusCode == 400 || res1.statusCode == 415 || res1.statusCode == 422) {
      final formBody = <String, String>{};
      data.forEach((k, v) => formBody[k] = v?.toString() ?? '');
      final res2 = await _client.post(
        uri,
        headers: _formHeaders(withAuth: withAuth),
        body: formBody,
      );
      if (res2.statusCode >= 200 && res2.statusCode <= 299) return res2;
      return res2; // Let caller throw with detailed body.
    }

    return res1;
  }

  // --------------- Account endpoints ---------------

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final emailNorm = email.trim().toLowerCase();
    final res = await _postSmart(
      '/api/Account/login',
      {
        'email': emailNorm,
        'password': password,
      },
      withAuth: false,
    );
    _throwIfError(res);

    final body = res.body.trim();
    if (body.isEmpty) return <String, dynamic>{};
    final obj = _tryParseJson(body);

    // Try to capture a token if backend returns one.
    final token = _extractToken(obj);
    if (token != null && token.isNotEmpty) {
      _authToken = token;
    }

    return obj ?? <String, dynamic>{};
  }

  /// POST /api/Account/register
  static Future<String> registerUser(
    String fullName,
    String email,
    String password,
  ) async {
    final emailNorm = email.trim().toLowerCase();
    final res = await _postSmart(
      '/api/Account/register',
      {
        // Send both common name keys if backend ignores unknowns; last write wins on duplicates,
        // so prefer the key you expect your API to use (fullName).
        'fullName': fullName,
        'email': emailNorm,
        'password': password,
      },
      withAuth: false,
    );
    _throwIfError(res);
    return 'ok';
  }

  /// POST /api/Account/forgot-password
  static Future<void> forgotPassword(String email) async {
    final emailNorm = email.trim().toLowerCase();
    final res = await _postSmart(
      '/api/Account/forgot-password',
      {'email': emailNorm},
      withAuth: false,
    );
    _throwIfError(res);
  }

  /// POST /api/Account/reset-password
  static Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    final emailNorm = email.trim().toLowerCase();
    final res = await _postSmart(
      '/api/Account/reset-password',
      {
        'email': emailNorm,
        'token': token,
        'newPassword': newPassword,
      },
      withAuth: false,
    );
    _throwIfError(res);
  }

  /// Access the current bearer token (if login provided one).
  static String? get authToken => _authToken;

  // --------------- Internal generic helpers (new) ---------------
  static Future<http.Response> _get(String path,
      {Map<String, String>? query, bool withAuth = true}) async {
    final uri = _api(path, query);
    final res = await _client.get(uri, headers: _jsonHeaders(withAuth: withAuth));
    return res;
  }

  // JSON first, fallback to form like _postSmart
  static Future<http.Response> _putSmart(
    String path,
    Map<String, dynamic> data, {
    bool withAuth = true,
  }) async {
    final uri = _api(path);
    final res1 = await _client.put(
      uri,
      headers: _jsonHeaders(withAuth: withAuth),
      body: json.encode(data),
    );
    if (res1.statusCode >= 200 && res1.statusCode <= 299) return res1;
    if (res1.statusCode == 400 || res1.statusCode == 415 || res1.statusCode == 422) {
      final formBody = <String, String>{};
      data.forEach((k, v) => formBody[k] = v?.toString() ?? '');
      final res2 = await _client.put(
        uri,
        headers: _formHeaders(withAuth: withAuth),
        body: formBody,
      );
      return res2;
    }
    return res1;
  }

  static Future<http.Response> _delete(String path,
      {bool withAuth = true}) async {
    final uri = _api(path);
    final res = await _client.delete(uri, headers: _jsonHeaders(withAuth: withAuth));
    return res;
  }

  static dynamic _decodeBody(http.Response res) {
    final body = res.body.trim();
    if (body.isEmpty) return null;
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  // --------------- AIResponses ---------------
  /// GET /api/AIResponses/{id}
  static Future<Map<String, dynamic>?> getAIResponse(int id,
      {bool withAuth = true}) async {
    final res = await _get('/api/AIResponses/$id', withAuth: withAuth);
    _throwIfError(res);
    final data = _decodeBody(res);
    return (data is Map<String, dynamic>) ? data : null;
  }

  // --------------- Doctors ---------------
  /// GET /api/Doctors
  static Future<List<dynamic>> getDoctors({bool withAuth = true}) async {
    final res = await _get('/api/Doctors', withAuth: withAuth);
    _throwIfError(res);
    final data = _decodeBody(res);
    if (data is List) return data;
    return [];
  }

  /// GET /api/Doctors/{id}
  static Future<Map<String, dynamic>?> getDoctor(String id,
      {bool withAuth = true}) async {
    final res = await _get('/api/Doctors/$id', withAuth: withAuth);
    _throwIfError(res);
    final data = _decodeBody(res);
    return (data is Map<String, dynamic>) ? data : null;
  }

  // --------------- SessionRecords ---------------
  /// GET /api/SessionRecords
  static Future<List<dynamic>> listSessionRecords({bool withAuth = true}) async {
    final res = await _get('/api/SessionRecords', withAuth: withAuth);
    _throwIfError(res);
    final data = _decodeBody(res);
    if (data is List) return data;
    return [];
  }

  /// GET /api/SessionRecords/{id}
  static Future<Map<String, dynamic>?> getSessionRecord(int id,
      {bool withAuth = true}) async {
    final res = await _get('/api/SessionRecords/$id', withAuth: withAuth);
    _throwIfError(res);
    final data = _decodeBody(res);
    return (data is Map<String, dynamic>) ? data : null;
  }

  /// POST /api/SessionRecords
  static Future<Map<String, dynamic>?> createSessionRecord({
    required int aiResponseId,
    required int patientAge,
    required String patientSex,
    bool? chf,
    bool? htn,
    bool? dm,
    bool? stroke,
    bool? vascular,
    int? cha2ds2VascScore,
    bool withAuth = true,
  }) async {
    final payload = <String, dynamic>{
      'aiResponseId': aiResponseId,
      'patientAge': patientAge,
      'patientSex': patientSex,
      if (chf != null) 'chf': chf,
      if (htn != null) 'htn': htn,
      if (dm != null) 'dm': dm,
      if (stroke != null) 'stroke': stroke,
      if (vascular != null) 'vascular': vascular,
      if (cha2ds2VascScore != null) 'cha2ds2VascScore': cha2ds2VascScore,
    };
    final res = await _postSmart('/api/SessionRecords', payload, withAuth: withAuth);
    _throwIfError(res);
    final data = _decodeBody(res);
    return (data is Map<String, dynamic>) ? data : null;
  }

  /// PUT /api/SessionRecords/{id}
  static Future<Map<String, dynamic>?> updateSessionRecord(
    int id, {
    bool? chf,
    bool? htn,
    bool? dm,
    bool? stroke,
    bool? vascular,
    int? patientAge,
    String? patientSex,
    bool withAuth = true,
  }) async {
    final payload = <String, dynamic>{
      if (chf != null) 'chf': chf,
      if (htn != null) 'htn': htn,
      if (dm != null) 'dm': dm,
      if (stroke != null) 'stroke': stroke,
      if (vascular != null) 'vascular': vascular,
      if (patientAge != null) 'patientAge': patientAge,
      if (patientSex != null) 'patientSex': patientSex,
    };
    final res = await _putSmart('/api/SessionRecords/$id', payload, withAuth: withAuth);
    _throwIfError(res);
    final data = _decodeBody(res);
    return (data is Map<String, dynamic>) ? data : null;
  }

  /// DELETE /api/SessionRecords/{id}
  static Future<void> deleteSessionRecord(int id, {bool withAuth = true}) async {
    final res = await _delete('/api/SessionRecords/$id', withAuth: withAuth);
    _throwIfError(res);
  }

  // --------------- Error handling & helpers ---------------
  static void _throwIfError(http.Response res, {int minOk = 200, int maxOk = 299}) {
    if (res.statusCode < minOk || res.statusCode > maxOk) {
      final detail = _bestErrorDetail(res.body);
      throw Exception('Server error ${res.statusCode}${detail.isNotEmpty ? ': $detail' : ''}');
    }
  }

  static String _bestErrorDetail(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return '';
    try {
      final obj = json.decode(trimmed);
      if (obj is Map) {
        if (obj['message'] is String) return obj['message'] as String;
        if (obj['error'] is String) return obj['error'] as String;
        if (obj['title'] is String) return obj['title'] as String;
        if (obj['errors'] != null) return obj['errors'].toString();
      }
      // If it's not a map, return the raw JSON.
      return trimmed;
    } catch (_) {
      // Not JSON — return raw text.
      return trimmed;
    }
  }

  static Map<String, dynamic>? _tryParseJson(String body) {
    try {
      final obj = json.decode(body);
      if (obj is Map<String, dynamic>) return obj;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Tries common token field names returned by many backends.
  static String? _extractToken(Map<String, dynamic>? obj) {
    if (obj == null) return null;
    final candidates = [
      'access_token',
      'accessToken',
      'token',
      'jwt',
      'id_token',
      'idToken',
    ];
    for (final k in candidates) {
      final v = obj[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }
}
