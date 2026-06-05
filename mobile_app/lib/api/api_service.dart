import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Base URL of the Django backend.
///
/// IMPORTANT for testing:
///  - Android emulator reaches your computer's localhost via 10.0.2.2
///  - iOS simulator can use 127.0.0.1
///  - A physical device needs your machine's LAN IP (e.g. 192.168.1.20)
/// Override at build time with: --dart-define=API_URL=http://host:8000/api
const String kApiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://127.0.0.1:8000/api',
);

/// Thrown when the API returns an error; carries a human-readable message.
class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => message;
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _storage = const FlutterSecureStorage();
  String? _access;
  String? _refresh;

  // ---- token lifecycle ----
  Future<void> loadTokens() async {
    _access = await _storage.read(key: 'access');
    _refresh = await _storage.read(key: 'refresh');
  }

  Future<void> _saveTokens(String access, String? refresh) async {
    _access = access;
    await _storage.write(key: 'access', value: access);
    if (refresh != null) {
      _refresh = refresh;
      await _storage.write(key: 'refresh', value: refresh);
    }
  }

  Future<void> clearTokens() async {
    _access = null;
    _refresh = null;
    await _storage.deleteAll();
  }

  bool get hasToken => _access != null;

  /// Decode the JWT payload to read role/email without a library.
  Map<String, dynamic>? get claims {
    if (_access == null) return null;
    try {
      final parts = _access!.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      return jsonDecode(utf8.decode(base64.decode(payload)))
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? get role => claims?['role'] as String?;
  String? get email => claims?['email'] as String?;

  // ---- core request with one automatic refresh-and-retry on 401 ----
  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool retry = true,
  }) async {
    final uri = Uri.parse('$kApiUrl$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_access != null) headers['Authorization'] = 'Bearer $_access';

    late http.Response res;
    final encoded = body == null ? null : jsonEncode(body);
    switch (method) {
      case 'GET':
        res = await http.get(uri, headers: headers);
        break;
      case 'POST':
        res = await http.post(uri, headers: headers, body: encoded);
        break;
      case 'PATCH':
        res = await http.patch(uri, headers: headers, body: encoded);
        break;
      default:
        throw ApiException('Unsupported method $method');
    }

    if (res.statusCode == 401 && retry && _refresh != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(method, path, body: body, retry: false);
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }

    throw ApiException(_extractError(res), status: res.statusCode);
  }

  Future<bool> _tryRefresh() async {
    try {
      final res = await http.post(
        Uri.parse('$kApiUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refresh}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await _saveTokens(data['access'] as String, null);
        return true;
      }
    } catch (_) {}
    await clearTokens();
    return false;
  }

  String _extractError(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map) {
        if (data['detail'] != null) return data['detail'].toString();
        // Field errors: join them into one line.
        return data.entries
            .map((e) => '${e.key}: ${(e.value is List) ? (e.value as List).join(', ') : e.value}')
            .join('  ');
      }
      if (data is List && data.isNotEmpty) return data.first.toString();
    } catch (_) {}
    return 'Something went wrong (HTTP ${res.statusCode}).';
  }

  // ---- auth ----
  Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$kApiUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _saveTokens(data['access'] as String, data['refresh'] as String?);
      return;
    }
    throw ApiException(_extractError(res), status: res.statusCode);
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    final res = await http.post(
      Uri.parse('$kApiUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(_extractError(res), status: res.statusCode);
    }
  }

  // ---- list helper: handle paginated or plain list responses ----
  List<dynamic> _asList(dynamic data) {
    if (data is Map && data['results'] is List) return data['results'] as List;
    if (data is List) return data;
    return const [];
  }

  // ---- student endpoints ----
  Future<Map<String, dynamic>> getStudentProfile() async =>
      (await _send('GET', '/students/me/')) as Map<String, dynamic>;

  Future<Map<String, dynamic>> updateStudentProfile(
          Map<String, dynamic> data) async =>
      (await _send('PATCH', '/students/me/', body: data))
          as Map<String, dynamic>;

  Future<List<dynamic>> getPostings({String? search}) async {
    final q = (search != null && search.isNotEmpty)
        ? '?search=${Uri.encodeQueryComponent(search)}'
        : '';
    return _asList(await _send('GET', '/postings/$q'));
  }

  Future<List<dynamic>> getMyApplications() async =>
      _asList(await _send('GET', '/applications/'));

  Future<void> apply(int postingId, String coverLetter) async {
    await _send('POST', '/applications/',
        body: {'posting': postingId, 'cover_letter': coverLetter});
  }

  Future<void> withdraw(int applicationId) async {
    await _send('POST', '/applications/$applicationId/withdraw/');
  }

  // ---- company endpoints (the app also supports company users) ----
  Future<List<dynamic>> getPostingApplications(int postingId) async =>
      _asList(await _send('GET', '/postings/$postingId/applications/'));

  Future<void> setApplicationStatus(int applicationId, String status) async {
    await _send('POST', '/applications/$applicationId/status/',
        body: {'status': status});
  }

  Future<List<dynamic>> getCompanies() async =>
      _asList(await _send('GET', '/companies/'));

  Future<List<dynamic>> getStudents() async =>
      _asList(await _send('GET', '/students/'));

  Future<void> approvePosting(int postingId) async {
    await _send('POST', '/postings/$postingId/approve/');
  }

  Future<void> rejectPosting(int postingId) async {
    await _send('POST', '/postings/$postingId/reject/');
  }

  Future<void> verifyCompany(int companyId) async {
    await _send('POST', '/companies/$companyId/verify/');
  }

  Future<void> createPosting(Map<String, dynamic> data) async {
    await _send('POST', '/postings/', body: data);
  }

  // ---- notifications ----
  Future<List<dynamic>> getNotifications() async =>
      _asList(await _send('GET', '/notifications/'));

  Future<int> unreadCount() async {
    final data = await _send('GET', '/notifications/unread_count/');
    return (data is Map && data['unread'] is int) ? data['unread'] as int : 0;
  }

  Future<void> markAllRead() async {
    await _send('POST', '/notifications/read_all/');
  }
}
