import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:mobile_app/core/routing.dart';

class LoggedInMainScreen extends StatelessWidget {
  const LoggedInMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are logged in!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (user != null) ...[
              Text('Username: ${user.username ?? "N/A"}'),
              Text('Email: ${user.email ?? "N/A"}'),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}