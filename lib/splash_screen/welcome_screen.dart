import 'dart:ui';

import 'package:flutter/material.dart';

import '../Colors/app_color.dart';
import '../auth/Sign_Up.dart';


/// ---------------------------------------------------------------------------
/// YOUR images (declared in pubspec.yaml under flutter -> assets)
/// The name must match the real file EXACTLY (capital letters + extension).
/// ---------------------------------------------------------------------------
/// Welcome screen background:
const String kWelcomeBackgroundAsset = 'assets/images/SplashScreen.jpg';

/// Your other image (not used on this screen):
const String kLoginImageAsset = 'assets/images/login.jpg';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onLogin,
    this.onSignUp,
  });

  /// Optional overrides. If [onSignUp] is null, the Sign Up button opens
  /// the Sign Up screen automatically.
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Background image from assets (your SplashScreen.jpg) --------
          Image.asset(
            kWelcomeBackgroundAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            // Shows the problem on screen if the image can't be loaded.
            // You can delete this errorBuilder once the image appears.
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Image not found:\n$kWelcomeBackgroundAsset\n\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),

          // ---- Soft dark gradient so text/buttons stay readable ------------
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.35),
                  Color.fromRGBO(0, 0, 0, 0.05),
                  Color.fromRGBO(0, 0, 0, 0.10),
                  Color.fromRGBO(0, 0, 0, 0.55),
                ],
                stops: [0.0, 0.30, 0.60, 1.0],
              ),
            ),
          ),

          // ---- Foreground content ------------------------------------------
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.07),
                  const _NourishLogo(),
                  const Spacer(),
                  _AuthButtons(onLogin: onLogin, onSignUp: onSignUp),
                  const SizedBox(height: 14),
                  const _InfoCard(),
                  SizedBox(height: size.height * 0.025),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Logo: "N [fork&knife in ring] URISH" + tagline
// =============================================================================
class _NourishLogo extends StatelessWidget {
  const _NourishLogo();

  @override
  Widget build(BuildContext context) {
    const double fontSize = 40;

    const TextStyle letterStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 6,
      height: 1,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('N', style: letterStyle),
              // The "O" of NOURISH: a white ring holding an orange fork & knife.
              Container(
                width: fontSize * 0.95,
                height: fontSize * 0.95,
                margin: const EdgeInsets.only(right: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textPrimary, width: 3.5),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.primary,
                  size: fontSize * 0.55,
                ),
              ),
              const Text('URISH', style: letterStyle),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'GOOD FOOD  •  BRIGHTER DAYS',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Login (glass) + Sign Up (orange) buttons
// =============================================================================
class _AuthButtons extends StatelessWidget {
  const _AuthButtons({this.onLogin, this.onSignUp});

  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;

  static const double _height = 52;
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Login — translucent glass button
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Material(
                color: AppColors.glassFill,
                child: InkWell(
                  onTap: onLogin,
                  child: Container(
                    height: _height,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_radius),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Sign Up — orange gradient button  ->  opens the Sign Up screen
        Expanded(
          flex: 5,
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(_radius),
              child: InkWell(
                borderRadius: BorderRadius.circular(_radius),
                // Uses your own callback if given, otherwise navigates to
                // the Sign Up screen (with its fade + slide animation).
                onTap: onSignUp ??
                        () => Navigator.of(context).push(SignUpScreen.route()),
                child: const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Glass info card: "Find your favourite food from top restaurants"
// =============================================================================
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  static const double _radius = 18;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.glassFillSoft,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Find your favourite food\nfrom top restaurants',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}