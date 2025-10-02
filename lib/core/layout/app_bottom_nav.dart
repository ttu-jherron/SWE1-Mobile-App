import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import '../colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.ebonyClay),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 64,
          backgroundColor: AppColors.ebonyClay,
          indicatorColor: Colors.transparent,
          selectedIndex: currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: onTap,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.sandyYellow),
              selectedIcon: Icon(Icons.home, color: AppColors.sandyYellow),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.handyman_outlined, color: AppColors.sandyYellow),
              selectedIcon: Icon(Icons.handyman, color: AppColors.sandyYellow),
              label: 'My Assets',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: AppColors.sandyYellow),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.sandyYellow),
              label: 'Maintenance',
            ),
            // Profile avatar uses cached data; no fetching unless Profile tab is opened
            NavigationDestination(
              icon: ProfileAvatarBackend(),
              selectedIcon: ProfileAvatarBackend(),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Backend-driven profile avatar (no implicit fetch)
class ProfileAvatarBackend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dh = DataHandler.fromContext(context);
    return StreamBuilder<Map<String, dynamic>>(
      stream: dh.backendProfileStream, // will only emit when Profile is active
      initialData: dh.cachedBackendProfile,
      builder: (context, snapshot) {
        final imageUrl = (snapshot.data?['image_url'] ??
            snapshot.data?['imageUrl']) as String?;

        if (imageUrl == null || imageUrl.isEmpty) {
          return const CircleAvatar(
            radius: 12,
            backgroundImage: AssetImage('assets/images/bob.jpg'),
          );
        }

        return CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 24,
              height: 24,
              errorWidget: (context, url, error) => const CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage('assets/images/bob.jpg'),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Could replace this to make a surrounding color on the icon when selected
// selectedIcon: Container(
//   decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     border: Border.all(color: AppColors.sandyYellow, width: 2),
//   ),
//   child: CircleAvatar(
//     radius: 12,
//     backgroundImage: AssetImage('assets/images/bob.jpg'),
//     backgroundColor: Colors.transparent,
//   ),
// ),
