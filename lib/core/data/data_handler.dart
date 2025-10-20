import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/assets/data/asset.dart';
import 'package:mobile_app/features/maintenance/data/maintenance_entry.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        // Always use dev URL if _useProd is false
        _useProd
            ? (baseUrl ?? (_globalBaseUrl.isNotEmpty ? _globalBaseUrl : _globalProdUrl))
            : _globalDevUrl,
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

  // Warm caches right after sign-in
  static bool _prefetchInFlight = false;
  static DateTime? _lastPrefetchAt;
  static const Duration _prefetchCooldown = Duration(seconds: 30);

  static Future<void> _prefetchForCurrentUser() async {
    final auth = _subscribedAuth;
    final u = auth?.user;
    if (auth == null || u == null) return;

    final now = DateTime.now();
    if (_prefetchInFlight) return;
    if (_lastPrefetchAt != null &&
        now.difference(_lastPrefetchAt!) < _prefetchCooldown) {
      return;
    }

    _prefetchInFlight = true;
    try {
      final dh = DataHandler(auth: auth);
      final tasks = <Future>[];

      if (_cachedAssets == null) {
        tasks.add(dh._fetchAssetsForUser(u.id));
      }
      if (_cachedMaintenance == null) {
        tasks.add(dh._fetchMaintenanceForUser(u.id));
      }

      if (tasks.isNotEmpty) {
        await Future.wait(tasks).timeout(const Duration(seconds: 8));
      }
    } catch (_) {
      // ignore prefetch errors
    } finally {
      _lastPrefetchAt = DateTime.now();
      _prefetchInFlight = false;
    }
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

  Future<void> clearAllCache() async {
    // 1. Clear in-memory static caches
    _cachedClerkProfile = null;
    _clerkCachedAt = null;
    _cachedAssets = null;
    _assetsFetchedAt = null;

    // 2. Clear image cache from CachedNetworkImage
    await DefaultCacheManager().emptyCache();

    // 3. Notify stream listeners that data is gone
    if (!_clerkProfileController.isClosed) {
      _clerkProfileController.add(<String, dynamic>{});
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
            // final changed = !_listShallowEquals(_cachedAssets, list); // not needed
            _cachedAssets = list;
            _assetsFetchedAt = DateTime.now();
            _emitAssets(); // always emit so UI gets field updates
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
    // Ignore invalid payloads (prevents a blank asset from being inserted)
    final rawId = assetJson['id'];
    if (rawId == null || (rawId is String && rawId.trim().isEmpty)) {
      debugPrint('DataHandler: Ignoring asset merge without valid id: $assetJson');
      return;
    }

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

  Future<void> markAssetFavorite(Asset asset, bool value) async {
    markActivity();
    final userId = user?.id;
    if (userId == null) throw Exception('User not authenticated');

    final uri = _buildUri("/assets/${asset.id}");
    try {
      final res = await _client
          .patch(
            uri,
            headers: {
              'Accept': '*/*',
              'Content-Type': 'application/json',
              'X-User-Id': userId,
            },
            body: value ? 'true' : 'false',
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        // Try to merge if a valid asset is returned; otherwise refresh
        try {
          final decoded = jsonDecode(res.body);
          Map<String, dynamic>? assetMap;

          if (decoded is Map<String, dynamic>) {
            if (decoded['id'] != null && decoded['id'].toString().isNotEmpty) {
              assetMap = decoded;
            } else if (decoded['asset'] is Map &&
                (decoded['asset']['id']?.toString().isNotEmpty ?? false)) {
              assetMap = Map<String, dynamic>.from(decoded['asset']);
            }
          }

          if (assetMap != null) {
            _mergeOrInsertAsset(assetMap);
          } else {
            debugPrint('DataHandler: PATCH returned no asset payload, refreshing list...');
            await _fetchAssetsForUser(userId);
          }
        } catch (e) {
          debugPrint('DataHandler: Favorite decode error $e, refreshing list...');
          await _fetchAssetsForUser(userId);
        }
        debugPrint('DataHandler: Asset Favorite success');
      } else if (res.statusCode == 204) {
        // No content: refresh to reflect server state
        await _fetchAssetsForUser(userId);
        debugPrint('DataHandler: Asset Favorite success (204)');
      } else {
        debugPrint('DataHandler: Favorite patch failed ${res.statusCode} - ${res.body}');
        throw Exception('Favorite patch failed: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('DataHandler: Asset Favorite error $e (uri=$uri)');
      rethrow;
    }
  }

  // Helper to remove an asset locally and update the stream (List-based)
  void _removeAssetById(String id) {
    final originalLength = _cachedAssets?.length;
    _cachedAssets?.removeWhere((asset) => asset.id == id);
    
    // Only update the stream if something was actually removed
    if (_cachedAssets!.length < originalLength!) {
      _assetsController.add(_cachedAssets!); 
    }
  }

  Future<String?> _getClerkUserId() async {
    final auth = _subscribedAuth;
    final u = auth?.user;
    return u?.id;
  }

  // Public method to delete the asset on the backend 
  Future<void> deleteAsset(String assetId) async {
    // Use the authentication helper
    final clerkId = await _getClerkUserId();
    if (clerkId == null) {
      throw Exception('User not authenticated for asset deletion.');
    }

    final uri = Uri.parse('$_globalBaseUrl/assets/$assetId');

    http.Response res;
    try {
      res = await _client.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': clerkId,
        },
      );
    } catch (e) {
      debugPrint('DeleteAsset network error: $e');
      throw Exception('Network error while deleting asset: $e');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('DeleteAsset failed: ${res.statusCode} - ${res.body}');
      throw Exception(
        'Failed to delete asset $assetId}: ${res.statusCode} - ${res.body}',
      );
    }

    // On successful deletion from the backend, remove it from local cache
    _removeAssetById(assetId);

    // Refresh profile data if needed 
    try {
      // await _refreshBackendProfileForUser(clerkId);
    } catch (e) {
      debugPrint('Profile refresh failed after asset deletion: $e');
    }
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

  Future<void> clerkUpdateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? emailAddress,
    String? password, // optional only
  }) async {
    final userId = user?.id;
    if (userId == null) throw Exception('No user found');

    // Ensure we have current values to fill required fields
    Map<String, dynamic> prof = _cachedClerkProfile ?? <String, dynamic>{};
    if (prof.isEmpty) {
      prof = await clerkFetchProfile(force: true);
    }

    String get(Map m, String a, String b) =>
        (m[a] ?? m[b] ?? '').toString();

    final body = <String, dynamic>{
      'first_name': (firstName ?? get(prof, 'firstName', 'first_name')).trim(),
      'last_name': (lastName ?? get(prof, 'lastName', 'last_name')).trim(),
      'username': (username ?? get(prof, 'username', 'username')).trim(),
      'email_address': (emailAddress ?? get(prof, 'email', 'email_address')).trim(),
      if (password != null && password.trim().isNotEmpty)
        'password': password.trim(),
    };

    // Basic validation to avoid sending blanks
    for (final k in ['first_name','last_name','username','email_address']) {
      if ((body[k] as String).isEmpty) {
        throw Exception('Missing required field: $k');
      }
    }

    final uri = _buildUri('/update-clerk-user/$userId');
    http.Response res;
    try {
      res = await _client
          .patch(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-User-Id': userId,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('clerkUpdateProfileMerge network error: $e');
      rethrow;
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      debugPrint('clerkUpdateProfileMerge failed: ${res.statusCode} - ${res.body}');
      debugPrint(uri.toString());
      throw Exception('Profile update failed: ${res.statusCode}');
    }

    try {
      await clerkRefreshUserData();
      await clerkFetchProfile(force: true);
    } catch (e) {
      debugPrint('clerkUpdateProfileMerge refresh ignore: $e');
    }
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

    // Kick off background prefetch to warm caches (assets/maintenance)
    if (_cachedAssets == null || _cachedMaintenance == null) {
      Future.microtask(_prefetchForCurrentUser);
    }
  }

  // Helper to get a File from assets
  Future<File> getAssetFile(String assetPath, String filename) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  Future<void> clerkDeleteProfilePicture() async {
    // Weird bandaid fix
    // Update profile with default clerk image, then delete so it is updated locally
    // NOTE: the default profile is for production, so it wont look smooth right now
    try {
      File defaultProfilePicture = await getAssetFile('assets/images/clerkProfile.png', 'clerkProfile.png');
      await clerkUpdateProfilePicture(defaultProfilePicture);
      await auth.deleteUserImage();
      await clerkRefreshUserData();
      await clerkFetchProfile(force: true);
      _emitClerk();
    } catch (e) {
      debugPrint('clerkDeleteProfilePicture error: $e');
      rethrow;
    }
  }

  Future<void> clerkUpdateProfilePicture(File file) async {
    try {
      await auth.updateUserImage(file);
      await clerkFetchProfile(force: true);
      _emitClerk();
    } catch (e) {
      debugPrint('clerkUpdateProfilePicture error: $e');
      rethrow;
    }
  }

  // Optional: expose a manual prefetch trigger you can call from Home initState
  Future<void> prefetchAll() async {
    await _prefetchForCurrentUser();
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
  }

  // ================== Write API ==================

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

    // Convert status string to integer enum for backend
    // Backend expects: 0=Active, 1=Inactive, 2=Maintenance, 3=Retired
    int statusCode;
    switch (status.toLowerCase()) {
      case 'active':
        statusCode = 0;
        break;
      case 'inactive':
        statusCode = 1;
        break;
      case 'maintenance':
        statusCode = 2;
        break;
      case 'retired':
        statusCode = 3;
        break;
      default:
        statusCode = 0; // Default to Active
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
      "status": statusCode, // Changed from status string to integer
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
      final errorBody = res.body.isNotEmpty ? res.body : 'No error message';
      debugPrint('AddAsset failed: ${res.statusCode}');
      debugPrint('Request body: ${jsonEncode(body)}');
      debugPrint('Response body: $errorBody');
      throw Exception('Failed to add asset: ${res.statusCode} - $errorBody');
    }

    debugPrint('Asset added successfully: ${res.body}');
    await getAssets(force: true);

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        _mergeOrInsertAsset(decoded); // now uses Asset
      }
    } catch (_) {}
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

    // Convert status string to integer enum for backend
    // Backend expects: 0=Active, 1=Inactive, 2=Maintenance, 3=Retired
    int statusCode;
    switch (status.toLowerCase()) {
      case 'active':
        statusCode = 0;
        break;
      case 'inactive':
        statusCode = 1;
        break;
      case 'maintenance':
        statusCode = 2;
        break;
      case 'retired':
        statusCode = 3;
        break;
      default:
        statusCode = 0; // Default to Active
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
      "status": statusCode, // Changed from status string to integer
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
      final errorBody = res.body.isNotEmpty ? res.body : 'No error message';
      debugPrint('UpdateAsset failed: ${res.statusCode}');
      debugPrint('Request body: ${jsonEncode(body)}');
      debugPrint('Response body: $errorBody');
      throw Exception('Failed to update asset: ${res.statusCode} - $errorBody');
    }

    var merged = false;
    try {
      // Try to merge if backend returned an asset payload
      if (res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          _mergeOrInsertAsset(decoded);
          merged = true;
        } else if (decoded is Map &&
            decoded['asset'] is Map<String, dynamic>) {
          _mergeOrInsertAsset(Map<String, dynamic>.from(decoded['asset']));
          merged = true;
        }
      }
    } catch (_) {
      // fall through to refresh
    }

    if (!merged) {
      // No usable payload (e.g., 204 or empty/unknown format) -> refresh list
      debugPrint('UpdateAsset: no mergeable payload, refreshing assets...');
      await _fetchAssetsForUser(clerkId);
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
                .map<MaintenanceEntry?>((e) {
                  try { return MaintenanceEntry.fromJson(e as Map<String, dynamic>); }
                  catch (err) { debugPrint('Skip bad maintenance item: $err'); return null; }
                })
                .whereType<MaintenanceEntry>()
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
                .map<MaintenanceEntry?>((e) {
                  try { return MaintenanceEntry.fromJson(e as Map<String, dynamic>); }
                  catch (err) { debugPrint('Skip bad maintenance item: $err'); return null; }
                })
                .whereType<MaintenanceEntry>()
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

  static const String _lastOverdueCheckKey = 'last_overdue_check_date';

  /// Returns true if the check should run today (i.e., it's a new day)
  static Future<bool> shouldRunOverdueCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRun = prefs.getString(_lastOverdueCheckKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (lastRun == todayStr) return false;
    return true;
  }

  /// Call this after running the overdue check
  static Future<void> markOverdueCheckRan() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    await prefs.setString(_lastOverdueCheckKey, todayStr);
  }

  /// Update maintenance statuses for overdue tasks
  Future<void> updateOverdueMaintenanceStatuses() async {
    final now = DateTime.now();
    final List<MaintenanceEntry> entries = cachedMaintenance ?? [];
    bool changed = false;

    for (final entry in entries) {
      if (!entry.isCompleted && entry.maintenanceDueDate.isBefore(DateTime(now.year, now.month, now.day))) {
        if (entry.maintenanceStatus != 'Overdue') {
          await updateMaintenance(
            maintenanceId: entry.id,
            patch: {'maintenanceStatus': 'Overdue'},
          );
          changed = true;
        }
      } else if (!entry.isCompleted && entry.maintenanceDueDate.isAfter(DateTime(now.year, now.month, now.day - 1))) {
        // Optionally, reset status if not overdue
        if (entry.maintenanceStatus == 'Overdue') {
          await updateMaintenance(
            maintenanceId: entry.id,
            patch: {'maintenanceStatus': 'Pending'},
          );
          changed = true;
        }
      }
    }
    if (changed) {
      await getMaintenance(force: true);
    }
  }
}