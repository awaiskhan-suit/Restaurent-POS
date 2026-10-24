import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../Controller/Sign_Up_Controller.dart';
import 'home_screen_provider.dart'; // contains authProvider

// =============================================================================
// Form controller provider (creates + disposes the text controllers)
// =============================================================================
final signUpControllerProvider =
Provider.autoDispose<SignUpFormController>((ref) {
  final controller = SignUpFormController();
  ref.onDispose(controller.dispose);
  return controller;
});

// =============================================================================
// UI state for the Sign Up screen
// =============================================================================
@immutable
class SignUpState {
  const SignUpState({
    this.hidePassword = true,
    this.hideConfirm = true,
    this.isSubmitting = false,
  });

  final bool hidePassword;
  final bool hideConfirm;
  final bool isSubmitting;

  SignUpState copyWith({
    bool? hidePassword,
    bool? hideConfirm,
    bool? isSubmitting,
  }) {
    return SignUpState(
      hidePassword: hidePassword ?? this.hidePassword,
      hideConfirm: hideConfirm ?? this.hideConfirm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class SignUpNotifier extends Notifier<SignUpState> {
  @override
  SignUpState build() => const SignUpState();

  void togglePassword() =>
      state = state.copyWith(hidePassword: !state.hidePassword);

  void toggleConfirm() =>
      state = state.copyWith(hideConfirm: !state.hideConfirm);

  /// Calls the shared auth provider. On success, the listener in main.dart
  /// opens the Home screen; on failure it shows the error SnackBar.
  Future<bool> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      return await ref.read(authProvider.notifier).signUp(
        name: name,
        email: email,
        password: password,
      );
    } finally {
      // The screen may already be closed after a successful sign up.
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }
}

final signUpProvider =
NotifierProvider.autoDispose<SignUpNotifier, SignUpState>(
  SignUpNotifier.new,
);



