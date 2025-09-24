import 'package:flutter/material.dart';
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
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final zipCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    stateCtrl.dispose();
    zipCtrl.dispose();
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
              // "HE Sign Up" heading
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: Spacing.md),
                        const Text(
                          'Address',
                          style: TextStyle(
                            color: AppColors.sandyYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
                                  const Text(
                                    'State',
                                    style: TextStyle(
                                      color: AppColors.sandyYellow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
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
                                  const Text(
                                    'Zip Code',
                                    style: TextStyle(
                                      color: AppColors.sandyYellow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
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
                      ],
                    ),

                    const SizedBox(height: Spacing.xl + Spacing.sm),
                    Center(
                      child: PrimaryButton(
                        text: 'Sign Up',
                        variant: ButtonVariant.yellowFilled, // yellow pill
                        onPressed: () {
                          // TODO: validate + register
                        },
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
                          // co pilot how can i make this log in sandyYellow?
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
                    const SizedBox(height: Spacing.xl),
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
