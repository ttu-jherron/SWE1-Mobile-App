import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import 'widgets/app_text_field.dart';
import 'widgets/primary_button.dart';
import 'widgets/link_text.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for the required fields
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  
  // Controllers for fields to be used later (commented out in UI)
  // final addressCtrl = TextEditingController();
  // final stateCtrl = TextEditingController();
  // final zipCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // State variables for Clerk logic
  late final ClerkAuthState _auth;
  late final StreamSubscription _errorSub;
  bool _loading = false;
  bool _hasShownError = false; // Track if we've already shown an error
  DateTime? _lastErrorTime; // Track when we last showed an error
  bool _authSuccess = false; // Track if auth was successful to prevent multiple navigations
  
  static const int snackBarDuration = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = ClerkAuth.of(context);

      // Clear any previous sign-up state to avoid conflicts
      try {
        _auth.signOut();
      } catch (e) {
        // Ignore errors if no state to clear
      }
      _auth.addListener(_onAuthChanged);
      _errorSub = _auth.errorStream.listen((err) {
        if (mounted) {
          _showErrorSnackbar(err.message);
        }
      });
    });
  }
  
  // This listener will navigate to home after successful signup
  void _onAuthChanged() {
    if (kDebugMode) {
      debugPrint('_onAuthChanged called - mounted: $mounted, _authSuccess: $_authSuccess, user: ${_auth.user?.id}');
    }
    
    if (!mounted || _authSuccess) return; // Prevent multiple navigations
    
    if (_auth.user != null) {
      if (kDebugMode) {
        debugPrint('User authenticated, navigating to home...');
      }
      _authSuccess = true; // Mark as successful to prevent multiple calls
      // Reset loading state before navigation
      setState(() { _loading = false; });
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  // Helper method to show error snackbar with duplicate prevention
  void _showErrorSnackbar(String message) {
    final now = DateTime.now();
    final devcallId = now.millisecondsSinceEpoch; // Unique identifier for this call
    if(mounted) _loading = true;
    
    if (kDebugMode) {
      debugPrint('=== _showErrorSnackbar called [ID: $devcallId] ===');
      debugPrint('Message: $message');
      debugPrint('_hasShownError: $_hasShownError');
      debugPrint('_lastErrorTime: $_lastErrorTime');
      if (_lastErrorTime != null) {
        debugPrint('Time difference: ${now.difference(_lastErrorTime!).inSeconds} seconds');
      }
      debugPrint('Stack trace: ${StackTrace.current}');
    }
    
    // Prevent duplicate snackbars within 6 seconds
    if (_hasShownError && _lastErrorTime != null && 
        now.difference(_lastErrorTime!).inSeconds < 6) {
      if (kDebugMode) {
        debugPrint('BLOCKED duplicate snackbar [ID: $devcallId]');
      }
      return;
    }
    
    _hasShownError = true;
    _lastErrorTime = now;
    
    if (kDebugMode) {
      debugPrint('SHOWING snackbar [ID: $devcallId]: $message');
    }
    
    // Clear any existing snackbars first to prevent stacking
    ScaffoldMessenger.of(context).clearSnackBars();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    
    // If we're currently in a loading state, keep it active for the duration of the snackbar
    if (_loading) {
      Future.delayed(const Duration(seconds: snackBarDuration), () {
        if (mounted) setState(() { _loading = false; });
      });
    }
  }

  // --- REVISED SIGN UP LOGIC ---
  Future<void> _signUp() async {
    // Prevent multiple simultaneous requests
    if (!mounted || _loading || _authSuccess) return;
    
    // Reset error tracking for new attempt
    _hasShownError = false;
    _lastErrorTime = null;
    
    // Set loading state immediately to prevent spam clicking
    setState(() { _loading = true; });

    try {
      await _auth.refreshClient();
    } catch (e) {
      // If refreshClient doesn't exist, continue anyway
      debugPrint('refreshClient not available: $e');
    }

    // Simple Local validation
    if (usernameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        confirmCtrl.text.isEmpty) {
        if (mounted) {
          _showErrorSnackbar('Please fill in all fields.');
        }
      return;
    }

    if (passwordCtrl.text != confirmCtrl.text) {
      if (mounted) {
        _showErrorSnackbar('Passwords do not match');
      }
      return;
    }

    try {
      // Clear any previous sign-up state before attempting new sign-up
      try {
        _auth.signOut();
        _auth.refreshClient();
        _auth.refreshEnvironment();
      } catch (e) {
        debugPrint('Error clearing state: $e');
      }
      
      if (kDebugMode) {
        debugPrint('Attempting sign-up for: ${emailCtrl.text}');
      }
      
      await _auth.attemptSignUp(
        strategy: clerk.Strategy.password,
        emailAddress: emailCtrl.text,
        password: passwordCtrl.text,
        passwordConfirmation: confirmCtrl.text,
        username: usernameCtrl.text,
      );
      
      // If we reach here, sign-up was successful
      if (kDebugMode) {
        debugPrint('Sign-up successful, waiting for auth state change...');
      }
    } catch (e) {
      if (mounted) {
        // Clear any partial sign-up state that might have been created
        try {
          _auth.signOut();
          _auth.refreshClient();
          _auth.refreshEnvironment();
        } catch (clearError) {
          debugPrint('Error clearing state after failed sign-up: $clearError');
        }
        _showErrorSnackbar('Error: ${e.toString()}');
      }
    } finally {
      // Fallback: If loading is still true, reset it
      // This prevents permanent loading in case something goes wrong
      Future.delayed(const Duration(seconds: snackBarDuration + 1), () {
        if (mounted && _loading) {
          setState(() { _loading = false; });
        }
      });
    }
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    emailCtrl.dispose();
    // addressCtrl.dispose();
    // stateCtrl.dispose();
    // zipCtrl.dispose();
    _auth.removeListener(_onAuthChanged);
    _errorSub.cancel();
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
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'HE',
                      style: TextStyle(
                        color: AppColors.sandyYellow,
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                      ),
                    ),
                    TextSpan(
                      text: '  Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // --- USERNAME, EMAIL, PASSWORD FIELDS ---
                    const Text(
                          'Username',
                          style: TextStyle(
                            color: AppColors.sandyYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        AppTextField(
                          controller: usernameCtrl,
                          label: 'Username',
                          borderColor: AppColors.sandyYellow,
                        ),
                        const SizedBox(height: Spacing.md),
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: AppColors.sandyYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        AppTextField(
                          controller: passwordCtrl,
                          label: 'Password',
                          obscure: true,
                          borderColor: AppColors.sandyYellow,
                        ),
                        const SizedBox(height: Spacing.md),
                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                            color: AppColors.sandyYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        AppTextField(
                          controller: confirmCtrl,
                          label: 'Confirm Password',
                          obscure: true,
                          borderColor: AppColors.sandyYellow,
                        ),
                        const SizedBox(height: Spacing.md),
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: AppColors.sandyYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        AppTextField(
                          controller: emailCtrl,
                          label: 'Email',
                          borderColor: AppColors.sandyYellow,
                        ),
                    
                    // --- ADDRESS FIELDS (COMMENTED OUT) ---
                    /* const SizedBox(height: Spacing.md),
                    const Text('Address', style: TextStyle(...)),
                    AppTextField(
                      controller: addressCtrl,
                      label: 'Address',
                      borderColor: AppColors.sandyYellow,
                    ),
                    const SizedBox(height: Spacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('State', style: TextStyle(...)),
                              AppTextField(
                                controller: stateCtrl,
                                label: 'State',
                                borderColor: AppColors.sandyYellow,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Zip Code', style: TextStyle(...)),
                              AppTextField(
                                controller: zipCtrl,
                                label: 'Zip Code',
                                keyboardType: TextInputType.number,
                                borderColor: AppColors.sandyYellow,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    */

                    const SizedBox(height: Spacing.xl + Spacing.sm),
                    Center(
                      child: PrimaryButton(
                        text: 'Sign Up',
                        variant: ButtonVariant.yellowFilled,
                        isLoading: _loading,
                        onPressed: _signUp,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Already Have an Account?',
                            style: TextStyle(color: AppColors.sandyYellow),
                          ),
                          LinkText(
                            text: 'Log In',
                            color: AppColors.sandyYellow,
                            onTap: () => Navigator.popAndPushNamed(
                              context,
                              AppRoutes.login,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}