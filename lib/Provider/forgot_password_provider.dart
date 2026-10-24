import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Controller/forgot_password.dart';
import 'auth_provider.dart';

// =============================================================================
// Form controller
// =============================================================================
final forgotPasswordControllerProvider =
Provider.autoDispose<ForgotPasswordFormController>((ref) {
  final controller = ForgotPasswordFormController();
  ref.onDispose(controller.dispose);
  return controller;
});

// =============================================================================
// UI state
// =============================================================================
@immutable
class ForgotPasswordState {
  const ForgotPasswordState({
    this.isSubmitting = false,
    this.emailSent = false,
  });

  final bool isSubmitting;
  final bool emailSent;

  ForgotPasswordState copyWith({
    bool? isSubmitting,
    bool? emailSent,
  }) {
    return ForgotPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailSent: emailSent ?? this.emailSent,
    );
  }
}

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> submit({required String email}) async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, emailSent: false);

    try {
      final success = await ref
          .read(authProvider.notifier)
          .sendPasswordResetEmail(email: email);

      if (ref.mounted) {
        state = state.copyWith(
          isSubmitting: false,
          emailSent: success,
        );
      }
      return success;
    } finally {
      if (ref.mounted && state.isSubmitting) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }
}

final forgotPasswordProvider =
NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);