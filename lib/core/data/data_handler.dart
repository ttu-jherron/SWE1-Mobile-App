import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/assets/data/asset.dart';
import 'package:mobile_app/features/maintenance/data/maintenance_entry.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DataHandler {
  // Instance deps
  final ClerkAuthState auth;
  final String baseUrl;
  final http.Client _client;

  // Global base URL (kept in sync by latest instance)
  static final String _globalDevUrl = 'http://10.0.2.2:8080';
  static final String _globalProdUrl = 'https://api.thehippoexchange.com';
  static String _globalBaseUrl = "";
  static bool _useProd = true; // environment flag

  static String get _defaultBaseUrl =>
      _useProd ? _globalProdUrl : _globalDevUrl;

  // NEW: normalize helper (ensures scheme + strips trailing slash)
  static String _normalizeBase(String raw) {
    var v = raw.trim();
    if (v.isEmpty) return _defaultBaseUrl;
    if (!v.startsWith('http://') && !v.startsWith('https://')) {
      v = 'https://$v'; // default to https
    }
    if (v.endsWith('/')) v = v.substring(0, v.length - 1);
    return v;
  }

  static void setEnvironment({required bool production}) {
    _useProd = production;
    _globalBaseUrl = _normalizeBase(
      production ? _globalProdUrl : _globalDevUrl,
    );
  }

  DataHandler({required this.auth, String? baseUrl, http.Client? client})
    : baseUrl = _normalizeBase(
        baseUrl ??
            (_globalBaseUrl.isNotEmpty ? _globalBaseUrl : _defaultBaseUrl),
      ),
      _client = client ?? http.Client() {
    // Keep global in sync & normalized
    _globalBaseUrl = this.baseUrl;
    _ensureClerkSubscription(auth);
    _ensurePollingStarted();
  }

  // Convenience to build a full Uri safely
  static Uri _buildUri(String path) {
    final base = _normalizeBase(
      _globalBaseUrl.isNotEmpty ? _globalBaseUrl : _defaultBaseUrl,
    );
    final cleanPath = path.startsWith('/')
        ? path
        : '/$path'; // ensure single slash join
    return Uri.parse('$base$cleanPath');
  }

  static DataHandler fromContext(BuildContext context) {
    final auth = ClerkAuth.of(context);
    return DataHandler(auth: auth);
  }

  // ================== Profile Caches / Streams ==================
  static DateTime _lastRefreshAttemptTime = DateTime.fromMillisecondsSinceEpoch(
    0,
  );
  static const Duration _refreshThreshold = Duration(minutes: 1);

  // Clerk
  static const Duration _clerkTtl = Duration(seconds: 30);
  static Map<String, dynamic>? _cachedClerkProfile;
  static DateTime? _clerkCachedAt;
  static final _clerkProfileController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get clerkProfileStream =>
      _clerkProfileController.stream;
  Map<String, dynamic>? get cachedClerkProfile => _cachedClerkProfile;

  // Backend profile
  static const Duration _backendTtl = Duration(seconds: 30);
  static Map<String, dynamic>? _cachedBackendProfile;
  static DateTime? _backendCachedAt;
  static final _backendProfileController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get backendProfileStream =>
      _backendProfileController.stream;
  Map<String, dynamic>? get cachedBackendProfile => _cachedBackendProfile;
  static Future<Map<String, dynamic>>? _ongoingBackendFetch;

  Future<void> clearAllCache() async {
    // 1. Clear in-memory static caches
    _cachedClerkProfile = null;
    _clerkCachedAt = null;
    _cachedBackendProfile = null;
    _backendCachedAt = null;
    _cachedAssets = null;
    _assetsFetchedAt = null;

    // 2. Clear image cache from CachedNetworkImage
    await DefaultCacheManager().emptyCache();

    // 3. Notify stream listeners that data is gone
    if (!_clerkProfileController.isClosed) {
      _clerkProfileController.add(<String, dynamic>{});
    }
    if (!_backendProfileController.isClosed) {
      _backendProfileController.add(<String, dynamic>{});
    }
    if (!_assetsController.isClosed) {
      _assetsController.add(<Asset>[]);
    }

    debugPrint('DataHandler: All caches cleared.');
  }

  // Activity / polling
  static const Duration _pollInterval = Duration(seconds: 30);
  static const Duration _activityWindow = Duration(seconds: 30);
  static DateTime _lastActivity = DateTime.fromMillisecondsSinceEpoch(0);
  static Timer? _pollTimer;
  static bool _profileActive = false;

  // Clerk user
  clerk.User? get user => auth.user;
  String get clerkID => user!.id;

  // ================== Assets Cache ==================
  static const Duration _assetsSoftTtl = Duration(seconds: 60);
  static const Duration _assetsHardTtl = Duration(minutes: 10);
  static List<Asset>? _cachedAssets; // CHANGED
  static DateTime? _assetsFetchedAt;
  static Future<List<Asset>>? _inFlightAssets; // CHANGED
  static final _assetsController =
      StreamController<List<Asset>>.broadcast(); // CHANGED

  Stream<List<Asset>> get assetsStream => _assetsController.stream; // CHANGED
  List<Asset>? get cachedAssets => _cachedAssets; // CHANGED

  bool _assetsSoftExpired() {
    if (_assetsFetchedAt == null) return true;
    return DateTime.now().difference(_assetsFetchedAt!) > _assetsSoftTtl;
  }

  bool _assetsHardExpired() {
    if (_assetsFetchedAt == null) return true;
    return DateTime.now().difference(_assetsFetchedAt!) > _assetsHardTtl;
  }

  void invalidateAssets() {
    _assetsFetchedAt = null;
  }

  void _emitAssets() {
    if (_cachedAssets != null) {
      _assetsController.add(
        List<Asset>.unmodifiable(_cachedAssets!),
      ); // CHANGED
    }
  }

  bool _listShallowEquals(List<Asset>? a, List<Asset>? b) {
    // CHANGED
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final ai = a[i];
      final bi = b[i];
      if (ai.id != bi.id) return false;
      // Optional: deeper comparison if needed (hash or toJson string compare)
    }
    return true;
  }

  Future<List<Asset>> _fetchAssetsForUser(String userId) {
    if (_inFlightAssets != null) return _inFlightAssets!;
    final uri = _buildUri('/assets'); // CHANGED

    _inFlightAssets = () async {
      try {
        final res = await _client
            .get(
              uri,
              headers: {'Accept': 'application/json', 'X-User-Id': userId},
            )
            .timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is List) {
            final list = decoded
                .map<Asset>(
                  (e) => Asset.fromJson(
                    Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                  ),
                )
                .toList();
            final changed = !_listShallowEquals(_cachedAssets, list);
            _cachedAssets = list;
            _assetsFetchedAt = DateTime.now();
            if (changed) _emitAssets();
          } else {
            debugPrint('DataHandler: Assets payload not a list (${res.body})');
          }
        } else if (res.statusCode == 401 || res.statusCode == 403) {
          debugPrint(
            'DataHandler: Unauthorized assets fetch (${res.statusCode})',
          );
          // Do not clear cache; rethrow only if no cache
          if (_cachedAssets == null) {
            throw Exception('Unauthorized');
          }
        } else {
          debugPrint('DataHandler: Assets fetch failed ${res.statusCode}');
          if (_cachedAssets == null) {
            throw Exception('Failed to fetch assets: ${res.statusCode}');
          }
        }
      } catch (e) {
        debugPrint('DataHandler: Assets fetch error $e (uri=$uri)');
        if (_cachedAssets == null) rethrow;
      } finally {
        _inFlightAssets = null;
      }
      return _cachedAssets ?? <Asset>[];
    }();
    return _inFlightAssets!;
  }

  Future<List<Asset>> getAssets({
    // CHANGED
    bool force = false,
    bool staleOk = true,
  }) async {
    markActivity();
    final uid = user?.id;
    if (uid == null) throw Exception('User not authenticated');

    if (!force && _cachedAssets != null) {
      final softExpired = _assetsSoftExpired();
      final hardExpired = _assetsHardExpired();

      if (!softExpired) {
        return _cachedAssets!;
      }
      if (softExpired && !hardExpired && staleOk) {
        _fetchAssetsForUser(uid); // background refresh
        return _cachedAssets!;
      }
    }
    return await _fetchAssetsForUser(uid);
  }

  void _mergeOrInsertAsset(Map<String, dynamic> assetJson) {
    // CHANGED
    final asset = Asset.fromJson(assetJson);
    final list = (_cachedAssets ?? <Asset>[]).toList();
    final idx = list.indexWhere((e) => e.id == asset.id);
    if (idx >= 0) {
      list[idx] = asset;
    } else {
      list.insert(0, asset);
    }
    _cachedAssets = list;
    _assetsFetchedAt = DateTime.now();
    _emitAssets();
  }

  // ================== Activity / Context ==================
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

  // ================== Backend Profile (public) ==================
  Future<Map<String, dynamic>> getProfile({
    bool preferCache = true,
    bool forceNetwork = false,
  }) async {
    markActivity();
    final uid = user?.id;
    if (uid == null) {
      throw Exception("User not found");
    }
    if (preferCache && !forceNetwork && _cachedBackendProfile != null) {
      final fresh =
          _backendCachedAt != null &&
          DateTime.now().difference(_backendCachedAt!) < _backendTtl;
      if (fresh) return _cachedBackendProfile!;
    }
    return await _refreshBackendProfileForUser(uid);
  }

  Future<Map<String, dynamic>> backendFetchProfile({bool force = false}) {
    return getProfile(preferCache: !force, forceNetwork: force);
  }

  // ================== Clerk Profile ==================
  Future<Map<String, dynamic>> clerkFetchProfile({bool force = false}) async {
    final now = DateTime.now();
    final fresh =
        _clerkCachedAt != null && now.difference(_clerkCachedAt!) < _clerkTtl;
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
    if (changed) _emitClerk();
    return map;
  }

  Future<void> clerkRefreshUserData() async {
    final now = DateTime.now();
    if (now.difference(_lastRefreshAttemptTime) < _refreshThreshold) return;
    try {
      _lastRefreshAttemptTime = now;
      await auth.refreshClient();
      await auth.refreshEnvironment();
      debugPrint('DataHandler: Refreshed clerk client/environment');
    } catch (e) {
      debugPrint('DataHandler: Clerk refresh error: $e');
    }
  }

  // ================== Backend Profile Fetch ==================
  static Future<Map<String, dynamic>> _refreshBackendProfileForUser(
    String userId,
  ) async {
    if (_ongoingBackendFetch != null) return await _ongoingBackendFetch!;

    final uri = _buildUri('/users/$userId'); // CHANGED

    _ongoingBackendFetch = () async {
      try {
        final response = await http
            .get(
              uri,
              headers: {'Accept': 'application/json', 'X-User-Id': userId},
            )
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          _updateBackendCacheIfChanged(data);
          return _cachedBackendProfile!;
        } else {
          debugPrint(
            'DataHandler: Backend status ${response.statusCode} (uri=$uri)',
          );
          if (_cachedBackendProfile != null) return _cachedBackendProfile!;
          throw Exception('Failed profile fetch: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint(
          'DataHandler: Backend profile error $userId -> $e (uri=$uri)',
        );
        if (_cachedBackendProfile != null) return _cachedBackendProfile!;
        rethrow;
      } finally {
        _ongoingBackendFetch = null;
      }
    }();

    return await _ongoingBackendFetch!;
  }

  static void _updateBackendCacheIfChanged(Map<String, dynamic> newData) {
    final changed =
        _cachedBackendProfile == null ||
        !mapEquals(_cachedBackendProfile!, newData);
    _cachedBackendProfile = newData;
    _backendCachedAt = DateTime.now();
    if (changed) _emitBackend();
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

  // ================== Combined Helpers ==================
  Future<Map<String, Map<String, dynamic>>> fetchBothDataSources({
    bool force = false,
  }) async {
    try {
      final backendData = await backendFetchProfile(force: force);
      return {'clerk': <String, dynamic>{}, 'backend': backendData};
    } catch (e) {
      debugPrint('DataHandler: Combined fetch error: $e');
      return {
        'clerk': <String, dynamic>{},
        'backend': _cachedBackendProfile ?? <String, dynamic>{},
      };
    }
  }

  Map<String, dynamic> getClerkData(
    Map<String, Map<String, dynamic>> separatedData,
  ) {
    return separatedData['clerk'] ?? <String, dynamic>{};
  }

  Map<String, dynamic> getBackendData(
    Map<String, Map<String, dynamic>> separatedData,
  ) {
    return separatedData['backend'] ?? <String, dynamic>{};
  }

  // ================== Clerk Subscription ==================
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

  static bool _didClerkProfileChange(
    Map<String, dynamic>? oldMap,
    Map<String, dynamic> newMap,
  ) {
    if (oldMap == null) return true;
    return oldMap['imageUrl'] != newMap['imageUrl'] ||
        oldMap['username'] != newMap['username'] ||
        oldMap['email'] != newMap['email'];
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

  // ================== Polling ==================
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

  // ================== Priming ==================
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
      final result = await backendFetchProfile(force: true).timeout(
        const Duration(seconds: 5),
        onTimeout: () => <String, dynamic>{},
      );

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

  // ================== Write API ==================
  Future<void> updateUserProfile({
    required String clerkId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? username,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (body.isEmpty) return;

    final uri = Uri.parse('$baseUrl/users/$clerkId');
    final res = await _client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Id': clerkId,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Backend update failed (${res.statusCode}): ${res.body}');
    }

    _mergeBackendPatch(body);
  }

  Future<void> addAsset({
    required String itemName,
    required String brandName,
    required String category,
    required DateTime purchaseDate,
    required double purchaseCost,
    required String currentLocation,
    required List<String> images,
    required String conditionDescription,
    required String status,
    required bool favorite,
  }) async {
    final clerkId = user?.id;
    if (clerkId == null) {
      throw Exception("User not authenticated");
    }

    final uri = Uri.parse('$baseUrl/assets');
    final body = {
      "itemName": itemName,
      "brandName": brandName,
      "category": category,
      "purchaseDate": purchaseDate.toIso8601String(),
      "purchaseCost": purchaseCost,
      "currentLocation": currentLocation,
      "images": images,
      "conditionDescription": conditionDescription,
      "ownerUserId": clerkId,
      "status": status,
      "favorite": favorite,
    };

    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Id': clerkId,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('AddAsset failed: ${res.statusCode} - ${res.body}');
      throw Exception('Failed to add asset: ${res.statusCode}');
    }

    debugPrint('Asset added successfully: ${res.body}');

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        _mergeOrInsertAsset(decoded); // now uses Asset
      }
    } catch (_) {}

    // Optionally refresh related profile data (if backend updates counts, etc.)
    try {
      await _refreshBackendProfileForUser(clerkId);
    } catch (e) {
      // Don't treat profile refresh failures as a hard error for asset creation.
      debugPrint(
        'DataHandler: Ignored profile refresh error after addAsset: $e',
      );
    }
  }

  Future<void> updateAsset({
    required String id,
    required String itemName,
    required String brandName,
    required String category,
    required DateTime purchaseDate,
    required double purchaseCost,
    required String currentLocation,
    required List<String> images,
    required String conditionDescription,
    required String status,
    required bool favorite,
  }) async {
    final clerkId = user?.id;
    if (clerkId == null) {
      throw Exception("User not authenticated");
    }

    final uri = Uri.parse('$baseUrl/assets/$id');
    final body = {
      "itemName": itemName,
      "brandName": brandName,
      "category": category,
      "purchaseDate": purchaseDate.toIso8601String(),
      "purchaseCost": purchaseCost,
      "currentLocation": currentLocation,
      "images": images,
      "conditionDescription": conditionDescription,
      "ownerUserId": clerkId,
      "status": status,
      "favorite": favorite,
    };

    http.Response res;
    try {
      res = await _client.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': clerkId,
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint('UpdateAsset network error: $e');
      throw Exception('Network error while updating asset: $e');
    }

    if (res.statusCode == 404) {
      // Try a PATCH fallback for servers that prefer PATCH for updates
      try {
        final patchRes = await _client.patch(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-User-Id': clerkId,
          },
          body: jsonEncode(body),
        );
        res = patchRes;
      } catch (e) {
        debugPrint('UpdateAsset PATCH fallback network error: $e');
      }
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('UpdateAsset failed: ${res.statusCode} - ${res.body}');
      throw Exception(
        'Failed to update asset: ${res.statusCode} - ${res.body}',
      );
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        _mergeOrInsertAsset(decoded);
      }
    } catch (_) {}

    // Optionally refresh related profile data
    try {
      await _refreshBackendProfileForUser(clerkId);
    } catch (e) {
      // Don't surface profile refresh failures as an update failure.
      debugPrint(
        'DataHandler: Ignored profile refresh error after updateAsset: $e',
      );
    }
  }

  // ================== Maintenance Cache ==================
  static const Duration _maintenanceSoftTtl = Duration(seconds: 60);
  static const Duration _maintenanceHardTtl = Duration(minutes: 10);
  static List<MaintenanceEntry>? _cachedMaintenance;
  static DateTime? _maintenanceFetchedAt;
  static Future<List<MaintenanceEntry>>? _inFlightMaintenance;
  static final _maintenanceController =
      StreamController<List<MaintenanceEntry>>.broadcast();

  Stream<List<MaintenanceEntry>> get maintenanceStream => _maintenanceController.stream;
  List<MaintenanceEntry>? get cachedMaintenance => _cachedMaintenance;

  bool _maintenanceSoftExpired() {
    if (_maintenanceFetchedAt == null) return true;
    return DateTime.now().difference(_maintenanceFetchedAt!) > _maintenanceSoftTtl;
  }

  bool _maintenanceHardExpired() {
    if (_maintenanceFetchedAt == null) return true;
    return DateTime.now().difference(_maintenanceFetchedAt!) > _maintenanceHardTtl;
  }

  void invalidateMaintenance() {
    _maintenanceFetchedAt = null;
  }

  void _emitMaintenance() {
    if (_cachedMaintenance != null) {
      _maintenanceController.add(
        List<MaintenanceEntry>.unmodifiable(_cachedMaintenance!),
      );
    }
  }

  Future<List<MaintenanceEntry>> _fetchMaintenanceForUser(String userId) {
    if (_inFlightMaintenance != null) return _inFlightMaintenance!;
    final uri = _buildUri('/maintenance');

    _inFlightMaintenance = () async {
      try {
        final res = await _client
            .get(
              uri,
              headers: {'Accept': 'application/json', 'X-User-Id': userId},
            )
            .timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is List) {
            final list = decoded
                .map<MaintenanceEntry>(
                  (e) => MaintenanceEntry.fromJson(
                    Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                  ),
                )
                .toList();
            final changed = !_listShallowEqualsMaintenance(_cachedMaintenance, list);
            _cachedMaintenance = list;
            _maintenanceFetchedAt = DateTime.now();
            if (changed) _emitMaintenance();
          } else {
            debugPrint('DataHandler: Maintenance payload not a list (${res.body})');
          }
        } else if (res.statusCode == 401 || res.statusCode == 403) {
          debugPrint(
            'DataHandler: Unauthorized maintenance fetch (${res.statusCode})',
          );
          if (_cachedMaintenance == null) {
            throw Exception('Unauthorized');
          }
        } else {
          debugPrint('DataHandler: Maintenance fetch failed ${res.statusCode}');
          if (_cachedMaintenance == null) {
            throw Exception('Failed to fetch maintenance: ${res.statusCode}');
          }
        }
      } catch (e) {
        debugPrint('DataHandler: Maintenance fetch error $e (uri=$uri)');
        if (_cachedMaintenance == null) rethrow;
      } finally {
        _inFlightMaintenance = null;
      }
      return _cachedMaintenance ?? <MaintenanceEntry>[];
    }();
    return _inFlightMaintenance!;
  }

  bool _listShallowEqualsMaintenance(List<MaintenanceEntry>? a, List<MaintenanceEntry>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final ai = a[i];
      final bi = b[i];
      if (ai.id != bi.id) return false;
    }
    return true;
  }

  Future<List<MaintenanceEntry>> getMaintenance({
    bool force = false,
    bool staleOk = true,
  }) async {
    markActivity();
    final uid = user?.id;
    if (uid == null) throw Exception('User not authenticated');

    if (!force && _cachedMaintenance != null) {
      final softExpired = _maintenanceSoftExpired();
      final hardExpired = _maintenanceHardExpired();

      if (!softExpired) {
        return _cachedMaintenance!;
      }
      if (softExpired && !hardExpired && staleOk) {
        _fetchMaintenanceForUser(uid);
        return _cachedMaintenance!;
      }
    }
    return await _fetchMaintenanceForUser(uid);
  }

  Future<void> addMaintenance(MaintenanceEntry entry) async {
    final clerkId = user?.id;
    if (clerkId == null) {
      debugPrint('CMD: [addMaintenance] User not authenticated');
      print('CMD: [addMaintenance] User not authenticated');
      throw Exception("User not authenticated");
    }

    // According to API docs, creating a maintenance record requires the assetId
    // to be supplied in the URL: POST /assets/{assetId}/maintenance
    final assetId = entry.assetId;
    final uri = _buildUri('/assets/$assetId/maintenance');

    // The API expects the assetId in the path, not in the body. Remove id and assetId
    // from the serialized body when creating.
    final bodyMap = Map<String, dynamic>.from(entry.toJson())..remove('assetId')..remove('id');

    debugPrint('CMD: [addMaintenance] POST $uri with body: $bodyMap');
    print('CMD: [addMaintenance] POST $uri with body: $bodyMap');

    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Id': clerkId,
      },
      body: jsonEncode(bodyMap),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('CMD: [addMaintenance] failed: ${res.statusCode} - ${res.body}');
      print('CMD: [addMaintenance] failed: ${res.statusCode} - ${res.body}');
      throw Exception('Failed to add maintenance: ${res.statusCode}');
    }

    debugPrint('CMD: [addMaintenance] Maintenance added successfully: ${res.body}');
    print('CMD: [addMaintenance] Maintenance added successfully: ${res.body}');

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        _mergeOrInsertMaintenance(MaintenanceEntry.fromJson(decoded));
        debugPrint('CMD: [addMaintenance] Inserted new maintenance entry into cache.');
        print('CMD: [addMaintenance] Inserted new maintenance entry into cache.');
      }
    } catch (e) {
      debugPrint('CMD: [addMaintenance] Error decoding response: $e');
      print('CMD: [addMaintenance] Error decoding response: $e');
    }

    // Force a refresh of all maintenance from backend to ensure UI is up to date
    try {
      debugPrint('CMD: [addMaintenance] Forcing maintenance refresh after add.');
      print('CMD: [addMaintenance] Forcing maintenance refresh after add.');
      await getMaintenance(force: true, staleOk: false);
    } catch (e) {
      debugPrint('CMD: [addMaintenance] Error during maintenance refresh: $e');
      print('CMD: [addMaintenance] Error during maintenance refresh: $e');
    }

    try {
      await _refreshBackendProfileForUser(clerkId);
    } catch (e) {
      debugPrint(
        'DataHandler: Ignored profile refresh error after addMaintenance: $e',
      );
    }
  }

  /// Update an existing maintenance record using PATCH.
  /// The API exposes PATCH /maintenance/{maintenanceId} for partial updates.
  Future<void> updateMaintenance({
    required String maintenanceId,
    required Map<String, dynamic> patch,
  }) async {
    final clerkId = user?.id;
    if (clerkId == null) {
      debugPrint('CMD: [updateMaintenance] User not authenticated');
      print('CMD: [updateMaintenance] User not authenticated');
      throw Exception('User not authenticated');
    }

    final uri = _buildUri('/maintenance/$maintenanceId');

    debugPrint('CMD: [updateMaintenance] PATCH $uri with patch: $patch');
    print('CMD: [updateMaintenance] PATCH $uri with patch: $patch');

    final res = await _client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-User-Id': clerkId,
      },
      body: jsonEncode(patch),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('CMD: [updateMaintenance] failed: ${res.statusCode} - ${res.body}');
      print('CMD: [updateMaintenance] failed: ${res.statusCode} - ${res.body}');
      throw Exception('Failed to update maintenance: ${res.statusCode}');
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        _mergeOrInsertMaintenance(MaintenanceEntry.fromJson(decoded));
        debugPrint('CMD: [updateMaintenance] Updated maintenance entry in cache.');
        print('CMD: [updateMaintenance] Updated maintenance entry in cache.');
      }
    } catch (e) {
      debugPrint('CMD: [updateMaintenance] Error decoding response: $e');
      print('CMD: [updateMaintenance] Error decoding response: $e');
    }
  }

  /// Fetch maintenance records for a specific asset: GET /assets/{assetId}/maintenance
  Future<List<MaintenanceEntry>> getMaintenanceForAsset(String assetId,
      {bool force = false, bool staleOk = true}) async {
    markActivity();
    final uid = user?.id;
    if (uid == null) throw Exception('User not authenticated');

    // Shortcut: if we already have maintenance cached and not forced, reuse it.
    if (!force && _cachedMaintenance != null) {
      final softExpired = _maintenanceSoftExpired();
      final hardExpired = _maintenanceHardExpired();

      if (!softExpired) return _cachedMaintenance!;
      if (softExpired && !hardExpired && staleOk) {
        // fire-and-forget refresh
        _fetchMaintenanceForAsset(uid, assetId);
        return _cachedMaintenance!;
      }
    }

    return await _fetchMaintenanceForAsset(uid, assetId);
  }

  Future<List<MaintenanceEntry>> _fetchMaintenanceForAsset(String userId, String assetId) {
    // Not deduping in-flight per-asset for simplicity; reuse the global in-flight when present.
    if (_inFlightMaintenance != null) return _inFlightMaintenance!;

    final uri = _buildUri('/assets/$assetId/maintenance');

    _inFlightMaintenance = () async {
      try {
        final res = await _client
            .get(
              uri,
              headers: {'Accept': 'application/json', 'X-User-Id': userId},
            )
            .timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is List) {
            final list = decoded
                .map<MaintenanceEntry>(
                  (e) => MaintenanceEntry.fromJson(
                    Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                  ),
                )
                .toList();
            final changed = !_listShallowEqualsMaintenance(_cachedMaintenance, list);
            _cachedMaintenance = list;
            _maintenanceFetchedAt = DateTime.now();
            if (changed) _emitMaintenance();
          } else {
            debugPrint('DataHandler: Maintenance payload not a list (${res.body})');
          }
        } else if (res.statusCode == 401 || res.statusCode == 403) {
          debugPrint(
            'DataHandler: Unauthorized maintenance fetch (${res.statusCode})',
          );
          if (_cachedMaintenance == null) {
            throw Exception('Unauthorized');
          }
        } else {
          debugPrint('DataHandler: Maintenance fetch failed ${res.statusCode}');
          if (_cachedMaintenance == null) {
            throw Exception('Failed to fetch maintenance: ${res.statusCode}');
          }
        }
      } catch (e) {
        debugPrint('DataHandler: Maintenance fetch error $e (uri=$uri)');
        if (_cachedMaintenance == null) rethrow;
      } finally {
        _inFlightMaintenance = null;
      }
      return _cachedMaintenance ?? <MaintenanceEntry>[];
    }();

    return _inFlightMaintenance!;
  }

  void _mergeOrInsertMaintenance(MaintenanceEntry entry) {
    final list = (_cachedMaintenance ?? <MaintenanceEntry>[]).toList();
    final idx = list.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      list[idx] = entry;
    } else {
      list.insert(0, entry);
    }
    _cachedMaintenance = list;
    _maintenanceFetchedAt = DateTime.now();
    _emitMaintenance();
  }
}
