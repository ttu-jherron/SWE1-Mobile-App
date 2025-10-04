import 'package:flutter/material.dart';
import '../routing.dart';
import '../colors.dart';
import 'app_header_bar.dart';
import 'app_bottom_nav.dart';

class AppLayout extends StatefulWidget {
  final int currentIndex;
  final Widget body;
  final bool popOnCurrentTabTap;
  final bool useYellowBackground;

  const AppLayout({
    super.key,
    required this.currentIndex,
    required this.body,
    this.popOnCurrentTabTap = false,
    this.useYellowBackground = false,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  void _handleNavTap(BuildContext context, int i) {
    // If user taps the current tab, optionally pop (used by View Asset and Edit Profile)
    if (i == widget.currentIndex) {
      if (widget.popOnCurrentTabTap) {
        Navigator.of(context).maybePop();
      }
      return;
    }
    switch (i) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.myAssets, (_) => false);
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.maintenance, (_) => false);
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.profile, (_) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.useYellowBackground ? AppColors.sandyYellow : null,
      appBar: const AppHeaderBar(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.currentIndex,
        onTap: (i) => _handleNavTap(context, i),
      ),
      body: widget.body,
    );
  }
}
