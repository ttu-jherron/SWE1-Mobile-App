import 'dart:convert';
import 'dart:async'; // <-- add

import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:http/http.dart' as http;

class DataHandler {
  final ClerkAuthState auth;

  DataHandler({required this.auth}) {
    _ensureClerkSubscription(auth);
  }

  // Static variable to track last refresh time (shared across all instances)
  static DateTime _lastRefreshAttemptTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _refreshThreshold = Duration(minutes: 1);

  // Caching for Clerk profile (30s TTL)
  static const Duration _clerkTtl = Duration(seconds: 30);
  static Map<String, dynamic>? _cachedClerkProfile;
  static DateTime? _clerkCachedAt;

  // Caching for backend profile (30s TTL)
  static const Duration _backendTtl = Duration(seconds: 30);
  static Map<String, dynamic>? _cachedBackendProfile;
  static DateTime? _backendCachedAt;

  // Stream to push Clerk profile updates (e.g. when image/username changes)
  static final _clerkProfileController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get clerkProfileStream => _clerkProfileController.stream;
  Map<String, dynamic>? get cachedClerkProfile => _cachedClerkProfile;

  // Expose cached backend so UI can avoid flashing placeholders
  Map<String, dynamic>? get cachedBackendProfile => _cachedBackendProfile;

  clerk.User? get user => auth.user;
  String get clerkID => user!.id;

  static DataHandler fromContext(BuildContext context) {
    final auth = ClerkAuth.of(context);
    return DataHandler(auth: auth);
  }

  // =============================================================================
  // CLERK METHODS - Direct Clerk operations
  // =============================================================================

  Future<Map<String, dynamic>> clerkFetchProfile({bool force = false}) async {
    // Use cache if available and fresh
    final now = DateTime.now();
    final fresh = _clerkCachedAt != null && now.difference(_clerkCachedAt!) < _clerkTtl;
    if (!force && _cachedClerkProfile != null && fresh) {
      return _cachedClerkProfile!;
    }

    if (user == null) {
      _cachedClerkProfile = <String, dynamic>{};
      _clerkCachedAt = DateTime.now();
      return _cachedClerkProfile!;
    }

    // Refresh Clerk client/environment, but rate limit it
    await clerkRefreshUserData();

    final map = {
      'id': user!.id,
      'email': user!.email,
      'username': user!.username,
      'firstName': user!.firstName,
      'lastName': user!.lastName,
      'imageUrl': user!.imageUrl,
    };

    final changed = _didClerkProfileChange(_cachedClerkProfile, map);
    _cachedClerkProfile = map;
    _clerkCachedAt = DateTime.now();

    if (changed) {
      _emitClerk();
    }

    return map;
  }

  Future<void> clerkRefreshUserData() async {
    final now = DateTime.now();
    if (now.difference(_lastRefreshAttemptTime) < _refreshThreshold) {
      return;
    }
    try {
      _lastRefreshAttemptTime = now;
      await auth.refreshClient();
      await auth.refreshEnvironment();
      debugPrint('DataHandler: Refreshed client and environment');
    } catch (e) {
      debugPrint('DataHandler: Error refreshing user data: $e');
    }
  }

  // =============================================================================
  // BACKEND METHODS - Our backend API
  // =============================================================================

  Future<Map<String, dynamic>> backendFetchProfile({bool force = false}) async {
    // Use cache if available and fresh
    final now = DateTime.now();
    final fresh = _backendCachedAt != null && now.difference(_backendCachedAt!) < _backendTtl;
    if (!force && _cachedBackendProfile != null && fresh) {
      return _cachedBackendProfile!;
    }

    if (user == null) {
      throw Exception("User not found");
    }
    try {
      final response = await http.get(
        // 10.0.2.2 allows emulator to access 127.0.0.1
        Uri.parse("http://10.0.2.2:8080/users/${user!.id}")
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _cachedBackendProfile = data;
        _backendCachedAt = DateTime.now();
        debugPrint('DataHandler: Backend profile fetched successfully');
        return data;
      } else {
        debugPrint('DataHandler: Backend request failed with status: ${response.statusCode}');
        debugPrint('DataHandler: Response body: ${response.body}');
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DataHandler: Error fetching backend profile for user ${user!.id}: $e');
      rethrow;
    }
  }

  // =============================================================================
  // COMBINED DATA METHODS
  // =============================================================================

  Future<Map<String, Map<String, dynamic>>> fetchBothDataSources({bool force = false}) async {
    try {
      final clerkData = await clerkFetchProfile(force: force);

      try {
        final backendData = await backendFetchProfile(force: force);

        return {
          'clerk': clerkData,
          'backend': backendData,
        };
      } catch (backendError) {
        debugPrint('DataHandler: Backend unavailable, returning clerk data only: $backendError');
        return {
          'clerk': clerkData,
          'backend': <String, dynamic>{},
        };
      }
    } catch (clerkError) {
      debugPrint('DataHandler: Error fetching clerk data: $clerkError');
      return {
        'clerk': <String, dynamic>{},
        'backend': <String, dynamic>{},
      };
    }
  }

  Map<String, dynamic> getClerkData(Map<String, Map<String, dynamic>> separatedData) {
    return separatedData['clerk'] ?? <String, dynamic>{};
  }

  Map<String, dynamic> getBackendData(Map<String, Map<String, dynamic>> separatedData) {
    return separatedData['backend'] ?? <String, dynamic>{};
  }

  // =============================================================================
  // Clerk subscription (simulated webhook → update cache/stream on changes)
  // =============================================================================

  static ClerkAuthState? _subscribedAuth;

  static void _ensureClerkSubscription(ClerkAuthState auth) {
    if (_subscribedAuth != null) return;
    _subscribedAuth = auth;
    _subscribedAuth!.addListener(_onClerkAuthChanged);
    // Emit immediately if we already have a user (initial render)
    _onClerkAuthChanged();
  }

  static void _onClerkAuthChanged() {
    final auth = _subscribedAuth;
    if (auth == null) return;

    final u = auth.user;
    if (u == null) {
      _cachedClerkProfile = <String, dynamic>{};
      _clerkCachedAt = DateTime.now();
      _emitClerk();
      return;
    }

    final map = {
      'id': u.id,
      'email': u.email,
      'username': u.username,
      'firstName': u.firstName,
      'lastName': u.lastName,
      'imageUrl': u.imageUrl,
    };

    final changed = _didClerkProfileChange(_cachedClerkProfile, map);
    if (changed) {
      _cachedClerkProfile = map;
      _clerkCachedAt = DateTime.now();
      _emitClerk();
    }
  }

  static bool _didClerkProfileChange(Map<String, dynamic>? oldMap, Map<String, dynamic> newMap) {
    if (oldMap == null) return true;
    return oldMap['imageUrl'] != newMap['imageUrl'] ||
           oldMap['username'] != newMap['username'] ||
           oldMap['email']    != newMap['email'];
  }

  static void _emitClerk() {
    if (_cachedClerkProfile != null) {
      _clerkProfileController.add(_cachedClerkProfile!);
    }
  }

  // Add a public staleness check so callers avoid unnecessary refreshes
  bool get isClerkStale {
    final at = _clerkCachedAt;
    if (at == null) return true;
    return DateTime.now().difference(at) > _clerkTtl;
  }
}