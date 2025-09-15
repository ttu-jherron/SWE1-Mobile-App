import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'core/theme.dart';
import 'core/routing.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hippo Exchange',
      theme: buildTheme(),
      initialRoute: AppRoutes.profile, //login
      routes: AppRoutes.routes,
=======
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: 'pk_test_aW4taHVza3ktMjMuY2xlcmsuYWNjb3VudHMuZGV2JA',
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hippo Exchange',
        theme: buildTheme(),
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
>>>>>>> dev
    );
  }
}
