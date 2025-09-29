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
            NavigationDestination(
              icon: Icon(Icons.calendar_month, color: AppColors.sandyYellow),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.sandyYellow),
              label: 'Maintenance',
            ),
            NavigationDestination(
              icon: _buildProfileAvatar(profileImageUrl),
              selectedIcon: _buildProfileAvatar(profileImageUrl),
            // Profile tab with dynamic image
            const NavigationDestination(
              icon: _ProfileAvatar(),
              selectedIcon: _ProfileAvatar(),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for the profile avatar
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final dataHandler = DataHandler.fromContext(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: dataHandler.clerkFetchProfile(),
      builder: (context, snapshot) {
        final profileImageUrl = snapshot.data?['imageUrl'];

        if (profileImageUrl == null || profileImageUrl.isEmpty) {
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
              imageUrl: profileImageUrl,
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
