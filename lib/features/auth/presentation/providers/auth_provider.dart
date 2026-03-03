import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

// ─── State ───────────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;
  const AuthAuthenticated({required this.user, required this.token});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;

  AuthNotifier(this._loginUsecase) : super(const AuthInitial());

  Future<void> login({
    required String identifiant,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _loginUsecase(identifiant: identifiant, password: password);
      state = AuthAuthenticated(user: result.user, token: result.token);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  void logout() => state = const AuthUnauthenticated();

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}

// ─── Provider (override dans di.dart) ────────────────────────────────────────

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  throw UnimplementedError('Override authProvider in ProviderScope');
});
