import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/features/profile/presentation/clerk_data_handler.dart';
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
    // Get user profile image from ClerkDataHandler
    final clerkDataHandler = ClerkDataHandler.fromContext(context);
    final userData = clerkDataHandler.fetchProfile();
    final String? profileImageUrl = userData['imageUrl'];
    clerkDataHandler.refreshUserData(context);

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
            // Profile tab with dynamic image
            NavigationDestination(
              icon: _buildProfileAvatar(profileImageUrl),
              selectedIcon: _buildProfileAvatar(profileImageUrl),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the profile avatar
  Widget _buildProfileAvatar(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Fallback to the static asset if no URL is available
      return const CircleAvatar(
        radius: 12,
        backgroundImage: AssetImage('assets/images/bob.jpg'),
      );
    }

    // Use CachedNetworkImage with the user's profile image
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
