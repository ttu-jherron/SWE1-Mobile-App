import 'package:flutter/foundation.dart';
import 'asset.dart';
import 'asset_repository.dart';

class AssetStore extends ChangeNotifier {
  final AssetRepository _repo;
  AssetStore(this._repo);


  List<Asset> all() => List.unmodifiable(_repo.getAll());
  List<Asset> favorites() => all().where((a) => a.favorite == true).toList();

  Asset getById(String id) => _repo.getById(id);
  
  void toggleFavorite(String assetId) {
    final a = _repo.getById(assetId);
    a.favorite = !(a.favorite == true);
    // TODO(back-end): await api.patch('/assets/$assetId', {'favorite': a.favorite});
    notifyListeners();
  }

  void setFavorite(String assetId, bool value) {
    final a = _repo.getById(assetId);
    if (a.favorite == value) return;
    a.favorite = value;
    // TODO(back-end): await api.patch('/assets/$assetId', {'favorite': value});
    notifyListeners();
  }
}

// Simple global for now. (If you use Provider/Riverpod later, swap this out.)
final assetStore = AssetStore(assetRepository);
