import 'package:flutter/material.dart';

class ForgotPasswordFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  String get email => emailController.text.trim();

  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'Enter a valid email address';
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose() {
    emailController.dispose();
  }
}