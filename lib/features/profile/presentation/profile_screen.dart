import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/colors.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:mobile_app/core/widgets/loading_screen.dart';
import 'package:mobile_app/app.dart'; // for routeObserver

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  Future<Map<String, dynamic>>? _backendFuture;
  Future<void>? _splashFuture;

  Timer? _retryTimer;
  int _retryAttempts = 0;
  bool _subscribed = false; // avoid double-subscribing RouteObserver

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure we’re in profile context even on first mount
      try {
        final dh = DataHandler.fromContext(context);
        dh.enterProfileContext();
      } catch (_) {}
      _resetAndStartFetch();
      _startRetryLoop(); // also start bounded retry on first entry (no cache/offline cases)
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_subscribed && route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    // Leave profile context when this widget is disposed
    try {
      DataHandler.fromContext(context).exitProfileContext();
    } catch (_) {}
    _stopRetryLoop();
    if (_subscribed) {
      routeObserver.unsubscribe(this);
      _subscribed = false;
    }
    super.dispose();
  }

  // Entered Profile tab
  @override
  void didPush() {
    _enterAndFetch();
  }

  // Returned to Profile tab
  @override
  void didPopNext() {
    _enterAndFetch();
  }

  // Navigating away from Profile tab
  @override
  void didPushNext() {
    _leaveProfile();
  }

  // Popping Profile tab
  @override
  void didPop() {
    _leaveProfile();
  }

  void _enterAndFetch() {
    final dh = DataHandler.fromContext(context);
    dh.enterProfileContext();
    _resetAndStartFetch();
    _startRetryLoop();
  }

  void _leaveProfile() {
    DataHandler.fromContext(context).exitProfileContext();
    _stopRetryLoop();
  }

  void _resetAndStartFetch() {
    _backendFuture = null;
    _splashFuture = null;
    _startFetch();
  }

  void _startFetch() {
    final auth = ClerkAuth.of(context);
    if (auth.user == null) return;
    final dh = DataHandler(auth: auth);

    // 100ms splash per navigation
    _splashFuture = Future.delayed(const Duration(milliseconds: 100));

    // Force a backend fetch; fallback to cache on timeout
    setState(() {
      _backendFuture = dh
          .backendFetchProfile(force: true)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => dh.cachedBackendProfile ?? <String, dynamic>{},
          );
    });
  }

  // Bounded retry loop to handle offline->online while Profile is open.
  // IMPORTANT: rebuild the Future each attempt so FutureBuilder updates.
  void _startRetryLoop() {
    _stopRetryLoop();
    final dh = DataHandler.fromContext(context);
    final noCache = dh.cachedBackendProfile == null || dh.cachedBackendProfile!.isEmpty;
    if (!noCache) return;

    // Try immediately once and rebuild the future
    setState(() {
      _backendFuture = dh
          .backendFetchProfile(force: true)
          .timeout(const Duration(seconds: 5), onTimeout: () => dh.cachedBackendProfile ?? <String, dynamic>{});
    });

    _retryAttempts = 0;
    _retryTimer = Timer.periodic(const Duration(seconds: 5), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      final handler = DataHandler.fromContext(context);
      final hasCache = handler.cachedBackendProfile != null && handler.cachedBackendProfile!.isNotEmpty;
      if (hasCache) {
        t.cancel();
        return;
      }
      _retryAttempts += 1;
      if (_retryAttempts > 6) { // ~30s total, then stop
        t.cancel();
        return;
      }
      // Rebuild the future each attempt
      setState(() {
        _backendFuture = handler
            .backendFetchProfile(force: true)
            .timeout(const Duration(seconds: 5), onTimeout: () => handler.cachedBackendProfile ?? <String, dynamic>{});
      });
    });
  }

  void _stopRetryLoop() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempts = 0;
  }

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

    // Ensure builders have futures even on first build
    _splashFuture ??= Future.delayed(const Duration(milliseconds: 100));
    _backendFuture ??= dataHandler
        .backendFetchProfile(force: true)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => dataHandler.cachedBackendProfile ?? <String, dynamic>{},
        );

    return AppLayout(
      currentIndex: 3,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: dataHandler.backendProfileStream,
        initialData: dataHandler.cachedBackendProfile,
        builder: (context, streamSnap) {
          final streamData = streamSnap.data ?? <String, dynamic>{};

          return FutureBuilder<void>(
            future: _splashFuture,
            builder: (context, splashSnap) {
              final inSplash = splashSnap.connectionState == ConnectionState.waiting;

              if (inSplash) {
                return const LoadingScreen();
              }

              return FutureBuilder<Map<String, dynamic>>(
                future: _backendFuture,
                builder: (context, backendSnap) {
                  final futureData = backendSnap.data ?? <String, dynamic>{};
                  final effective =
                      streamData.isNotEmpty ? streamData
                      : futureData.isNotEmpty ? futureData
                      : (dataHandler.cachedBackendProfile ?? <String, dynamic>{});

                  final String? profileImageUrl = effective['image_url'] ?? effective['imageUrl'];
                  final String email = effective['email'] ?? effective['Email'] ?? 'No Email';
                  final String username = effective['username'] ?? email;

                  final String firstName = effective['first_name'] ?? effective['firstName'] ?? '';
                  final String lastName = effective['last_name'] ?? effective['lastName'] ?? '';
                  final String fullName = "$firstName $lastName".trim();
                  final String displayFullName = fullName.isEmpty ? "No access to backend" : fullName;
                  final String phoneNumber =
                      effective['phone_number'] ?? effective['phoneNumber'] ?? 'No access to backend';

                  final bool avatarLoading =
                      backendSnap.connectionState == ConnectionState.waiting &&
                      streamData.isEmpty &&
                      (dataHandler.cachedBackendProfile == null ||
                       dataHandler.cachedBackendProfile!.isEmpty);

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
                            child: _buildProfileAvatar(
                              profileImageUrl,
                              loading: avatarLoading,
                            ),
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

  Widget _buildProfileAvatar(String? imageUrl, {bool loading = false}) {
    // While fetching with no data yet: show a spinner in a neutral grey circle
    if (loading) {
      return Container(
        width: 128,
        height: 128,
        color: Colors.grey.shade300,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    // If we have an image URL, load it with a simple grey placeholder
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: 128,
        height: 128,
        placeholder: (context, _) => Container(
          width: 128,
          height: 128,
          color: Colors.grey.shade300,
        ),
        errorWidget: (context, url, error) => Container(
          width: 128,
          height: 128,
          color: Colors.grey.shade400,
          child: const Icon(Icons.person, size: 48, color: Colors.white),
        ),
      );
    }

    // No image: neutral grey placeholder
    return Container(
      width: 128,
      height: 128,
      color: Colors.grey.shade400,
      child: const Icon(Icons.person, size: 48, color: Colors.white),
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