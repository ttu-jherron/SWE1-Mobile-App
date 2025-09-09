import 'package:flutter/material.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

import 'layout/app_layout.dart';
// Optional placeholder screens until you build them
class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold();
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 0,
      body: const Center(child: Text('Home page body')),
    );
  }
}

class _AssetsScaffold extends StatelessWidget {
  const _AssetsScaffold();
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 1,
      body: const Center(child: Text('My Assets page body')),
    );
  }
}

class AppRoutes {
  static const login = '/';
  static const signUp = '/signup';

  static const home    = '/home';
  static const assets  = '/assets';

  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  
  static final routes = <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    signUp: (_) => const SignUpScreen(),

    // stubs:
    home:        (_) => const _HomeScaffold(),   // see below
    assets:      (_) => const _AssetsScaffold(),

    // new screens:
    profile: (_) => const ProfileScreen(),
    profileEdit: (_) => const EditProfileScreen(),
  };
}