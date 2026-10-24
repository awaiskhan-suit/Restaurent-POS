import 'package:flutter/material.dart';

/// Owns everything the Login form needs: form key, text controllers
/// and validation rules. Created & disposed by Riverpod
/// (see `loginControllerProvider`).
class LoginFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ---- Clean values ---------------------------------------------------------
  String get email => emailController.text.trim();
  String get password => passwordController.text;

  // ---- Validation -----------------------------------------------------------
  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'Enter a valid email address';
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Runs every validator. Returns true when the form is valid.
  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}


