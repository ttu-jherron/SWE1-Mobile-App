import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/colors.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:mobile_app/core/widgets/loading_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);

    if (auth.user == null) {
      return AppLayout(
        currentIndex: 3,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dataHandler = DataHandler(auth: auth);

    return AppLayout(
      currentIndex: 3,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: dataHandler.clerkProfileStream,
        initialData: dataHandler.cachedClerkProfile,
        builder: (context, clerkSnap) {
          final clerkData = clerkSnap.data ?? <String, dynamic>{};

          // Stage 1: always show a short 200ms loader
          return FutureBuilder<void>(
            future: Future.delayed(const Duration(milliseconds: 200)),
            builder: (context, delaySnap) {
              final stillInSplash = delaySnap.connectionState == ConnectionState.waiting;

              // Stage 2: kick off backend fetch (max 5s), but never show full-screen loader again.
              return FutureBuilder<Map<String, dynamic>>(
                initialData: dataHandler.cachedBackendProfile,
                future: dataHandler
                    .backendFetchProfile() // cached for 30s
                    .timeout(
                      const Duration(seconds: 5),
                      onTimeout: () => dataHandler.cachedBackendProfile ?? <String, dynamic>{},
                    ),
                builder: (context, backendSnap) {
                  // If within the 200ms splash window, show loader and avoid flicker.
                  if (stillInSplash) {
                    return const LoadingScreen();
                  }

                  // After 200ms, render with cached (if any) and update when fetch completes (<=5s).
                  final backendData = backendSnap.data ?? <String, dynamic>{};

                  final String? profileImageUrl = clerkData['imageUrl'];
                  final String email = clerkData['email'] ?? 'No Email';
                  final String username =
                      clerkData['username'] ?? clerkData['email'] ?? 'No Username';

                  final String firstName = backendData['firstName'] ?? '';
                  final String lastName = backendData['lastName'] ?? '';
                  final String fullName = "$firstName $lastName".trim();
                  final String displayFullName =
                      fullName.isEmpty ? "No access to backend" : fullName;
                  final String phoneNumber =
                      backendData['phone'] ?? 'No access to backend';

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
                          child: ClipOval(child: _buildProfileAvatar(profileImageUrl)),
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
                                _FieldBlock(label: 'Phone Number', value: phoneNumber),
                                const SizedBox(height: Spacing.lg),
                                _FieldBlock(label: 'Email', value: email, underline: true),
                                const SizedBox(height: Spacing.lg),
                                const _FieldBlock(label: 'Password', value: '***************'),
                                const SizedBox(height: Spacing.xl),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 160,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.profileEdit),
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            child: const Center(child: Text('Edit Profile')),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 120,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await auth.signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                              }
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                            child: const Center(child: Text('Sign Out')),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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