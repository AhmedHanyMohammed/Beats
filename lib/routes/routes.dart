import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized CRUD utilities for Firebase Realtime Database.
/// Example usage:
/// - await ApiRoutes.login(email, password);
/// - final id = await ApiRoutes.registerUser(name, email, password);
/// - final users = await ApiRoutes.getAll('users');
/// - final uid = await ApiRoutes.create('users', {...});
/// - await ApiRoutes.update('users', uid, {...});
/// - await ApiRoutes.delete('users', uid);
class ApiRoutes {
  ApiRoutes._();

  static const String _base =
      'https://beats-94c51-default-rtdb.europe-west1.firebasedatabase.app';

  static final http.Client _client = http.Client();

  static Uri _endpoint(
    String collection, {
    String? id,
    Map<String, String>? query,
  }) {
    final path = id == null ? '/$collection.json' : '/$collection/$id.json';
    return Uri.parse('$_base$path').replace(queryParameters: query);
  }

  // ---------- Generic CRUD ----------

  /// Read all items in a collection. Returns Map[id, item] or null if empty.
  static Future<Map<String, dynamic>?> getAll(String collection) async {
    final res = await _client.get(_endpoint(collection));
    _throwIfError(res);
    final decoded = json.decode(res.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// Read one item by id. Returns Map or null if not found.
  static Future<Map<String, dynamic>?> getOne(
      String collection, String id) async {
    final res = await _client.get(_endpoint(collection, id: id));
    _throwIfError(res);
    final decoded = json.decode(res.body);
    if (decoded == null) return null;
    return Map<String, dynamic>.from(decoded as Map);
  }

  /// Create a new item. Returns generated id.
  static Future<String> create(
      String collection, Map<String, dynamic> data) async {
    final res = await _client.post(
      _endpoint(collection),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _throwIfError(res, minOk: 200, maxOk: 299);
    final decoded = json.decode(res.body);
    final id = decoded?['name'] as String?;
    if (id == null || id.isEmpty) {
      throw Exception('Create failed: missing id');
    }
    return id;
  }

  /// Update fields of an item (PATCH).
  static Future<void> update(
      String collection, String id, Map<String, dynamic> data) async {
    final res = await _client.patch(
      _endpoint(collection, id: id),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _throwIfError(res, minOk: 200, maxOk: 299);
  }

  /// Replace an item (PUT).
  static Future<void> replace(
      String collection, String id, Map<String, dynamic> data) async {
    final res = await _client.put(
      _endpoint(collection, id: id),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _throwIfError(res, minOk: 200, maxOk: 299);
  }

  /// Delete an item by id.
  static Future<void> delete(String collection, String id) async {
    final res = await _client.delete(_endpoint(collection, id: id));
    _throwIfError(res, minOk: 200, maxOk: 299);
  }

  /// Firebase query: orderBy=field, equalTo=value. Returns Map[id, item].
  static Future<Map<String, dynamic>> queryEqualTo(
    String collection, {
    required String field,
    required dynamic value,
  }) async {
    final query = {
      'orderBy': json.encode(field),
      'equalTo': json.encode(value),
    };
    final uri = _endpoint(collection, query: query);
    final res = await _client.get(uri);

    // Fast path: OK
    if (res.statusCode >= 200 && res.statusCode <= 299) {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    }

    // Graceful fallback for common 400 from Firebase (e.g., missing .indexOn).
    if (res.statusCode == 400) {
      try {
        final all = await getAll(collection);
        if (all == null) return <String, dynamic>{};
        final out = <String, dynamic>{};
        all.forEach((k, v) {
          if (v is Map && v[field] == value) out[k] = v;
        });
        return out;
      } catch (_) {
        // fall through to throw detailed error
      }
    }

    // Throw with detailed body so UI shows the real reason.
    _throwIfError(res);
    return <String, dynamic>{};
  }

  // ---------- Users helpers ----------

  static Future<bool> emailExists(String email) async {
    final r = await queryEqualTo('users', field: 'email', value: email.toLowerCase());
    return r.isNotEmpty;
  }

  /// Finds the first user by email. Returns { ...user, id } or null.
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final r = await queryEqualTo('users', field: 'email', value: email.toLowerCase());
    if (r.isEmpty) return null;
    final entry = r.entries.first;
    final user = Map<String, dynamic>.from(entry.value as Map);
    user['id'] = entry.key;
    return user;
  }

  /// Authenticates user by email/password. Returns user map with 'id'.
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final user = await findUserByEmail(email);
    if (user == null) {
      throw Exception('Email not found');
    }
    if (user['password'] != password) {
      throw Exception('Wrong password');
    }
    return user;
  }

  /// Registers a new user. Returns generated id.
  static Future<String> registerUser(
      String name, String email, String password) async {
    if (await emailExists(email)) {
      throw Exception('Email already in use');
    }
    final id = await create('users', {
      'name': name,
      'email': email.toLowerCase(),
      'password': password,
    });
    return id;
  }

  // ---------- Utils ----------

  static void _throwIfError(http.Response res, {int minOk = 200, int maxOk = 299}) {
    if (res.statusCode < minOk || res.statusCode > maxOk) {
      String detail = '';
      try {
        final body = res.body;
        if (body.isNotEmpty) {
          final obj = json.decode(body);
          if (obj is Map && obj['error'] != null) {
            detail = obj['error'].toString();
          } else {
            detail = body;
          }
        }
      } catch (_) {
        detail = res.body;
      }
      throw Exception('Server error ${res.statusCode}${detail.isNotEmpty ? ': $detail' : ''}');
    }
  }
}
