// Helpers (top-level)
int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double _asDouble(dynamic v, {double fallback = 0.0}) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

bool _asBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

String _asString(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  return v.toString();
}

DateTime _asDate(dynamic v) {
  if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
  if (v is int) {
    // Heuristic: seconds vs milliseconds
    return v > 2000000000
        ? DateTime.fromMillisecondsSinceEpoch(v).toLocal()
        : DateTime.fromMillisecondsSinceEpoch(v * 1000).toLocal();
  }
  if (v is String) {
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso.toLocal();
    final n = int.tryParse(v);
    if (n != null) return _asDate(n);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

class MaintenanceEntry {
  final String id;
  final String assetId;
  final String brandName;
  final String productName;
  final String assetCategory;
  final double costPaid;
  final DateTime maintenanceDueDate;
  final String maintenanceTitle;
  final String maintenanceDescription;
  final String maintenanceStatus;
  final bool preserveFromPrior;
  final bool isCompleted;

  MaintenanceEntry({
    required this.id,
    required this.assetId,
    required this.brandName,
    required this.productName,
    required this.assetCategory,
    required this.costPaid,
    required this.maintenanceDueDate,
    required this.maintenanceTitle,
    required this.maintenanceDescription,
    required this.maintenanceStatus,
    required this.preserveFromPrior,
    required this.isCompleted,
  });

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    // Allow alternate key names and nulls
    final dueRaw = json['maintenanceDueDate'] ?? json['dueDate'] ?? json['due_date'];

    return MaintenanceEntry(
      id: _asString(json['id'] ?? json['_id']),
      assetId: _asString(json['assetId'] ?? json['asset_id']),
      brandName: _asString(json['brandName']),
      productName: _asString(json['productName']),
      assetCategory: _asString(json['assetCategory']),
      costPaid: _asDouble(json['costPaid']),
      maintenanceDueDate: _asDate(dueRaw),
      maintenanceTitle: _asString(json['maintenanceTitle'] ?? json['title']),
      maintenanceDescription: _asString(json['maintenanceDescription'] ?? json['description']),
      maintenanceStatus: _asString(json['maintenanceStatus'] ?? json['status']),
      preserveFromPrior: _asBool(json['preserveFromPrior']),
      isCompleted: _asBool(json['isCompleted'] ?? json['completed']),
    );
  }

  MaintenanceEntry copyWith({
    String? id,
    String? assetId,
    String? brandName,
    String? productName,
    String? assetCategory,
    double? costPaid,
    DateTime? maintenanceDueDate,
    String? maintenanceTitle,
    String? maintenanceDescription,
    String? maintenanceStatus,
    bool? preserveFromPrior,
    bool? isCompleted,
  }) {
    return MaintenanceEntry(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      brandName: brandName ?? this.brandName,
      productName: productName ?? this.productName,
      assetCategory: assetCategory ?? this.assetCategory,
      costPaid: costPaid ?? this.costPaid,
      maintenanceDueDate: maintenanceDueDate ?? this.maintenanceDueDate,
      maintenanceTitle: maintenanceTitle ?? this.maintenanceTitle,
      maintenanceDescription: maintenanceDescription ?? this.maintenanceDescription,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      preserveFromPrior: preserveFromPrior ?? this.preserveFromPrior,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'brandName': brandName,
      'productName': productName,
      'assetCategory': assetCategory,
      'costPaid': costPaid,
      'maintenanceDueDate': maintenanceDueDate.toIso8601String(),
      'maintenanceTitle': maintenanceTitle,
      'maintenanceDescription': maintenanceDescription,
      'maintenanceStatus': maintenanceStatus,
      'preserveFromPrior': preserveFromPrior,
      'isCompleted': isCompleted,
    };
  }
}