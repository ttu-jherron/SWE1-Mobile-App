import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
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

// Backend-driven profile avatar with self-priming (backend only)
class ProfileAvatarBackend extends StatefulWidget {
  const ProfileAvatarBackend({super.key});

  @override
  State<ProfileAvatarBackend> createState() => _ProfileAvatarBackendState();
}

class _ProfileAvatarBackendState extends State<ProfileAvatarBackend> with WidgetsBindingObserver {
  Timer? _burstTimer;
  Timer? _slowTimer;
  int _burstStep = 0;
  DateTime? _burstStarted;

  static const List<Duration> _burstDelays = [
    Duration(seconds: 0),
    Duration(seconds: 3),
    Duration(seconds: 7),
    Duration(seconds: 15),
  ];
  static const Duration _burstMax = Duration(seconds: 60);
  static const Duration _slowPeriod = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePriming());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePriming());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      _ensurePriming();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimers();
    super.dispose();
  }

  bool _hasUser() {
    try {
      return ClerkAuth.of(context).user != null;
    } catch (_) {
      return false;
    }
  }

  bool _hasCache() {
    try {
      final dh = DataHandler.fromContext(context);
      return dh.cachedBackendProfile != null && dh.cachedBackendProfile!.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _attemptFetch() async {
    if (!_hasUser()) {
      _stopTimers();
      return;
    }
    final auth = ClerkAuth.of(context);
    final dh = DataHandler(auth: auth);
    if (dh.cachedBackendProfile != null && dh.cachedBackendProfile!.isNotEmpty) {
      _stopTimers();
      return;
    }
    try {
      await dh.backendFetchProfile(force: true).timeout(const Duration(seconds: 5));
    } catch (_) {
      // ignore; retry schedule continues
    }
    if (dh.cachedBackendProfile != null && dh.cachedBackendProfile!.isNotEmpty) {
      _stopTimers();
      if (mounted) setState(() {});
    }
  }

  void _ensurePriming() {
    if (!_hasUser()) {
      _stopTimers();
      return;
    }
    if (_hasCache()) {
      _stopTimers();
      return;
    }
    if (_burstTimer == null && _slowTimer == null) {
      _startBurst();
    }
  }

  void _startBurst() {
    _burstStarted = DateTime.now();
    _burstStep = 0;
    _scheduleNextBurst();
  }

  void _scheduleNextBurst() {
    if (!mounted) return;
    if (_burstStep >= _burstDelays.length) {
      _startSlow();
      return;
    }
    final delay = _burstDelays[_burstStep];
    _burstTimer?.cancel();
    _burstTimer = Timer(delay, () async {
      if (!mounted) return;
      final exceeded = _burstStarted != null && DateTime.now().difference(_burstStarted!) > _burstMax;
      if (exceeded) {
        _startSlow();
        return;
      }
      await _attemptFetch();
      _burstStep += 1;
      if (_hasCache()) {
        _stopTimers();
      } else {
        _scheduleNextBurst();
      }
    });
  }

  void _startSlow() {
    _burstTimer?.cancel();
    _burstTimer = null;
    if (!mounted || _hasCache()) return;
    _slowTimer?.cancel();
    _slowTimer = Timer.periodic(_slowPeriod, (_) async {
      if (!mounted || !_hasUser()) {
        _stopTimers();
        return;
      }
      if (_hasCache()) {
        _stopTimers();
        return;
      }
      await _attemptFetch();
    });
  }

  void _stopTimers() {
    _burstTimer?.cancel();
    _slowTimer?.cancel();
    _burstTimer = null;
    _slowTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final dh = DataHandler.fromContext(context);
    final hasCache = dh.cachedBackendProfile != null && dh.cachedBackendProfile!.isNotEmpty;

    // Keep priming alive as state changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePriming());

    return StreamBuilder<Map<String, dynamic>>(
      stream: dh.backendProfileStream,
      initialData: dh.cachedBackendProfile,
      builder: (context, snap) {
        final data = snap.data ?? const <String, dynamic>{};
        final imageUrl = (data['image_url'] ?? data['imageUrl']) as String?;

        if (hasCache || data.isNotEmpty) {
          // As soon as data appears, stop any timers
          _stopTimers();

          if (imageUrl == null || imageUrl.isEmpty) {
            return CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey.shade400,
              child: const Icon(Icons.person, size: 14, color: Colors.white),
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
        }

        // No cache and no stream yet: spinner (max 5s), then neutral placeholder
        return FutureBuilder<void>(
          future: Future.delayed(const Duration(seconds: 5)),
          builder: (context, waitSnap) {
            final waiting = waitSnap.connectionState == ConnectionState.waiting;
            if (waiting) {
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
            return CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey.shade400,
              child: const Icon(Icons.person, size: 14, color: Colors.white),
            );
          },
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
