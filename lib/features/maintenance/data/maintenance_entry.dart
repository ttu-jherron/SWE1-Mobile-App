class MaintenanceEntry {
  final String id;
  final String assetId;
  final DateTime date;
  final String summary;
  final String? notes;

  // ... fromJson constructor stays the same ...
  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      id: json['id'],
      assetId: json['assetId'],
      date: DateTime.parse(json['date']),
      summary: json['summary'],
      notes: json['notes'],
    );
  }

  // ✅ Add this method to convert the object to a map for POST requests.
  // We don't include 'id' because the database will generate it.
  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'date': date.toIso8601String(), // Convert DateTime to a string
    'summary': summary,
    'notes': notes,
  };

  MaintenanceEntry({
    required this.id,
    required this.assetId,
    required this.date,
    required this.summary,
    this.notes,
  });
}