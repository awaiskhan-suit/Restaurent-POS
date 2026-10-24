import 'package:flutter/material.dart';

/// Nourish color palette — sampled from the reference screens.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // BRAND ORANGE
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFFFD7122);
  static const Color primaryLight = Color(0xFFFF812B);
  static const Color primaryDark = Color(0xFFFD6818);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, primaryDark],
  );
  static const Color primaryGlow = Color.fromRGBO(253, 113, 34, 0.45);

  // ---------------------------------------------------------------------------
  // DARK SURFACES
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFF121213);
  static const Color header = Color(0xFF201E1D);
  static const Color surface = Color(0xFF242424);
  static const Color inputFill = Color(0xFF282828);
  static const Color stepperBox = Color(0xFF2C2A2A);

  // ---------------------------------------------------------------------------
  // TEXT
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAFACAC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // RATING STAR
  // ---------------------------------------------------------------------------
  static const Color star = Color(0xFFEECF34);

  // ---------------------------------------------------------------------------
  // GLASS / TRANSLUCENT (over photos)
  // ---------------------------------------------------------------------------
  static const Color glassFill = Color.fromRGBO(255, 255, 255, 0.18);
  static const Color glassFillSoft = Color.fromRGBO(255, 255, 255, 0.14);
  static const Color glassFillFocused = Color.fromRGBO(255, 255, 255, 0.26); // NEW
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.28);
  static const Color darkChip = Color.fromRGBO(0, 0, 0, 0.45);

  // ---------------------------------------------------------------------------
  // NEW: forms, errors and image overlay
  // ---------------------------------------------------------------------------
  static const Color error = Color(0xFFFF8A80);
  static const Color fieldGlow = Color.fromRGBO(253, 113, 34, 0.28);

  /// Dark overlay on top of background photos (top -> middle -> bottom).
  static const Color scrimTop = Color.fromRGBO(0, 0, 0, 0.55);
  static const Color scrimMid = Color.fromRGBO(0, 0, 0, 0.45);
  static const Color scrimBottom = Color.fromRGBO(0, 0, 0, 0.72);
}

