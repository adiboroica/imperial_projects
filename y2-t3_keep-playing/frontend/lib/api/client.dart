import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:keep_playing_frontend/api/exceptions.dart';
import 'package:keep_playing_frontend/api/status.dart';

/// Thin HTTP wrapper that handles auth headers, JSON encoding, and error checking.
class ApiClient {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');

  final http.Client _client;
  String? _token;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        if (_token != null) 'Authorization': 'Token $_token',
        'Content-Type': 'application/json; charset=UTF-8',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) async {
    final response = await _client.get(_uri(path), headers: _headers);
    _checkResponse(response);
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ApiException(statusCode: response.statusCode, body: response.body);
    }
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkResponse(response);
    return response;
  }

  /// Posts form-encoded data without auth headers or error checking.
  /// Used for login (unauthenticated, caller checks status directly).
  Future<http.Response> postForm(String path, {required Map<String, String> fields}) async {
    final response = await _client.post(_uri(path), body: fields);
    return response;
  }

  Future<http.Response> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.patch(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkResponse(response);
    return response;
  }

  Future<http.Response> delete(String path) async {
    final response = await _client.delete(_uri(path), headers: _headers);
    _checkResponse(response);
    return response;
  }

  /// GET a JSON array and deserialise each element with [fromJson].
  Future<List<T>> getList<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final body = await get(path);
    return (body as List<dynamic>).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET a single JSON object and deserialise it with [fromJson].
  Future<T> getOne<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final body = await get(path);
    return fromJson(body as Map<String, dynamic>);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(statusCode: response.statusCode, body: response.body);
    }
  }
}
