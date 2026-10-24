import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';   // ← added

import '../Colors/app_color.dart';
import '../Forgot_Password/forgot_password_ui.dart';
import '../Provider/login_provider.dart';
import '../Provider/auth_provider.dart';
import 'Sign_Up.dart';

/// Same background image used on Sign-Up
const String kLoginBackgroundAsset = 'assets/images/login.jpg';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  /// Page transition: fade + gentle slide up.
  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => const LoginScreen(),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _background;

  Animation<double> _step(double begin, double end) {
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  late final Animation<double> _backAnim = _step(0.00, 0.40);
  late final Animation<double> _headerAnim = _step(0.10, 0.50);
  late final Animation<double> _emailAnim = _step(0.22, 0.62);
  late final Animation<double> _passAnim = _step(0.32, 0.72);
  late final Animation<double> _forgotAnim = _step(0.40, 0.80);
  late final Animation<double> _buttonAnim = _step(0.50, 0.90);
  late final Animation<double> _footerAnim = _step(0.60, 1.00);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _background = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _background.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = ref.read(loginControllerProvider);
    FocusScope.of(context).unfocus();

    if (!form.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.selectionClick();

    final success = await ref.read(loginProvider.notifier).submit(
      email: form.email,
      password: form.password,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Login successful!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // ✅ Use the router so MainShell + bottom navigation appear
      context.go('/menu');
    }
  }

  void _onForgotPassword() {
    Navigator.of(context).push(ForgotPasswordScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double keyboard = MediaQuery.of(context).viewInsets.bottom;

    final form = ref.watch(loginControllerProvider);
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Background image --------------------------------------------
          Positioned.fill(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _background,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(_background.value);
                  return Transform.scale(scale: 1.0 + 0.06 * t, child: child);
                },
                child: Image.asset(
                  kLoginBackgroundAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        'Image not found:\n$kLoginBackgroundAsset\n\n$error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ---- Dark overlay ------------------------------------------------
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.scrimTop,
                  AppColors.scrimMid,
                  AppColors.scrimBottom,
                ],
              ),
            ),
          ),

          // ---- Foreground content ------------------------------------------
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                size.width * 0.06,
                8.h,
                size.width * 0.06,
                keyboard + 16.h,
              ),
              child: Form(
                key: form.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Reveal(
                      animation: _backAnim,
                      child: _GlassBackButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),

                    _Reveal(
                      animation: _headerAnim,
                      child: const _LoginHeader(),
                    ),
                    SizedBox(height: size.height * 0.05),

                    // Email
                    _Reveal(
                      animation: _emailAnim,
                      child: _GlassField(
                        controller: form.emailController,
                        hint: 'Email',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: form.validateEmail,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Password
                    _Reveal(
                      animation: _passAnim,
                      child: _GlassField(
                        controller: form.passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: state.hidePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: form.validatePassword,
                        suffix: _VisibilityToggle(
                          isHidden: state.hidePassword,
                          onTap: notifier.togglePassword,
                        ),
                      ),
                    ),

                    // ---------- Forgot Password ----------
                    _Reveal(
                      animation: _forgotAnim,
                      dy: 12,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _onForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 8.h,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Login button
                    _Reveal(
                      animation: _buttonAnim,
                      child: _LoginButton(
                        isLoading: state.isSubmitting,
                        onTap: _submit,
                      ),
                    ),
                    SizedBox(height: 22.h),

                    // ---------- Footer: Sign Up ----------
                    _Reveal(
                      animation: _footerAnim,
                      dy: 12,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account?  ",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Prefer router if possible
                                context.go('/signup');
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Staggered entrance: fade in + slide up
// =============================================================================
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.animation,
    required this.child,
    this.dy = 24,
  });

  final Animation<double> animation;
  final Widget child;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final v = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * dy.h),
            child: child,
          ),
        );
      },
    );
  }
}

// =============================================================================
// Header
// =============================================================================
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in to continue ordering\nyour favourite food',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Glass back button
// =============================================================================
class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: AppColors.glassFill,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Glass text field
// =============================================================================
class _GlassField extends StatefulWidget {
  const _GlassField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<_GlassField> {
  static final double _radius = 14.r;
  bool _focused = false;

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: _focused
              ? const [BoxShadow(color: AppColors.fieldGlow, blurRadius: 18)]
              : const [],
        ),
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          cursorColor: AppColors.primary,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15.sp,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15.sp,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _focused ? AppColors.primary : AppColors.textSecondary,
              size: 22.sp,
            ),
            suffixIcon: widget.suffix,
            filled: true,
            fillColor:
            _focused ? AppColors.glassFillFocused : AppColors.glassFill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            errorStyle: TextStyle(
              color: AppColors.error,
              fontSize: 12.sp,
            ),
            enabledBorder: _border(AppColors.glassBorder),
            focusedBorder: _border(AppColors.primary, width: 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Password visibility toggle
// =============================================================================
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.isHidden, required this.onTap});

  final bool isHidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: Icon(
          isHidden
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          key: ValueKey<bool>(isHidden),
          color: AppColors.textSecondary,
          size: 22.sp,
        ),
      ),
    );
  }
}

// =============================================================================
// Login button
// =============================================================================
class _LoginButton extends StatefulWidget {
  const _LoginButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  static final double _height = 52.h;
  static final double _radius = 14.r;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        height: _height,
        width: double.infinity,
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
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onTap: widget.isLoading ? null : widget.onTap,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: widget.isLoading
                    ? SizedBox(
                  key: const ValueKey('loader'),
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textOnPrimary,
                  ),
                )
                    : Text(
                  'Login',
                  key: const ValueKey('label'),
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}