import 'package:http/http.dart' as http;

import 'package:keep_playing_frontend/models/user.dart';

/// What the auth state layer needs — login, user validation, token management.
/// Pages use [UserRepository] for user queries and sign-up.
abstract class AuthRepository {
  Future<http.Response> login({required UserLogin userLogin});
  Future<void> logout();
  Future<User> getCurrentUser();
  void setToken(String? token);
}
