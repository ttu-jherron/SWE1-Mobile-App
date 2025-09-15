class Asset {
  final String id;
  final String brand;
  final String title;           // “350 W Power Station”
  final String name;            // “Predator 350 W Power Station”
  final DateTime completionDate;
  final String shortDescription;
  final String notes;
  final List<MaterialRow> requiredMaterials;

  Asset({
    required this.id,
    required this.brand,
    required this.title,
    required this.name,
    required this.completionDate,
    required this.shortDescription,
    required this.notes,
    required this.requiredMaterials,
  });
}

class MaterialRow {
  final String tool;
  final String location;

  MaterialRow({required this.tool, required this.location});
}
