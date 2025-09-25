import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import the package
import 'package:mobile_app/app.dart';
import 'package:mobile_app/core/colors.dart';
import 'package:mobile_app/features/profile/presentation/clerk_data_handler.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);
    
    // Play loading circle when signing out
    if (auth.user == null) {
      return AppLayout(
        currentIndex: 3,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final clerkDataHandler = ClerkDataHandler(auth: auth);
    // TODO dont let this be a band-aid fix, this is probably too many clerk requests
    final userData = clerkDataHandler.fetchProfile();
    final String? profileImageUrl = userData['imageUrl'];

    final String nameFromData = "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
    final String fullName = nameFromData.isEmpty ? "ERROR: No full name available" : nameFromData;

    final String username = userData['username'] ?? 'ERROR: No username available';
    final String email = userData['email'] ?? 'ERROR: No email available';

    return AppLayout(
      currentIndex: 3, // Profile tab
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
                child: _buildProfileAvatar(profileImageUrl)
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // title
            Text(
              username,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            //const SizedBox(height: Spacing.lg),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 260,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DEMO_FLAG INCOMPLETE FEATURE
                    /*
                    // fields (static)
                    FieldBlock(
                      label: 'Full Name',
                      value: fullName
                    ),
                    const SizedBox(height: Spacing.lg),
                    FieldBlock(
                      label: 'Phone Number',
                      value: 'No access to backend',
                      //value: userData['phoneNumber'],
                    ),
                    */
                    const SizedBox(height: Spacing.lg),
                    FieldBlock(
                      label: 'Email',
                      value: email,
                      underline: true,
                    ),
                    /*
                    const SizedBox(height: Spacing.lg),
                    FieldBlock(label: 'Password', value: '***************'),

                    const SizedBox(height: Spacing.xl),
                    */
                  ],
                ),
              ),
            ),
            // DEMO_FLAG INCOMPLETE FEATURE
            /*
            // Edit Profile button (dark pill)
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.profileEdit),
                style: ButtonStyle(
                  alignment: Alignment.center,
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                child: const Center(child: Text('Edit Profile')),
              ),
            ),
            */
            // Sign Out button (dark pill)
            // DEMO_FLAG NEW FEATURE
            SizedBox(height: 32),
            SizedBox(
              width: 120,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                await auth.signOut();
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
                style: ButtonStyle(
                  alignment: Alignment.center,
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                child: const Center(child: Text('Sign Out')),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileAvatar(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Fallback to the static asset if no URL is available
      return const CircleAvatar(
        radius: 12,
        backgroundImage: AssetImage('assets/images/tools.jpg'),
      );
    }

    // Use CachedNetworkImage with the user's profile image
    return CircleAvatar(
      radius: 64,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/tools.jpg'),
          ),
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
    super.key, // Add super.key parameter
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