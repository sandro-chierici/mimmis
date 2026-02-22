import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Thin wrapper around [http.Client] that adds:
/// - Base URL injection
/// - JSON headers
/// - Uniform error handling (throws [ApiException] on non-2xx)
class ApiClient {
  ApiClient({required String baseUrl, http.Client? client})
      : _base = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
        _client = client ?? http.Client();

  final Uri _base;
  final http.Client _client;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Uri _uri(String path) =>
      _base.resolve(path.startsWith('/') ? path.substring(1) : path);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  dynamic _parse(http.Response res) {
    log('${res.request?.method} ${res.request?.url} → ${res.statusCode}',
        name: 'ApiClient');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    // Try to extract structured error from backend ErrorResponse.
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw ApiException(
        code: body['code'] as int? ?? res.statusCode,
        message: body['message'] as String? ?? res.reasonPhrase ?? 'error',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(code: res.statusCode, message: res.reasonPhrase ?? 'error');
    }
  }

  // ── Public verbs ───────────────────────────────────────────────────────────

  Future<dynamic> get(String path) async {
    try {
      final res = await _client.get(_uri(path), headers: _headers);
      return _parse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(code: 0, message: e.toString());
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client.post(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _parse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(code: 0, message: e.toString());
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client.put(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _parse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(code: 0, message: e.toString());
    }
  }

  Future<void> delete(String path) async {
    try {
      final res = await _client.delete(_uri(path), headers: _headers);
      _parse(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(code: 0, message: e.toString());
    }
  }
}
