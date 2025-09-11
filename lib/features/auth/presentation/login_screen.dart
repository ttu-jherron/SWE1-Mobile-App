import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/presentation/widgets/custom_text_field.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import 'widgets/app_header_hero.dart';
import 'widgets/app_text_field.dart';
import 'widgets/primary_button.dart';
import 'widgets/link_text.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome!'),
            if (user != null) ...[
              const SizedBox(height: 8),
              Text('Username: ${user.username ?? "N/A"}'),
              Text('Email: ${user.email ?? "N/A"}'),
            ]
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  late final ClerkAuthState _auth;
  late final StreamSubscription _errorSub;
  bool _loading = false;
  bool _errorShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = ClerkAuth.of(context);
      _auth.addListener(_onAuthChanged);
      _errorSub = _auth.errorStream.listen((err) {
        if (mounted && !_errorShown) {
          _errorShown = true;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(err.message)));
        }
      });
      if (_auth.user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  void _onAuthChanged() {
    if (!mounted) return;
    if (_auth.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _signIn(String username, String password) async {
    if (!mounted || _loading) return;
    setState(() {
      _loading = true;
      _errorShown = false;
    });

    try {
      await _auth.attemptSignIn(
        strategy: clerk.Strategy.password,
        identifier: username,
        password: password,
      );
    } catch (e) {
      if (mounted && !_errorShown) {
        _errorShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    if(mounted){
      _auth.removeListener(_onAuthChanged);
    }
    _errorSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                image: const AssetImage('assets/images/tools.jpg'),
              ),
              const SizedBox(height: 24),
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
                                'Email/Username',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              SizedBox(
                                height: 40,
                                child: AppTextField(
                                  controller: usernameCtrl,
                                  label: 'Email/Username',
                                  hint: 'Email/Username',
                                  labelColor: Colors.black,
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
                                height: 40,
                                child: AppTextField(
                                  controller: passwordCtrl,
                                  label: 'Password',
                                  hint: '************',
                                  labelColor: Colors.black,
                                  isRequired: true,
                                  obscure: true,
                                  borderColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xxl + 16),
                      // --- CHANGE IS HERE ---
                      Center(
                        child: PrimaryButton(
                          text: 'Sign In',
                          variant: ButtonVariant.darkFilled,
                          isLoading: _loading,
                          onPressed: _loading
                              ? null
                              : () {
                                  _signIn(usernameCtrl.text, passwordCtrl.text);
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