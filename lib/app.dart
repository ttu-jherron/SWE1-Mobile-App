import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/routing.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hippo Exchange',
      theme: buildTheme(),
      initialRoute: AppRoutes.profile, //login
      routes: AppRoutes.routes,
    );
  }
}
