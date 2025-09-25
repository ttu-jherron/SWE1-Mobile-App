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

  /// Example async version you’ll likely use later:
  /// Future<Asset> fetchById(String id) async {
  ///   final resp = await http.get(Uri.parse('$baseUrl/assets/$id'));
  ///   return Asset.fromJson(jsonDecode(resp.body));
  /// }
}

final assetRepository = AssetRepository();
