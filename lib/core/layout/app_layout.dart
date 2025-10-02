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
    if (i == widget.currentIndex) return;
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
        onTap: (index) {
          // Special-case: if already on the My Assets tab (index 1), always go to MyAssets list
          // This ensures ViewAsset -> tap "My Assets" goes to the list (not pop back to Home)
          if (index == widget.currentIndex && index == 1) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.myAssets, (_) => false);
            return;
          }

          // For other tabs, tapping the current tab can pop if enabled
          if (index == widget.currentIndex && widget.popOnCurrentTabTap) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
          }

          _handleNavTap(context, index);
        },
      ),
      body: widget.body,
    );
  }
}
