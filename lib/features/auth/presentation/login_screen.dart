import 'package:flutter/material.dart';
import '../../../core/visuals/colors.dart';
import '../../../core/visuals/constants.dart';
import '../../../core/visuals/routing.dart';
import 'widgets/app_header_hero.dart';
import 'widgets/app_text_field.dart';
import 'widgets/primary_button.dart';
import 'widgets/link_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Yellow background like the mock
    return Scaffold(
      backgroundColor: AppColors.sandyYellow,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppHeaderHero(
                titleLine1: 'Hippo',
                titleLine2: 'Exchange',
                subtitle: "don’t buy. borrow.",
                image: const AssetImage('assets/images/hammerTime.png'),
              ),
              const SizedBox(height: 24), // to clear the overlapping avatar

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Username',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              SizedBox(
                                height: 40, // or your desired height
                                child: AppTextField(
                                  controller: usernameCtrl,
                                  label: 'Username',
                                  hint: 'Username',
                                  borderColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              SizedBox(
                                height: 40, // or your desired height
                                child: AppTextField(
                                  controller: passwordCtrl,
                                  label: 'Password',
                                  hint: '************',
                                  obscure: true,
                                  borderColor: Colors.black,
                              ),
                            )],
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xxl + 16),

                      Center(
                        child: PrimaryButton(
                          text: 'Sign Up',
                          variant: ButtonVariant.darkFilled, // dark pill
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.signUp);
                          },
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          children: [
                            const Text(
                              'New?',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            LinkText(
                              text: 'Start Here',
                              color: Colors.black,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.signUp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),
                    ],
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
