import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/presentation/logged_in_main_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';

class AppRoutes {
  static const login = '/';
  static const signUp = '/signup';
  static const home = '/home';

  static final routes = <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    signUp: (_) => const SignUpScreen(),
    home: (_) => const LoggedInMainScreen(),
  };
}