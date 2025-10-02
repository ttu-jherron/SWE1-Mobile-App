import 'dart:convert';
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
  final String brand;
  final String title; // e.g., “350 W Power Station”
  final String name; // e.g., “Predator 350 W Power Station”
  
  // --- Purchase/Identity Fields ---
  final String condition;
  final String store;
  final double price;
  final String? imagePath; // Path to the image file
  
  // --- Maintenance Fields (Placeholders) ---
  final DateTime completionDate;
  final String shortDescription;
  final String notes;
  final List<MaterialRow> requiredMaterials;

  // --- Favorites ---
  final bool favorite; // NEW: favorite flag

  const Asset({
    required this.id,
    required this.brand,
    required this.title,
    required this.name,
    
    // Purchase fields
    required this.condition,
    required this.store,
    required this.price,
    this.imagePath,
    
    // Maintenance fields
    required this.completionDate,
    required this.shortDescription,
    required this.notes,
    required this.requiredMaterials,

    // Favorites
    this.favorite = false,
  });

  // Factory constructor for creating an Asset object from JSON
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      brand: json['brand'] as String,
      title: json['title'] as String,
      name: json['name'] as String,
      
      // Purchase fields
      condition: json['condition'] as String,
      store: json['store'] as String,
      price: (json['price'] as num).toDouble(),
      imagePath: json['imagePath'] as String?,
      
      // Maintenance fields
      completionDate: DateTime.parse(json['completionDate'] as String),
      shortDescription: json['shortDescription'] as String,
      notes: json['notes'] as String,
      requiredMaterials: (json['requiredMaterials'] as List<dynamic>)
          .map((item) => MaterialRow.fromJson(item as Map<String, dynamic>))
          .toList(),

      // Favorites
      favorite: (json['favorite'] as bool?) ?? false,
    );
  }

  // Method to convert Asset object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'title': title,
        'name': name,
        
        // Purchase fields
        'condition': condition,
        'store': store,
        'price': price,
        'imagePath': imagePath,
        
        // Maintenance fields
        'completionDate': completionDate.toIso8601String(),
        'shortDescription': shortDescription,
        'notes': notes,
        'requiredMaterials':
            requiredMaterials.map((e) => e.toJson()).toList(),

        // Favorites
        'favorite': favorite,
      };

  // Method to create a copy of the asset with optional updates
  Asset copyWith({
    String? id,
    String? brand,
    String? title,
    String? name,
    String? condition,
    String? store,
    double? price,
    ValueGetter<String?>? imagePath, // Use ValueGetter for nullable updates
    DateTime? completionDate,
    String? shortDescription,
    String? notes,
    List<MaterialRow>? requiredMaterials,
    bool? favorite, // NEW: copy favorite
  }) {
    return Asset(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      title: title ?? this.title,
      name: name ?? this.name,
      condition: condition ?? this.condition,
      store: store ?? this.store,
      price: price ?? this.price,
      imagePath: imagePath != null ? imagePath() : this.imagePath,
      completionDate: completionDate ?? this.completionDate,
      shortDescription: shortDescription ?? this.shortDescription,
      notes: notes ?? this.notes,
      requiredMaterials: requiredMaterials ?? this.requiredMaterials,
      favorite: favorite ?? this.favorite,
    );
  }

  @override
  String toString() {
    return 'Asset(id: $id, brand: $brand, title: $title, price: $price, imagePath: $imagePath, favorite: $favorite)';
  }
}

