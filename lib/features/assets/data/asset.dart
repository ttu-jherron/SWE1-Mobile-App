import 'package:flutter/material.dart';

// Helper class for required materials/tools
class MaterialRow {
  final String tool;
  final String location;

  MaterialRow({required this.tool, required this.location});

  Map<String, dynamic> toJson() => {
        'tool': tool,
        'location': location,
      };

  factory MaterialRow.fromJson(Map<String, dynamic> json) => MaterialRow(
        tool: json['tool'] as String,
        location: json['location'] as String,
      );

  @override
  String toString() => 'MaterialRow(tool: $tool, location: $location)';
}

/// The core data structure for an asset managed by the user.
@immutable

class Asset {
  final String id;
  final String itemName;
  final String brandName;
  final String category;
  final DateTime purchaseDate;
  final double purchaseCost;
  final String currentLocation;
  final List<String> images;
  final String conditionDescription;
  final String ownerUserId;
  final String status;
  final bool favorite;

  const Asset({
    required this.id,
    required this.itemName,
    required this.brandName,
    required this.category,
    required this.purchaseDate,
    required this.purchaseCost,
    required this.currentLocation,
    required this.images,
    required this.conditionDescription,
    required this.ownerUserId,
    required this.status,
    this.favorite = false,
  });


  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      itemName: json['itemName'] as String,
      brandName: json['brandName'] as String,
      category: json['category'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      purchaseCost: (json['purchaseCost'] as num).toDouble(),
      currentLocation: json['currentLocation'] as String,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      conditionDescription: json['conditionDescription'] as String,
      ownerUserId: json['ownerUserId'] as String,
      status: json['status'] as String,
      favorite: (json['favorite'] as bool?) ?? false,
    );
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'itemName': itemName,
      'brandName': brandName,
      'category': category,
      'purchaseDate': purchaseDate.toIso8601String(),
      'purchaseCost': purchaseCost,
      'currentLocation': currentLocation,
      // Only send image URLs or empty list; filter out local file paths
      'images': images.where((img) => img.startsWith('http') || img.startsWith('https')).toList(),
      'conditionDescription': conditionDescription,
      'ownerUserId': ownerUserId,
      'status': status,
      'favorite': favorite,
    };
    // Only include 'id' if it's not empty
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  // Optionally, add a copyWith method for the new fields if needed

  @override
  String toString() {
    return 'Asset(id: $id, itemName: $itemName, brandName: $brandName, purchaseCost: $purchaseCost, favorite: $favorite)';
  }
}

