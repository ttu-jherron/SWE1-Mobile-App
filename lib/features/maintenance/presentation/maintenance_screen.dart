import 'package:flutter/material.dart';
import '../../../core/constants.dart';
//import '../../../core/colors.dart';
//import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';




class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 2, // Maintenance tab
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.lg,
        ),
        child: 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Maintenance",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          )
      )
    );
  }
}