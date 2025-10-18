import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import 'asset.dart';

class AssetStore extends ChangeNotifier {
  DataHandler? _dh;
  StreamSubscription<List<Asset>>? _sub;

  List<Asset> _assets = const [];

  // Call this once from a widget (e.g., in didChangeDependencies)
  void bind(BuildContext context) {
    if (_dh != null) return;
    final dh = DataHandler.fromContext(context);
    _dh = dh;

    _sub = dh.assetsStream.listen((list) {
      _assets = list;
      notifyListeners();
    });

    // Initial fetch
    dh.getAssets();
  }

  Future<void> refresh({bool force = false}) async {
    await _dh?.getAssets(force: force);
  }

  List<Asset> all() => List.unmodifiable(_assets);

  List<Asset> favorites() =>
      _assets.where((a) => a.favorite == true).toList(growable: false);

  Asset getById(String id) {
    final idx = _assets.indexWhere((a) => a.id == id);
    if (idx == -1) {
      // Try to refresh in the background to reduce future misses
      unawaited(_dh?.getAssets(force: true));
      throw StateError('Asset not found: $id');
    }
    return _assets[idx];
  }

  void toggleFavorite(String assetId) {
    final idx = _assets.indexWhere((a) => a.id == assetId);
    if (idx == -1) {
      unawaited(_dh?.getAssets(force: true));
      throw StateError('Asset not found: $assetId');
    }
    final newValue = !(_assets[idx].favorite == true);
    setFavorite(assetId, newValue);
  }

  void setFavorite(String assetId, bool value) async {
    final idx = _assets.indexWhere((a) => a.id == assetId);
    if (idx == -1) {
      unawaited(_dh?.getAssets(force: true));
      throw StateError('Asset not found: $assetId');
    }
    _assets[idx].favorite = value;
    notifyListeners();
    await _dh?.markAssetFavorite(getById(assetId), value);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// Simple global for now.
final assetStore = AssetStore();
