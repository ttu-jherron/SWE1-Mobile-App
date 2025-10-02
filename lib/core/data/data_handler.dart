import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:http/http.dart' as http;

class DataHandler {
  // Instance deps
  final ClerkAuthState auth;
  final String baseUrl;
  final http.Client _client;

  // Use emulator base URL by default; kept in a static so static fetch can use it
  static String _globalBaseUrl = 'http://10.0.2.2:8080';

  DataHandler({required this.auth, String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _globalBaseUrl,
        _client = client ?? http.Client() {
    // Keep static base URL in sync with latest instance
    _globalBaseUrl = this.baseUrl;
    _ensureClerkSubscription(auth);
    _ensurePollingStarted();
  }

  static DataHandler fromContext(BuildContext context) {
    final auth = ClerkAuth.of(context);
    return DataHandler(auth: auth);
  }

  // ===== Caches, streams, activity/polling (unchanged) =====
  static DateTime _lastRefreshAttemptTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _refreshThreshold = Duration(minutes: 1);

  static const Duration _clerkTtl = Duration(seconds: 30);
  static Map<String, dynamic>? _cachedClerkProfile;
  static DateTime? _clerkCachedAt;

  static const Duration _backendTtl = Duration(seconds: 30);
  static Map<String, dynamic>? _cachedBackendProfile;
  static DateTime? _backendCachedAt;

  static final _clerkProfileController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get clerkProfileStream => _clerkProfileController.stream;
  Map<String, dynamic>? get cachedClerkProfile => _cachedClerkProfile;

  static final _backendProfileController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get backendProfileStream => _backendProfileController.stream;
  Map<String, dynamic>? get cachedBackendProfile => _cachedBackendProfile;

  static const Duration _pollInterval = Duration(seconds: 30);
  static const Duration _activityWindow = Duration(seconds: 30);
  static DateTime _lastActivity = DateTime.fromMillisecondsSinceEpoch(0);
  static Timer? _pollTimer;
  static Future<Map<String, dynamic>>? _ongoingBackendFetch;

  static bool _profileActive = false;

  clerk.User? get user => auth.user;
  String get clerkID => user!.id;

  // ===== Public read API =====
  void markActivity() {
    _lastActivity = DateTime.now();
  }

  void enterProfileContext() {
    _profileActive = true;
    markActivity();
  }

  void exitProfileContext() {
    _profileActive = false;
  }

  Future<Map<String, dynamic>> getProfile({bool preferCache = true, bool forceNetwork = false}) async {
    markActivity();

    final uid = user?.id;
    if (uid == null) {
      throw Exception("User not found");
    }

    if (preferCache && !forceNetwork && _cachedBackendProfile != null) {
      return _cachedBackendProfile!;
    }

    return await _refreshBackendProfileForUser(uid);
  }

  Future<Map<String, dynamic>> backendFetchProfile({bool force = false}) {
    return getProfile(preferCache: !force, forceNetwork: force);
  }

  // ===== Clerk methods =====
  Future<Map<String, dynamic>> clerkFetchProfile({bool force = false}) async {
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

  // ===== Backend fetch (uses global base URL) =====
  static Future<Map<String, dynamic>> _refreshBackendProfileForUser(String userId) async {
    if (_ongoingBackendFetch != null) {
      return await _ongoingBackendFetch!;
    }

    _ongoingBackendFetch = () async {
      try {
        final response = await http.get(
          Uri.parse("$_globalBaseUrl/users/$userId"),
          headers: {
            'Accept': 'application/json',
            'X-User-Id': userId, // required by backend
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          _updateBackendCacheIfChanged(data);
          debugPrint('DataHandler: Backend profile fetched successfully');
          return _cachedBackendProfile!;
        } else {
          debugPrint('DataHandler: Backend request failed with status: ${response.statusCode}');
          debugPrint('DataHandler: Response body: ${response.body}');
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

  static void _mergeBackendPatch(Map<String, dynamic> patch) {
    final current = _cachedBackendProfile ?? <String, dynamic>{};
    final merged = Map<String, dynamic>.from(current)..addAll(patch);
    _updateBackendCacheIfChanged(merged);
  }

  static void _emitBackend() {
    if (_cachedBackendProfile != null) {
      _backendProfileController.add(_cachedBackendProfile!);
    }
  }

  // ===== Combined helpers =====
  Future<Map<String, Map<String, dynamic>>> fetchBothDataSources({bool force = false}) async {
    try {
      final backendData = await backendFetchProfile(force: force);
      return {
        'clerk': <String, dynamic>{},
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
    return separatedData['clerk'] ?? <String, dynamic>{};
  }

  Map<String, dynamic> getBackendData(Map<String, Map<String, dynamic>> separatedData) {
    return separatedData['backend'] ?? <String, dynamic>{};
  }

  // ===== Clerk subscription =====
  static ClerkAuthState? _subscribedAuth;

  static void _ensureClerkSubscription(ClerkAuthState auth) {
    if (_subscribedAuth != null) return;
    _subscribedAuth = auth;
    _subscribedAuth!.addListener(_onClerkAuthChanged);
    _onClerkAuthChanged();
  }

  static void _onClerkAuthChanged() {
    final auth = _subscribedAuth;
    if (auth == null) return;

    final u = auth.user;
    if (u == null) {
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

  bool get isClerkStale {
    final at = _clerkCachedAt;
    if (at == null) return true;
    return DateTime.now().difference(at) > _clerkTtl;
  }

  // ===== Polling =====
  static void _ensurePollingStarted() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _onPollTick());
  }

  static Future<void> _onPollTick() async {
    final auth = _subscribedAuth;
    final u = auth?.user;
    if (u == null) return;

    if (!_profileActive) return;

    final inactive = DateTime.now().difference(_lastActivity) > _activityWindow;
    if (inactive) return;

    try {
      await _refreshBackendProfileForUser(u.id);
    } catch (_) {}
  }

  // ===== Priming (unchanged) =====
  static Timer? _primeTimer;
  static bool _isPriming = false;
  static int _primeIndex = 0;
  static DateTime? _lastPrimeStop;
  static String? _primingUserId;

  static const List<Duration> _primeSchedule = <Duration>[
    Duration(seconds: 0),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 20),
    Duration(seconds: 40),
  ];
  static const Duration _primeCooldown = Duration(minutes: 1);

  void startPrimingIfNeeded() {
    final u = auth.user;
    if (u == null) {
      _stopPriming();
      return;
    }

    if (cachedBackendProfile != null && cachedBackendProfile!.isNotEmpty) {
      _stopPriming();
      return;
    }

    if (_isPriming && _primingUserId == u.id) return;

    if (_lastPrimeStop != null &&
        DateTime.now().difference(_lastPrimeStop!) < _primeCooldown) {
      return;
    }

    _primingUserId = u.id;
    _isPriming = true;
    _primeIndex = 0;

    _primeTimer?.cancel();
    _primeTimer = Timer(_primeSchedule[_primeIndex], () => _runPrimeTick());
  }

  void _runPrimeTick() async {
    if (cachedBackendProfile != null && cachedBackendProfile!.isNotEmpty) {
      _stopPriming();
      return;
    }

    try {
      final result = await backendFetchProfile(force: true)
          .timeout(const Duration(seconds: 5), onTimeout: () => <String, dynamic>{});

      if (result.isNotEmpty ||
          (cachedBackendProfile != null && cachedBackendProfile!.isNotEmpty)) {
        _stopPriming();
        return;
      }
    } catch (_) {}

    _primeIndex += 1;
    if (_primeIndex >= _primeSchedule.length) {
      _stopPriming();
      return;
    }

    _primeTimer?.cancel();
    _primeTimer = Timer(_primeSchedule[_primeIndex], () => _runPrimeTick());
  }

  static void _stopPriming() {
    _primeTimer?.cancel();
    _primeTimer = null;
    _isPriming = false;
    _lastPrimeStop = DateTime.now();
  }

  // ===== Write API =====
  Future<void> updateUserProfile({
    required String clerkId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    // TODO Remove Username and Email from backend and transition to clerk
    String? username,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    // TODO Remove Username and Email from backend and transition to clerk
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;

    if (body.isEmpty) return;

    final uri = Uri.parse('$baseUrl/users/$clerkId');
    final res = await _client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Id': clerkId, // required by backend
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Backend update failed (${res.statusCode}): ${res.body}');
    }

    // Optimistically update cache and notify listeners
    _mergeBackendPatch(body);
  }
}