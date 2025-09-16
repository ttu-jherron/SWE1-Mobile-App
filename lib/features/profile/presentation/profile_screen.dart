import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import the package
import 'package:mobile_app/app.dart';
import 'package:mobile_app/features/profile/presentation/clerk_data_handler.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Schedule a post-frame callback to fetch data after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // Unsubscribe from route changes
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this page
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      final handler = ClerkDataHandler.fromContext(context);
      await handler.refreshUserData(context);
      // Add a small delay to ensure network operations complete
      await Future.delayed(const Duration(milliseconds: 300));
      // Force UI rebuild with fresh data
      if (mounted) {
        setState(() {});
        debugPrint('Profile screen refreshed with latest user data');
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always get a fresh reference to the user object
    final user = ClerkAuth.of(context).user;
    
    // Create data handler and force fetch the latest profile data
    final clerkDataHandler = ClerkDataHandler(user: user);
    final userData = clerkDataHandler.fetchProfile(forceRefresh: true);

    final String nameFromData = "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
    final String fullName = nameFromData.isEmpty ? "No access to backend" : nameFromData;

    return AppLayout(
      currentIndex: 2, // Profile tab
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: Spacing.lg),
            CircleAvatar(
              radius: 64,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userData['imageUrl'] ?? '',
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 64, color: Colors.grey),
                  fit: BoxFit.cover,
                  width: 128,
                  height: 128,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // title
            Text(
              userData['username'],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 260,
                ), // keeps things narrow
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // label/value alignment
                  children: [
                    // fields (static)
                    FieldBlock(label: 'Full Name', value: fullName),
                    const SizedBox(height: Spacing.lg),
                    FieldBlock(
                      label: 'Phone Number',
                      value: 'No access to backend',
                      //value: userData['phoneNumber'],
                    ),
                    const SizedBox(height: Spacing.lg),
                    FieldBlock(
                      label: 'Email',
                      value: userData['email'],
                      underline: true,
                    ),
                    const SizedBox(height: Spacing.lg),
                    FieldBlock(label: 'Password', value: '***************'),

                    const SizedBox(height: Spacing.xl),
                  ],
                ),
              ),
            ),
            // Edit Profile button (dark pill)
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.profileEdit),
                style: ButtonStyle(
                  alignment: Alignment.center,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                child: const Center(child: Text('Edit Profile')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool underline;
  const FieldBlock({
    super.key, 
    required this.label,
    required this.value,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              decoration: underline
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
