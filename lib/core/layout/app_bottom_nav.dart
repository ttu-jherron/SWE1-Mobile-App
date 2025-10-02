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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.sandyYellow),
              selectedIcon: Icon(Icons.home, color: AppColors.sandyYellow),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.handyman_outlined, color: AppColors.sandyYellow),
              selectedIcon: Icon(Icons.handyman, color: AppColors.sandyYellow),
              label: 'My Assets',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: AppColors.sandyYellow),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.sandyYellow),
              label: 'Maintenance',
            ),
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
  const ProfileAvatarBackend({super.key});

  @override
  Widget build(BuildContext context) {
    final dh = DataHandler.fromContext(context);

    return StreamBuilder<Map<String, dynamic>>(
      stream: dh.backendProfileStream,
      initialData: dh.cachedBackendProfile,
      builder: (context, snapshot) {
        final hasCache = dh.cachedBackendProfile != null && dh.cachedBackendProfile!.isNotEmpty;
        final imageUrl = (snapshot.data?['image_url'] ?? snapshot.data?['imageUrl']) as String?;

        // Show a small spinner while waiting for the very first fetch and we have no cache
        final isInitialLoading = !hasCache && (snapshot.data == null || snapshot.data!.isEmpty);

        if (isInitialLoading) {
          return CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade400,
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.sandyYellow),
              ),
            ),
          );
        }

        // If no image, show a neutral grey placeholder (no bob.png)
        if (imageUrl == null || imageUrl.isEmpty) {
          return CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade400,
            child: const Icon(Icons.person, size: 14, color: Colors.white),
          );
        }

        // Normal image
        return CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 24,
              height: 24,
              // Keep a neutral grey placeholder while the network image loads
              placeholder: (context, _) => Container(
                width: 24,
                height: 24,
                color: Colors.grey.shade300,
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade400,
                child: const Icon(Icons.person, size: 14, color: Colors.white),
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
