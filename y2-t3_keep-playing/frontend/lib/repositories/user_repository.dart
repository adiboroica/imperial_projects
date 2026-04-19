import 'package:http/http.dart' as http;

import 'package:keep_playing_frontend/models/event.dart';
import 'package:keep_playing_frontend/models/user.dart';

/// User lookup, sign-up, and profile operations.
abstract class UserRepository {
  Future<User> getUser(int pk);
  Future<User> getOrganiserOfEvent(Event event);
  Future<List<User>> getAllUsers();
  Future<http.StreamedResponse> signUpAsCoach({required CoachSignUp signUp});
  Future<http.Response> signUpAsOrganiser({required OrganiserSignUp signUp});
}
