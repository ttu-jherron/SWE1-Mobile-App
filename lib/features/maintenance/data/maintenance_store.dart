import 'package:flutter/foundation.dart';
import 'maintenance_entry.dart';

/// Simple in-memory store you can swap out later.
/// Call `maintenanceStore.add(...)` to create, and listen via AnimatedBuilder/ListenableBuilder.
class MaintenanceStore extends ChangeNotifier {
  // assetId -> list of entries
  final Map<String, List<MaintenanceEntry>> _byAsset = {
    // Seed/burner data
    'asset_001': [
      MaintenanceEntry(
        id: 'm_001',
        assetId: 'asset_001',
        date: DateTime(2025, 10, 1),
        summary: 'Recharge & health check',
        notes: 'Monthly recharge at the station; verify output voltage.',
      ),
    ],
  };

  List<MaintenanceEntry> allFor(String assetId) =>
      List.unmodifiable(_byAsset[assetId] ?? const []);

  MaintenanceEntry? nextFor(String assetId) {
    final list = _byAsset[assetId];
    if (list == null || list.isEmpty) return null;
    final sorted = [...list]..sort((a, b) => a.date.compareTo(b.date));
    return sorted.first;
  }

  void add(MaintenanceEntry entry) {
    final list = _byAsset.putIfAbsent(entry.assetId, () => []);
    list.add(entry);
    notifyListeners();
  }

  // TODO(backend): replace add() with an async API call,
  // then refresh entries and call notifyListeners() on success.
}

final maintenanceStore = MaintenanceStore();
