import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:mobile_app/core/data/data_handler.dart';

class LifeCycleRefresher extends StatefulWidget {
  final Widget child;
  const LifeCycleRefresher({super.key, required this.child});

  @override
  State<LifeCycleRefresher> createState() => _LifeCycleRefresherState();
}

class _LifeCycleRefresherState extends State<LifeCycleRefresher> with WidgetsBindingObserver {
  Timer? _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial sync shortly after start
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshOnce());
    _startTimer(); // foreground polling
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshOnce();
      _startTimer();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    // Poll every 60s; DataHandler only hits network if cache is stale
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _refreshOnce());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _refreshOnce() async {
    if (!mounted || _running) return;
    _running = true;
    try {
      final auth = ClerkAuth.of(context);
      if (auth.user != null) {
        final dh = DataHandler(auth: auth);
        if (dh.isClerkStale) {
          await dh.clerkFetchProfile(force: true);
        }
      }
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}