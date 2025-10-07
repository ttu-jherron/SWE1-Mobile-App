class MaintenanceItem {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isLate;
  final String thumbAsset;

  MaintenanceItem({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.isLate,
    required this.thumbAsset,
  });

  // TODO(back-end): add from Json/toJson for API
  // factory MaintenanceItem.fromJson(Map<String,dynamic> j) => ...
}