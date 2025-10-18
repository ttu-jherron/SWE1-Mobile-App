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
  final bool navigateToTabRootOnCurrentTap; // NEW

  const AppLayout({
    super.key,
    required this.currentIndex,
    required this.body,
    this.popOnCurrentTabTap = false,
    this.useYellowBackground = false,
    this.navigateToTabRootOnCurrentTap = false, // NEW
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  String _routeForIndex(int i) {
    switch (i) {
      case 0:
        return AppRoutes.home;
      case 1:
        return AppRoutes.myAssets;
      case 2:
        return AppRoutes.maintenance;
      case 3:
        return AppRoutes.profile;
      default:
        return AppRoutes.home;
    }
  }

  void _handleNavTap(BuildContext context, int i) {
    final target = _routeForIndex(i);
    final route = ModalRoute.of(context);
    final currentName = route?.settings.name;
    final hasArgs = route?.settings.arguments != null;

    // Consider we are on a subpage if:
    // - current route name differs from the tab root OR
    // - the route has arguments (typical for detail/edit pages) OR
    // - the navigator can pop (we're deeper than the tab root)
    final onSubRoute =
        (currentName != null && currentName != target) ||
        hasArgs ||
        Navigator.of(context).canPop();

    // If user taps the current tab...
    if (i == widget.currentIndex) {
      if (widget.navigateToTabRootOnCurrentTap || onSubRoute) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(target, (_) => false);
        return;
      }
      if (widget.popOnCurrentTabTap) {
        Navigator.of(context).maybePop();
      }
      return;
    }

    // Different tab tapped: always go to that tab's root via root navigator
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(target, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.useYellowBackground
          ? AppColors.sandyYellow
          : null,
      appBar: const AppHeaderBar(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.currentIndex,
        onTap: (i) => _handleNavTap(context, i),
      ),
      body: widget.body,
    );
  }
}
