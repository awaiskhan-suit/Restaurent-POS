import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/Splash_Screen_model.dart'; // AuthState & AuthStatus

// =============================================================================
// AUTH — Login / Sign Up / Continue As Guest / Forgot Password
// =============================================================================
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Keep Riverpod state in sync with Firebase
    final sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userName: user.displayName ??
              user.email?.split('@').first ??
              'User',
          clearError: true,
        );
      } else if (state.status != AuthStatus.guest) {
        // Don't overwrite guest mode
        state = const AuthState();
      }
    });

    ref.onDispose(sub.cancel);

    // Initial value (already logged in)
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      return AuthState(
        status: AuthStatus.authenticated,
        userName: current.displayName ??
            current.email?.split('@').first ??
            'User',
      );
    }
    return const AuthState();
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // authStateChanges listener will update status + userName
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapError(e.code),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN UP
  // ---------------------------------------------------------------------------
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Save display name so it appears in Firebase + later screens
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
        userName: name.trim(),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapError(e.code),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD (send reset email)
  // ---------------------------------------------------------------------------
  Future<bool> sendPasswordResetEmail({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapError(e.code),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // GUEST
  // ---------------------------------------------------------------------------
  void continueAsGuest() {
    state = const AuthState(
      status: AuthStatus.guest,
      userName: 'Guest',
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AuthState();
  }

  // ---------------------------------------------------------------------------
  // Friendly error messages
  // ---------------------------------------------------------------------------
  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

final authProvider =
NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);