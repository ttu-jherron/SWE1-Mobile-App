import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

import 'verify_email_screen.dart'; 
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = ClerkAuth.of(context);

      // Clear any previous sign-up state to avoid conflicts
      try {
        _auth.signOut(); // This should clear any existing auth state
      } catch (e) {
        // Ignore errors if no state to clear
      }

      _auth.addListener(_onAuthChanged);
      _errorSub = _auth.errorStream.listen((err) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(err.message)));
        }
      });
    });
  }
  
  // This listener will navigate to home if the user signs in
  // which happens automatically after successful email verification.
  void _onAuthChanged() {
    if (!mounted) return;
    if (_auth.user != null) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }

  // --- REVISED SIGN UP LOGIC ---
  Future<void> _signUp() async {
    if (!mounted) return;
    if (_loading) return;
    try {
      await _auth.refreshClient();
    } catch (e) {
      // If refreshClient doesn't exist, continue anyway
      debugPrint('refreshClient not available: $e');
    }
    // Local validation
    if (usernameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        confirmCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (passwordCtrl.text != confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() { _loading = true; });

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
      
      var client = await _auth.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        emailAddress: emailCtrl.text,
        password: passwordCtrl.text,
        passwordConfirmation: confirmCtrl.text,
        username: usernameCtrl.text,
      );

      // Debug print for status and missing fields
      if (kDebugMode) {
        debugPrint('SignUp status: ${client.signUp?.status}');
        debugPrint('SignUp missing fields: ${client.signUp?.missingFields}');
        debugPrint('SignUp unverified fields: ${client.signUp?.unverifiedFields}');
      }

      final signUp = client.signUp;
      
      if (signUp == null) {
        // No sign-up object returned, something went wrong
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up failed. Please try again.')),
          );
        }
        return;
      }

      // Handle different sign-up statuses
      switch (signUp.status) {
        case clerk.Status.missingRequirements:
          // Only navigate to verification if email verification is specifically needed
          if (signUp.missingFields.isEmpty &&
              signUp.unverifiedFields.contains(clerk.Field.emailAddress)) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyEmailScreen(),
                ),
              );
            }
          } else {
            // Handle other missing requirements
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Missing requirements: ${signUp.missingFields}')),
              );
            }
          }
          break;
          
        case clerk.Status.complete:
          // Sign-up completed successfully, user is signed in
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign-up completed successfully!')),
            );
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          }
          break;
          
        case clerk.Status.abandoned:
          // Sign-up was abandoned
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign-up was abandoned. Please try again.')),
            );
          }
          break;
          
        default:
          // Unknown status
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unexpected status: ${signUp.status}')),
            );
          }
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
        
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() { _loading = false; });
      }
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