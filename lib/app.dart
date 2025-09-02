import 'package:flutter/material.dart';
import 'core/visuals/theme.dart';
import 'core/visuals/routing.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hippo Exchange',
      theme: buildTheme(),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
