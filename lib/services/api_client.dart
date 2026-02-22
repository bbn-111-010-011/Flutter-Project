import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({required this.tokenProvider, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;
  final TokenProvider tokenProvider;
  final String baseUrl = Constants.apiBaseUrl;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: _cleanQuery(query));
  }

  Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic>? _cleanQuery(Map<String, dynamic>? query) {
    if (query == null) return null;
    final m = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      m[key] = value.toString();
    });
    return m;
  }

  Future<Map<String, dynamic>> _decodeJson(http.Response res) async {
    final code = res.statusCode;
    final body = res.body.isEmpty ? '{}' : res.body;
    dynamic data;
    try {
      data = json.decode(body);
    } catch (_) {
      data = body;
    }

    if (code >= 200 && code < 300) {
      if (data is Map<String, dynamic>) return data;
      return {'data': data};
    } else {
      final message = _extractErrorMessage(data) ?? 'HTTP $code';
      throw ApiException(statusCode: code, message: message, payload: data);
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (data is Map && data['error'] != null) return data['error'].toString();
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  // GET
  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = false}) async {
    final token = auth ? await tokenProvider() : null;
    final res = await _http.get(_uri(path, query), headers: _jsonHeaders(token: token));
    final decoded = await _decodeJson(res);
    return decoded['data'] ?? decoded;
  }

  // POST
  Future<dynamic> post(String path, {Object? body, bool auth = false}) async {
    final token = auth ? await tokenProvider() : null;
    final res = await _http.post(
      _uri(path),
      headers: _jsonHeaders(token: token),
      body: body == null ? null : json.encode(body),
    );
    final decoded = await _decodeJson(res);
    return decoded['data'] ?? decoded;
  }

  // PUT
  Future<dynamic> put(String path, {Object? body, bool auth = false}) async {
    final token = auth ? await tokenProvider() : null;
    final res = await _http.put(
      _uri(path),
      headers: _jsonHeaders(token: token),
      body: body == null ? null : json.encode(body),
    );
    final decoded = await _decodeJson(res);
    return decoded['data'] ?? decoded;
  }

  // DELETE
  Future<dynamic> delete(String path, {bool auth = false}) async {
    final token = auth ? await tokenProvider() : null;
    final res = await _http.delete(
      _uri(path),
      headers: _jsonHeaders(token: token),
    );
    final decoded = await _decodeJson(res);
    return decoded['data'] ?? decoded;
  }

  void close() {
    _http.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic payload;
  ApiException({
    required this.statusCode,
    required this.message,
    this.payload,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
