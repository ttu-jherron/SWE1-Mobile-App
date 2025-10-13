class MaintenanceEntry {
  final String id;
  final String assetId;   // which asset this belongs to
  final DateTime date;    // when to do it
  final String summary;   // short line shown in “Next maintenance”
  final String? notes;    // optional details

  MaintenanceEntry({
    required this.id,
    required this.assetId,
    required this.date,
    required this.summary,
    this.notes,
  });

  // TODO(backend): add fromJson/toJson when wiring API
  // factory MaintenanceEntry.fromJson(Map<String,dynamic> j) => ...
  // Map<String,dynamic> toJson() => ...
}
