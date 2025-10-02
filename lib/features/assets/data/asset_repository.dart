import 'asset.dart';

// I added two more dummy assets and a required getAll() method to simulate fetching all 
//assets for the list page.

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
      imagePath: 'assets/images/Predator.jpg',
      
      completionDate: DateTime(2025, 10, 1),
      shortDescription: 'Recharge Station',
      notes:
          'Monthly recharge at your local power station to stay energized, connected, and ready for anything with reliable energy every month.',
      requiredMaterials: [
        MaterialRow(tool: 'power supply cord', location: 'cord box'),
        MaterialRow(tool: 'solar panels', location: 'bottom garage shelf'),
      ],
      favorite: true,
    ),
    //ADDED: Additional dummy assets for the list view
    'asset_002': Asset(
      id: 'asset_002',
      brand: 'John Deere',
      title: 'Model 4020 Tractor',
      name: 'John Deere 4020',
      condition: 'Used - Good',
      store: 'Local Farm Auction',
      price: 15000.00,
      imagePath: 'assets/images/Tractor.png',
      completionDate: DateTime(2024, 1, 1),
      shortDescription: 'Engine Oil Change',
      notes: 'Need to replace hydraulic lines soon.',
      requiredMaterials: [],
      favorite: true,
    ),
    'asset_003': Asset(
      id: 'asset_003',
      brand: 'Dyson',
      title: 'V15 Detect',
      name: 'Dyson V15',
      condition: 'Used - Like New',
      store: 'Amazon',
      price: 699.00,
      imagePath: 'assets/images/Vacuum.png',
      completionDate: DateTime(2026, 6, 15),
      shortDescription: 'Filter cleaning',
      notes: 'Annual filter cleaning required.',
      requiredMaterials: [],
      favorite: true
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
  
  //ADDED: Method to get all assets for the list page
  List<Asset> getAll() {
    return _items.values.toList();
  }
}

final assetRepository = AssetRepository();

