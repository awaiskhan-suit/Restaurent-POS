import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Controller/Sign_In_Controller.dart';

import 'auth_provider.dart'; // your Firebase Auth provider

// =============================================================================
// Form controller provider (creates + disposes the text controllers)
// =============================================================================
final loginControllerProvider =
Provider.autoDispose<LoginFormController>((ref) {
  final controller = LoginFormController();
  ref.onDispose(controller.dispose);
  return controller;
});

// =============================================================================
// UI state for the Login screen
// =============================================================================
@immutable
class LoginState {
  const LoginState({
    this.hidePassword = true,
    this.isSubmitting = false,
  });

  final bool hidePassword;
  final bool isSubmitting;

  LoginState copyWith({
    bool? hidePassword,
    bool? isSubmitting,
  }) {
    return LoginState(
      hidePassword: hidePassword ?? this.hidePassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void togglePassword() =>
      state = state.copyWith(hidePassword: !state.hidePassword);

  /// Calls the shared auth provider. On success the listener in
  /// the screen (or main.dart) opens the Home screen.
  Future<bool> submit({
    required String email,
    required String password,
  }) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      return await ref.read(authProvider.notifier).login(
        email: email,
        password: password,
      );
    } finally {
      // Screen may already be closed after a successful login
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }
}

final loginProvider =
NotifierProvider.autoDispose<LoginNotifier, LoginState>(
  LoginNotifier.new,
);