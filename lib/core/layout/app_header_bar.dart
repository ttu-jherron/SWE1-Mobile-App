import 'package:flutter/material.dart';
import '../colors.dart';
import '../constants.dart';

class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(136);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(color: AppColors.ebonyClay),
      child: const Text(
        'HE',
        style: TextStyle(
          color: AppColors.sandyYellow,
          fontWeight: FontWeight.w900,
          fontSize: 64,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
