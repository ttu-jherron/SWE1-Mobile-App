import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 2, // Profile tab
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // avatar
            const SizedBox(height: Spacing.lg),
            const CircleAvatar(
              radius: 64,
              backgroundImage: AssetImage('assets/images/bob.jpg'),
            ),
            const SizedBox(height: Spacing.lg),

            // title
            Text(
              'Master Builder 1000',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 260,
                ), // keeps things narrow
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // label/value alignment
                  children: [
                    // fields (static)
                    _FieldBlock(label: 'Full Name', value: 'Bob DaBuilder'),
                    const SizedBox(height: Spacing.lg),
                    _FieldBlock(
                      label: 'Phone Number',
                      value: '(123) - 456 - 7890',
                    ),
                    const SizedBox(height: Spacing.lg),
                    _FieldBlock(
                      label: 'Email',
                      value: 'bobdabuilder@gmail.com',
                      underline: true,
                    ),
                    const SizedBox(height: Spacing.lg),
                    _FieldBlock(label: 'Password', value: '***************'),

                    const SizedBox(height: Spacing.xl),
                  ],
                ),
              ),
            ),
            // Edit Profile button (dark pill)
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.profileEdit),
                style: ButtonStyle(
                  alignment: Alignment.center,
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                child: const Center(child: Text('Edit Profile')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool underline;
  const _FieldBlock({
    required this.label,
    required this.value,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              decoration: underline
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
