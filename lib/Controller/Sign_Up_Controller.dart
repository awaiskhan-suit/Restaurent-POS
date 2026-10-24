import 'package:flutter/material.dart';

/// Owns everything the Sign Up form needs: form key, text controllers
/// and validation rules. It is created and disposed by Riverpod
/// (see `signUpControllerProvider`), so the screen never has to dispose
/// anything manually.
class SignUpFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  // ---- Clean values ---------------------------------------------------------
  String get name => nameController.text.trim();
  String get email => emailController.text.trim();
  String get password => passwordController.text;

  // ---- Validation -----------------------------------------------------------
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

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

  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  /// Runs every validator. Returns true when the form is valid.
  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }
}



