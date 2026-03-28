import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/client.dart';
import '../api/users.dart';
import '../models/user.dart';
import 'auth_state.dart';
import 'auth_storage.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiClient apiClient;
  final ApiUsers apiUsers;
  final AuthStorage _storage;

  late final Future<void> sessionRestored;

  AuthCubit({
    required this.apiClient,
    required this.apiUsers,
    AuthStorage? storage,
  })  : _storage = storage ?? AuthStorage(),
        super(const AuthInitial()) {
    sessionRestored = restoreSession();
  }

  User? get currentUser => switch (state) {
        AuthAuthenticated(user: final u) => u,
        _ => null,
      };

  Future<void> restoreSession() async {
    final token = await _storage.getToken();
    final user = await _storage.getUser();
    if (token != null && user != null) {
      apiClient.setToken(token);
      emit(AuthAuthenticated(user: user, token: token));
    }
  }

  Future<void> login({required UserLogin userLogin}) async {
    emit(const AuthLoading());
    try {
      final response = await apiUsers.login(userLogin: userLogin);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['token'] as String;

        apiClient.setToken(token);
        await _storage.saveToken(token);

        final user = await apiUsers.getCurrentUser();
        await _storage.saveUser(user);

        emit(AuthAuthenticated(user: user, token: token));
      } else {
        emit(const AuthError('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    apiClient.setToken(null);
    await _storage.clear();
    emit(const AuthUnauthenticated());
  }
}
