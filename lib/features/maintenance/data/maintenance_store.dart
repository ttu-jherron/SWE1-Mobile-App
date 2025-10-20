import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'maintenance_entry.dart';
import 'package:mobile_app/core/data/data_handler.dart';

/// Maintenance store that uses DataHandler for API persistence.
/// Call `maintenanceStore.add(...)` to create, and listen via AnimatedBuilder/ListenableBuilder.
class MaintenanceStore extends ChangeNotifier {
  final DataHandler _dataHandler;

  MaintenanceStore(this._dataHandler) {
    // Listen to DataHandler's maintenance stream
    _dataHandler.maintenanceStream.listen((_) => notifyListeners());
  }

  List<MaintenanceEntry> allFor(String assetId) {
    final all = _dataHandler.cachedMaintenance ?? [];
    return all.where((entry) => entry.assetId == assetId).toList();
  }

  MaintenanceEntry? nextFor(String assetId) {
    final list = allFor(assetId);
    if (list.isEmpty) return null;
    final sorted = [...list]..sort((a, b) => a.maintenanceDueDate.compareTo(b.maintenanceDueDate));
    return sorted.first;
  }

  Future<void> add(MaintenanceEntry entry) async {
    await _dataHandler.addMaintenance(entry);
    notifyListeners();
  }

  Future<void> update(MaintenanceEntry entry) async {
    final patch = {
      'maintenanceTitle': entry.maintenanceTitle,
      'maintenanceDescription': entry.maintenanceDescription,
      'maintenanceDueDate': entry.maintenanceDueDate.toIso8601String(),
      'maintenanceStatus': entry.maintenanceStatus,
      'costPaid': entry.costPaid,
      'recurrenceInterval': entry.recurrenceInterval,
      'recurrenceUnit': entry.recurrenceUnit,
      'isCompleted': entry.isCompleted,
    };
    await _dataHandler.updateMaintenance(maintenanceId: entry.id, patch: patch);
    await refresh(force: true);
  }

  List<MaintenanceEntry> getAll() {
    return _dataHandler.cachedMaintenance ?? [];
  }

  // Optional: expose a manual refresh
  Future<void> refresh({bool force = true}) async {
    await _dataHandler.getMaintenance(force: force);
    notifyListeners();
  }
}

// TODO: Initialize with proper context injection when used in widgets
// For now, create a factory method to initialize with context
MaintenanceStore createMaintenanceStore(BuildContext context) {
  return MaintenanceStore(DataHandler.fromContext(context));
}

// Temporary global instance - will be replaced with proper dependency injection
MaintenanceStore? _maintenanceStore;
MaintenanceStore get maintenanceStore {
  if (_maintenanceStore == null) {
    throw Exception('MaintenanceStore not initialized. Call initializeMaintenanceStore(context) first.');
  }
  return _maintenanceStore!;
}

void initializeMaintenanceStore(BuildContext context) {
  if (_maintenanceStore == null) {
    _maintenanceStore = MaintenanceStore(DataHandler.fromContext(context));
    // Kick initial fetch so UI has data
    unawaited(_maintenanceStore!._dataHandler.getMaintenance(force: false));
  }
}