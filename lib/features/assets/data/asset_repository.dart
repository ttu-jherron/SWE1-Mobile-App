import 'asset.dart';

/// Burner in-memory repo. Swap for a real API later.
class AssetRepository {
  // Fake store
  final Map<String, Asset> _items = {
    'asset_001': Asset(
      id: 'asset_001',
      brand: 'Predator',
      title: '350 W Power Station',
      name: 'Predator 350 W Power Station',
      
      // FIX: Added required fields (condition, store, price) and imagePath
      condition: 'New', // Default hardcoded condition
      store: 'Harbor Freight Tools', // Default hardcoded store
      price: 349.99, // Default hardcoded price
      imagePath: null, // Set to null since it's an optional String?
      
      completionDate: DateTime(2025, 10, 1),
      shortDescription: 'Recharge Station',
      notes:
          'Monthly recharge at your local power station to stay energized, connected, and ready for anything with reliable energy every month.',
      requiredMaterials: [
        MaterialRow(tool: 'power supply cord', location: 'cord box'),
        MaterialRow(tool: 'solar panels', location: 'bottom garage shelf'),
      ],
    ),
  };

  /// Synchronous getter for the demo.
  /// In production, make this `Future<Asset>` and fetch from your API.
  Asset getById(String id) {
    final a = _items[id];
    if (a == null) {
      throw Exception('Asset not found: $id');
    }
    return a;
  }
}

final assetRepository = AssetRepository();
