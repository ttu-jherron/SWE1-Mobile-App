import 'package:flutter/material.dart';
import '../routing.dart';
import '../colors.dart';
import 'app_header_bar.dart';
import 'app_bottom_nav.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  /// Which tab is active? 0 = Home, 1 = My Assets, 2 = Profile
  final int currentIndex;
  final bool useYellowBackground;

  const AppLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    this.useYellowBackground = false,
  });

  void _handleNavTap(BuildContext context, int i) {
    if (i == currentIndex) return;
    switch (i) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.assets, (_) => false);
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.profile, (_) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: useYellowBackground ? AppColors.sandyYellow : null,
      appBar: const AppHeaderBar(),
      body: body,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => _handleNavTap(context, i),
      ),
    );
  }
}
