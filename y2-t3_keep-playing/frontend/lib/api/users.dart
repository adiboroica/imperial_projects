import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/repositories/auth_repository.dart';
import 'package:keep_playing_frontend/repositories/user_repository.dart';
import 'package:keep_playing_frontend/api/client.dart';

/// REST implementation of [AuthRepository] and [UserRepository].
class ApiUsers implements AuthRepository, UserRepository {
  final ApiClient _client;

  ApiUsers({required ApiClient client}) : _client = client;

  @override
  Future<http.Response> login({required UserLogin userLogin}) {
    return _client.postForm('/login/', fields: {
      'username': userLogin.username,
      'password': userLogin.password,
    });
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/logout/');
    } catch (e) {
      // Best-effort: even if the backend call fails, local state will be cleared.
      // Log for dev diagnostics so the failure isn't completely silent.
      debugPrint('logout: backend call failed ($e) — clearing local state anyway');
    }
  }

  @override
  Future<User> getCurrentUser() => _client.getOne('/user/', User.fromJson);

  @override
  Future<User> getUser(int pk) => _client.getOne('/coach/$pk/', User.fromJson);

  @override
  Future<User> getOrganiserOfEvent(Event event) =>
      _client.getOne('/event/${event.pk}/organiser/', User.fromJson);

  @override
  Future<List<User>> getAllUsers() => _client.getList('/users/', User.fromJson);

  @override
  /// Multipart POST to register a coach with an optional qualification upload.
  Future<http.StreamedResponse> signUpAsCoach({required CoachSignUp signUp}) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiClient.baseUrl}/new_coach/'));
    request.fields['username'] = signUp.username;
    request.fields['password'] = signUp.password;
    request.fields['email'] = signUp.email;
    request.fields['first_name'] = signUp.firstName;
    request.fields['last_name'] = signUp.lastName;

    if (signUp.qualificationFile != null) {
      final bytes = await signUp.qualificationFile!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'qualification',
        bytes,
        filename: signUp.qualificationFile!.name,
      ));
    }

    return request.send();
  }

  @override
  Future<http.Response> signUpAsOrganiser({required OrganiserSignUp signUp}) {
    return _client.post('/new_organiser/', body: signUp.toJson());
  }

  @override
  void setToken(String? token) => _client.setToken(token);
}
