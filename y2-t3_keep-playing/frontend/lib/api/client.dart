import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions.dart';

class ApiClient {
  final http.Client _client;
  String? _token;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        if (_token != null) 'Authorization': 'Token $_token',
        'Content-Type': 'application/json; charset=UTF-8',
      };

  Future<dynamic> get(String path) async {
    final response = await _client.get(Uri.parse(path), headers: _headers);
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }

  Future<http.Response> postForm(String path, {required Map<String, String> fields}) async {
    final response = await _client.post(Uri.parse(path), body: fields);
    return response;
  }

  Future<http.Response> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.patch(
      Uri.parse(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }

  Future<http.Response> delete(String path) async {
    final response = await _client.delete(Uri.parse(path), headers: _headers);
    return response;
  }

  Future<List<T>> getList<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final body = await get(path);
    return (body as List<dynamic>).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<T> getOne<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final body = await get(path);
    return fromJson(body as Map<String, dynamic>);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(statusCode: response.statusCode, body: response.body);
    }
  }
}
