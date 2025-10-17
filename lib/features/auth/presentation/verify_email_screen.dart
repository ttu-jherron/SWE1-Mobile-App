import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import 'widgets/primary_button.dart';
import 'widgets/app_text_field.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String password;
  final String passwordConfirm;
  final String username;
  const VerifyEmailScreen({super.key, required this.email, required this.password, required this.passwordConfirm, required this.username});


  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeCtrl = TextEditingController();
  late final ClerkAuthState _auth;
  bool _loading = false;

  // Resend guards
  bool _resending = false;
  DateTime? _lastResendAt;
  static const Duration _resendCooldown = Duration(seconds: 30);
  bool get _resendDisabled => _loading || _resending;

  // Dedup SnackBars within a short window
  String? _lastSnackMsg;
  DateTime? _lastSnackAt;
  void _snack(String msg) {
    final now = DateTime.now();
    if (_lastSnackMsg == msg && _lastSnackAt != null && now.difference(_lastSnackAt!) < const Duration(seconds: 2)) {
      return; // suppress duplicate
    }
    _lastSnackMsg = msg;
    _lastSnackAt = now;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.remove);
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = ClerkAuth.of(context);
      // Do NOT auto-send here; initial sign-up already sent the first code.
    });
  }

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _snack('Enter the code sent to your email.');
      return;
    }
    setState(() => _loading = true);
    try {
      // Verify using emailCode
      await _auth.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        emailAddress: widget.email,
        code: code,
      );

      if (!mounted) return;
      
      // Check if user is now authenticated after verification
      if (_auth.user != null) {
        // User is successfully signed up and signed in
        ScaffoldMessenger.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.remove); // clear any pending snackbars
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      } else {
        // If verification succeeded but user is still null, try signing in
        try {
          await _auth.attemptSignIn(
            strategy: clerk.Strategy.password,
            identifier: widget.email,
            password: widget.password,
          );
          if (!mounted) return;
          if (_auth.user != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.remove); // clear any pending snackbars
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          } else {
            _snack('Email verified! Please sign in with your credentials.');
            Navigator.of(context).pop(true);
          }
        } catch (signInError) {
          if (!mounted) return;
          _snack('Email verified! Please sign in with your credentials.');
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Verification failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    // Single-flight + cooldown
    if (_resending || _loading) return;

    final now = DateTime.now();
    if (_lastResendAt != null) {
      final remaining = _resendCooldown - now.difference(_lastResendAt!);
      if (remaining > Duration.zero) {
        _snack('Please wait ${remaining.inSeconds}s before resending.');
        return;
      }
    }

    // EXACT SAME implementation as initial: use password strategy
    _resending = true;
    _lastResendAt = now; // block re-entry immediately
    setState(() => _loading = true);

    try {
      await _auth.signOut();
      await _auth.refreshClient();
      await _auth.refreshEnvironment();
      await _auth.attemptSignUp(
        strategy: clerk.Strategy.password,
        emailAddress: widget.email,
        password: widget.password,
        passwordConfirmation: widget.passwordConfirm,
        username: widget.username,
      );
      if (!mounted) return;
      _snack('A new code has been sent.');
    } catch (e) {
      if (!mounted) return;
      _lastResendAt = null; // allow retry
      _snack(e.toString());
    } finally {
      _resending = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ebonyClay,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Email',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Enter the 6-digit code sent to ${widget.email}. Tap Resend if you didn’t receive it.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: Spacing.lg),
              const Text(
                'Verification Code',
                style: TextStyle(
                  color: AppColors.sandyYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              AppTextField(
                controller: _codeCtrl,
                label: '123456',
                keyboardType: TextInputType.number,
                borderColor: AppColors.sandyYellow,
                labelColor: AppColors.sandyYellow,
                textColor: AppColors.sandyYellow,
                cursorColor: AppColors.sandyYellow,
                selectionColor: AppColors.sandyYellow.withOpacity(0.35),
                selectionHandleColor: AppColors.sandyYellow,
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Verify',
                      variant: ButtonVariant.yellowFilled,
                      isLoading: _loading,
                      onPressed: _verify,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: _resendDisabled,
                      child: PrimaryButton(
                        text: 'Resend',
                        variant: ButtonVariant.yellowOutline,
                        isLoading: _resending || _loading,
                        onPressed: _resendDisabled ? null : _resend,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel and go back to Sign Up',
                    style: TextStyle(color: Colors.white70),
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
