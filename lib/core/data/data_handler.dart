import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:http/http.dart' as http;

class DataHandler {
  final ClerkAuthState auth;

  DataHandler({required this.auth}) {
    _ensureClerkSubscription(auth);
    _ensurePollingStarted();
  }

  // Static variable to track last refresh time (shared across all instances)
  static DateTime _lastRefreshAttemptTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _refreshThreshold = Duration(minutes: 1);

  // Caching for Clerk profile (30s TTL)
  static const Duration _clerkTtl = Duration(seconds: 30);
  static Map<String, dynamic>? _cachedClerkProfile;
  static DateTime? _clerkCachedAt;

  // Caching for backend profile
  // Cache is the primary source of truth; background polling refreshes it.
  static const Duration _backendTtl = Duration(seconds: 30); // kept for reference/inspections
  static Map<String, dynamic>? _cachedBackendProfile;
  static DateTime? _backendCachedAt;

  // Streams
  static final _clerkProfileController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get clerkProfileStream => _clerkProfileController.stream;
  Map<String, dynamic>? get cachedClerkProfile => _cachedClerkProfile;

  static final _backendProfileController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get backendProfileStream => _backendProfileController.stream;

  // Expose cached backend so UI can avoid flashing placeholders
  Map<String, dynamic>? get cachedBackendProfile => _cachedBackendProfile;

  // Activity + polling
  static const Duration _pollInterval = Duration(seconds: 30);
  static const Duration _activityWindow = Duration(seconds: 30);
  static DateTime _lastActivity = DateTime.fromMillisecondsSinceEpoch(0);
  static Timer? _pollTimer;
  static Future<Map<String, dynamic>>? _ongoingBackendFetch;

  // NEW: gate backend polling to Profile context only
  static bool _profileActive = false;

  clerk.User? get user => auth.user;
  String get clerkID => user!.id;

  static DataHandler fromContext(BuildContext context) {
    final auth = ClerkAuth.of(context);
    return DataHandler(auth: auth);
  }

  // =============================================================================
  // PUBLIC API – Always use backend for reads
  // =============================================================================

  // Mark user activity manually (e.g., call from top-level navigation, screen focus, or interaction handlers)
  void markActivity() {
    _lastActivity = DateTime.now();
  }

  // NEW: enable/disable profile-driven polling window
  void enterProfileContext() {
    _profileActive = true;
    markActivity();
  }

  void exitProfileContext() {
    _profileActive = false;
  }

  // Primary read method: returns cached data, attempts to refresh if needed.
  // - preferCache: if true (default), returns cache immediately (if present).
  // - forceNetwork: if true, forces a fetch; still falls back to cache when fetch fails.
  Future<Map<String, dynamic>> getProfile({bool preferCache = true, bool forceNetwork = false}) async {
    // Reading counts as activity so background polling keeps running while user is active
    markActivity();

    final uid = user?.id;
    if (uid == null) {
      throw Exception("User not found");
    }

    if (preferCache && !forceNetwork && _cachedBackendProfile != null) {
      return _cachedBackendProfile!;
    }

    // Try to refresh; fallback to cache if fetch fails
    return await _refreshBackendProfileForUser(uid);
  }

  // Backwards-compatible name (now uses the new behavior)
  Future<Map<String, dynamic>> backendFetchProfile({bool force = false}) {
    return getProfile(preferCache: !force, forceNetwork: force);
  }

  // =============================================================================
  // CLERK METHODS - Direct Clerk operations (still used for auth/user id; updates unchanged)
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
  // BACKEND METHODS - Our backend API (centralized fetch + cache + fallback)
  // =============================================================================

  // Internal: fetch and update cache for a given user id, fallback to cached data on failure.
  static Future<Map<String, dynamic>> _refreshBackendProfileForUser(String userId) async {
    // Coalesce concurrent fetches
    if (_ongoingBackendFetch != null) {
      return await _ongoingBackendFetch!;
    }

    _ongoingBackendFetch = () async {
      try {
        final response = await http.get(
          // 10.0.2.2 allows emulator to access 127.0.0.1
          Uri.parse("http://10.0.2.2:8080/users/$userId"),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          _updateBackendCacheIfChanged(data);
          debugPrint('DataHandler: Backend profile fetched successfully');
          return _cachedBackendProfile!;
        } else {
          debugPrint('DataHandler: Backend request failed with status: ${response.statusCode}');
          debugPrint('DataHandler: Response body: ${response.body}');
          // Fallback to cache when possible
          if (_cachedBackendProfile != null) {
            return _cachedBackendProfile!;
          }
          throw Exception('Failed to fetch profile: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('DataHandler: Error fetching backend profile for user $userId: $e');
        if (_cachedBackendProfile != null) {
          return _cachedBackendProfile!;
        }
        rethrow;
      } finally {
        _ongoingBackendFetch = null;
      }
    }();

    return await _ongoingBackendFetch!;
  }

  static void _updateBackendCacheIfChanged(Map<String, dynamic> newData) {
    final changed = _cachedBackendProfile == null || !mapEquals(_cachedBackendProfile!, newData);
    _cachedBackendProfile = newData;
    _backendCachedAt = DateTime.now();
    if (changed) {
      _emitBackend();
    }
  }

  static void _emitBackend() {
    if (_cachedBackendProfile != null) {
      _backendProfileController.add(_cachedBackendProfile!);
    }
  }

  // =============================================================================
  // COMBINED DATA METHODS (kept for compatibility, but backend is the source)
  // =============================================================================

  Future<Map<String, Map<String, dynamic>>> fetchBothDataSources({bool force = false}) async {
    try {
      final backendData = await backendFetchProfile(force: force);
      return {
        'clerk': <String, dynamic>{}, // Clerk data no longer used for retrieval
        'backend': backendData,
      };
    } catch (e) {
      debugPrint('DataHandler: Error fetching backend data: $e');
      return {
        'clerk': <String, dynamic>{},
        'backend': _cachedBackendProfile ?? <String, dynamic>{},
      };
    }
  }

  Map<String, dynamic> getClerkData(Map<String, Map<String, dynamic>> separatedData) {
    // Clerk retrieval is no longer used; keep empty for compatibility
    return separatedData['clerk'] ?? <String, dynamic>{};
  }

  Map<String, dynamic> getBackendData(Map<String, Map<String, dynamic>> separatedData) {
    return separatedData['backend'] ?? <String, dynamic>{};
  }

  // =============================================================================
  // Clerk subscription (still used to know current user id; also clears cache on sign-out)
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
      // Clear caches on sign-out
      _cachedClerkProfile = <String, dynamic>{};
      _clerkCachedAt = DateTime.now();

      _cachedBackendProfile = null;
      _backendCachedAt = null;

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

  // =============================================================================
  // Polling control (30s) – only if there is activity in the last 30s
  // =============================================================================

  static void _ensurePollingStarted() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _onPollTick());
  }

  static Future<void> _onPollTick() async {
    final auth = _subscribedAuth;
    final u = auth?.user;
    if (u == null) return;

    // Only poll when Profile is active AND the user was active in the last 30s
    if (!_profileActive) return;

    final inactive = DateTime.now().difference(_lastActivity) > _activityWindow;
    if (inactive) {
      return;
    }

    try {
      await _refreshBackendProfileForUser(u.id);
    } catch (e) {
      // Fallback to cache is handled in _refreshBackendProfileForUser
    }
  }
}