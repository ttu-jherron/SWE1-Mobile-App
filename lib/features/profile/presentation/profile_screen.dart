import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/colors.dart';
import 'package:mobile_app/core/data/data_handler.dart';
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
    
    final dataHandler = DataHandler(auth: auth);

    return AppLayout(
      currentIndex: 3,
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: dataHandler.fetchBothDataSources(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Separate data
          final separatedData = snapshot.data ?? {};
          final clerkData = dataHandler.getClerkData(separatedData);
          final backendData = dataHandler.getBackendData(separatedData);
          
          // Extract data from clerk
          final String? profileImageUrl = clerkData['imageUrl'];
          final String email = clerkData['email'] ?? 'No Email';
          final String username = clerkData['username'] ?? clerkData['email'] ?? 'No Username';
          
          // Extract data from backend
          final String firstName = backendData['firstName'] ?? '';
          final String lastName = backendData['lastName'] ?? '';
          final String fullName = "$firstName $lastName".trim();
          final String displayFullName = fullName.isEmpty ? "No access to backend" : fullName;
          final String phoneNumber = backendData['phone'] ?? 'No access to backend';
          
          return SingleChildScrollView(
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
                    child: _buildProfileAvatar(profileImageUrl),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  username,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.lg),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldBlock(label: 'Full Name', value: displayFullName),
                        const SizedBox(height: Spacing.lg),
                        _FieldBlock(
                          label: 'Phone Number',
                          value: phoneNumber,
                        ),
                        const SizedBox(height: Spacing.lg),
                        _FieldBlock(
                          label: 'Email',
                          value: email,
                          underline: true,
                        ),
                        const SizedBox(height: Spacing.lg),
                        const _FieldBlock(label: 'Password', value: '***************'),
                        const SizedBox(height: Spacing.xl),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.profileEdit),
                    style: ButtonStyle(
                      alignment: Alignment.center,
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    child: const Center(child: Text('Edit Profile')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 64,
        backgroundImage: AssetImage('assets/images/tools.jpg'),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: 128,
      height: 128,
      errorWidget: (context, url, error) => const CircleAvatar(
        radius: 64,
        backgroundImage: AssetImage('assets/images/tools.jpg'),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool underline;
  
  const _FieldBlock({
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