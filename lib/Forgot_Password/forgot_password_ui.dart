import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Colors/app_color.dart';
import '../Provider/forgot_password_provider.dart';
import '../Provider/auth_provider.dart';
import '../auth/Sign_In.dart';

const String kForgotPasswordBackgroundAsset = 'assets/images/login.jpg';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
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
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
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
  late final Animation<double> _buttonAnim = _step(0.40, 0.85);
  late final Animation<double> _footerAnim = _step(0.55, 1.00);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
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
    final form = ref.read(forgotPasswordControllerProvider);
    FocusScope.of(context).unfocus();

    if (!form.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.selectionClick();

    final success = await ref.read(forgotPasswordProvider.notifier).submit(
      email: form.email,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset link sent! Check your email.',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double keyboard = MediaQuery.of(context).viewInsets.bottom;

    final form = ref.watch(forgotPasswordControllerProvider);
    final state = ref.watch(forgotPasswordProvider);

    // Show Firebase errors
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
          // ---- Background --------------------------------------------------
          Positioned.fill(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _background,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(_background.value);
                  return Transform.scale(scale: 1.0 + 0.06 * t, child: child);
                },
                child: Image.asset(
                  kForgotPasswordBackgroundAsset,
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
                        'Image not found:\n$kForgotPasswordBackgroundAsset\n\n$error',
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

          // ---- Scrim -------------------------------------------------------
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

          // ---- Content -----------------------------------------------------
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
                      child: const _ForgotHeader(),
                    ),
                    SizedBox(height: size.height * 0.05),

                    // Email field
                    _Reveal(
                      animation: _emailAnim,
                      child: _GlassField(
                        controller: form.emailController,
                        hint: 'Email',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: form.validateEmail,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Send Reset Link button
                    _Reveal(
                      animation: _buttonAnim,
                      child: _ResetButton(
                        isLoading: state.isSubmitting,
                        onTap: _submit,
                      ),
                    ),
                    SizedBox(height: 22.h),

                    // Footer → Login
                    _Reveal(
                      animation: _footerAnim,
                      dy: 12,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Remember your password?  ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  LoginScreen.route(),
                                );
                              },
                              child: Text(
                                'Login',
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
// Shared widgets (same style as Login / Sign-Up)
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

class _ForgotHeader extends StatelessWidget {
  const _ForgotHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Enter your registered email and we\'ll\nsend you a reset link',
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

class _ResetButton extends StatefulWidget {
  const _ResetButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton> {
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
                  'Send Reset Link',
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