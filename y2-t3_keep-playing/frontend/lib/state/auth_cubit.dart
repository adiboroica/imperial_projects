import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keep_playing_frontend/api/status.dart';
import 'package:keep_playing_frontend/models/user.dart';
import 'package:keep_playing_frontend/repositories/auth_repository.dart';
import 'package:keep_playing_frontend/state/auth_state.dart';
import 'package:keep_playing_frontend/state/auth_storage.dart';

/// Manages login, logout, and session restore via [AuthRepository] and [AuthStorage].
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final AuthStorage _storage;

  late final Future<void> sessionRestored;

  AuthCubit({
    required AuthRepository authRepository,
    AuthStorage? storage,
  })  : _authRepository = authRepository,
        _storage = storage ?? AuthStorage(),
        super(const AuthInitial()) {
    sessionRestored = restoreSession();
  }

  User? get currentUser => switch (state) {
        AuthAuthenticated(user: final u) => u,
        _ => null,
      };

  /// Re-authenticates from a persisted token, clearing storage on failure.
  Future<void> restoreSession() async {
    final token = await _storage.getToken();
    if (token == null) return;

    _authRepository.setToken(token);
    try {
      final user = await _authRepository.getCurrentUser();
      await _storage.saveUser(user);
      emit(AuthAuthenticated(user: user, token: token));
    } catch (_) {
      _authRepository.setToken(null);
      await _storage.clear();
    }
  }

  Future<void> login({required UserLogin userLogin}) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.login(userLogin: userLogin);
      if (response.statusCode == HttpStatus.ok) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['token'] as String;

        _authRepository.setToken(token);

        final user = await _authRepository.getCurrentUser();

        await _storage.saveToken(token);
        await _storage.saveUser(user);

        emit(AuthAuthenticated(user: user, token: token));
      } else {
        emit(const AuthError('Invalid credentials'));
      }
    } catch (e) {
      _authRepository.setToken(null);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _authRepository.setToken(null);
    await _storage.clear();
    emit(const AuthUnauthenticated());
  }
}
