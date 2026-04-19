import 'package:keep_playing_frontend/models/user.dart';

/// Sealed hierarchy representing the authentication lifecycle.
sealed class AuthState {
  const AuthState();
}

/// App just launched; auth status unknown.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Login or session restore in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is logged in with a valid token.
class AuthAuthenticated extends AuthState {
  final User user;
  final String token;
  const AuthAuthenticated({required this.user, required this.token});
}

/// User has explicitly logged out.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Login or session restore failed.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
