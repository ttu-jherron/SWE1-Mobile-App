import 'maintenance_entry.dart';

class MaintenanceItem {
  final String id;
  final String assetId;
  final String brandName;
  final String productName;
  final String purchaseLocation;
  final String assetCategory;
  final double costPaid;
  final DateTime maintenanceDueDate;
  final String maintenanceTitle;
  final String maintenanceDescription;
  final String maintenanceStatus;
  final bool preserveFromPrior;
  final bool isCompleted;
  final List<String> requiredTools;
  final String toolLocation;
  final int recurrenceUnit;
  final int recurrenceInterval;

  MaintenanceItem({
    required this.id,
    required this.assetId,
    required this.brandName,
    required this.productName,
    required this.purchaseLocation,
    required this.assetCategory,
    required this.costPaid,
    required this.maintenanceDueDate,
    required this.maintenanceTitle,
    required this.maintenanceDescription,
    required this.maintenanceStatus,
    required this.preserveFromPrior,
    required this.isCompleted,
    required this.requiredTools,
    required this.toolLocation,
    required this.recurrenceUnit,
    required this.recurrenceInterval,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      brandName: json['brandName'] as String,
      productName: json['productName'] as String,
      purchaseLocation: json['purchaseLocation'] as String,
      assetCategory: json['assetCategory'] as String,
      costPaid: (json['costPaid'] as num).toDouble(),
      maintenanceDueDate: DateTime.parse(json['maintenanceDueDate'] as String),
      maintenanceTitle: json['maintenanceTitle'] as String,
      maintenanceDescription: json['maintenanceDescription'] as String,
      maintenanceStatus: json['maintenanceStatus'] as String,
      preserveFromPrior: json['preserveFromPrior'] as bool,
      isCompleted: json['isCompleted'] as bool,
      requiredTools: List<String>.from(json['requiredTools'] as List),
      toolLocation: json['toolLocation'] as String,
      recurrenceUnit: json['recurrenceUnit'] as int,
      recurrenceInterval: json['recurrenceInterval'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'brandName': brandName,
      'productName': productName,
      'purchaseLocation': purchaseLocation,
      'assetCategory': assetCategory,
      'costPaid': costPaid,
      'maintenanceDueDate': maintenanceDueDate.toIso8601String(),
      'maintenanceTitle': maintenanceTitle,
      'maintenanceDescription': maintenanceDescription,
      'maintenanceStatus': maintenanceStatus,
      'preserveFromPrior': preserveFromPrior,
      'isCompleted': isCompleted,
      'requiredTools': requiredTools,
      'toolLocation': toolLocation,
      'recurrenceUnit': recurrenceUnit,
      'recurrenceInterval': recurrenceInterval,
    };
  }

  factory MaintenanceItem.fromMaintenanceEntry(MaintenanceEntry entry) {
    return MaintenanceItem(
      id: entry.id,
      assetId: entry.assetId,
      brandName: entry.brandName,
      productName: entry.productName,
      purchaseLocation: entry.purchaseLocation,
      assetCategory: entry.assetCategory,
      costPaid: entry.costPaid,
      maintenanceDueDate: entry.maintenanceDueDate,
      maintenanceTitle: entry.maintenanceTitle,
      maintenanceDescription: entry.maintenanceDescription,
      maintenanceStatus: entry.maintenanceStatus,
      preserveFromPrior: entry.preserveFromPrior,
      isCompleted: entry.isCompleted,
      requiredTools: entry.requiredTools,
      toolLocation: entry.toolLocation,
      recurrenceUnit: entry.recurrenceUnit,
      recurrenceInterval: entry.recurrenceInterval,
    );
  }
}