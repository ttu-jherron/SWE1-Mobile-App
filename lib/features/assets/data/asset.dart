import 'dart:convert';
import 'package:flutter/material.dart';

// Helper class for required materials/tools
class MaterialRow {
  final String tool;
  final String location;

  MaterialRow({required this.tool, required this.location});

  Map<String, dynamic> toJson() => {'tool': tool, 'location': location};

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
  final String currentLocation;
  final double price;
  final String? imagePath; // Path to the image file
  final String category; // NEW: category field

  // --- Maintenance Fields (Placeholders) ---
  final DateTime completionDate;
  final String shortDescription;
  final String notes;
  final List<MaterialRow> requiredMaterials;

  // --- Favorites ---
  bool favorite; // NEW: favorite flag

  Asset({
    required this.id,
    required this.brand,
    required this.title,
    required this.name,

    // Purchase fields
    required this.condition,
    required this.currentLocation,
    required this.price,
    required this.category, // Changed to required
    this.imagePath,

    // Maintenance fields
    required this.completionDate,
    required this.shortDescription,
    required this.notes,
    required this.requiredMaterials,

    // Favorites
    this.favorite = false,
    //this.currentLocation,
  });

  // Factory constructor for creating an Asset object from JSON
  factory Asset.fromJson(Map<String, dynamic> json) {
    String _readString(dynamic v, {String fallback = ''}) {
      if (v == null) return fallback;
      if (v is String) return v;
      return v.toString();
    }

    double _readDouble(dynamic v, {double fallback = 0.0}) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }

    DateTime _readDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    final imagesDynamic = json['images'];
    String? firstImage;
    if (imagesDynamic is List && imagesDynamic.isNotEmpty) {
      firstImage = imagesDynamic.first.toString();
    }

    final itemName = _readString(json['itemName']);
    final brandName = _readString(json['brandName']);
    final category = _readString(json['category']);
    final status = _readString(json['status']);
    final conditionDescription = _readString(json['conditionDescription']);
    final location = _readString(json['currentLocation']);
    final shortDesc = category.isNotEmpty
        ? category
        : (status.isNotEmpty ? status : itemName);

    final notesComposed = [
      if (status.isNotEmpty) status.toUpperCase(),
      if (conditionDescription.isNotEmpty) conditionDescription,
      if (location.isNotEmpty) 'Location: $location',
    ].join(' | ');

    return Asset(
      id: _readString(json['id']),
      brand: brandName,
      title: itemName,
      name: itemName, // or "$brandName $itemName"
      condition: conditionDescription,
      currentLocation: location,
      price: _readDouble(json['purchaseCost']),
      imagePath: firstImage,
      category: category, // Store category from backend
      completionDate: _readDate(json['purchaseDate']),
      shortDescription: shortDesc,
      notes: notesComposed,
      requiredMaterials: const <MaterialRow>[],
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
    'currentLocation': currentLocation,
    'price': price,
    'imagePath': imagePath,
    'category': category, // Include category in JSON
    // Maintenance fields
    'completionDate': completionDate.toIso8601String(),
    'shortDescription': shortDescription,
    'notes': notes,
    'requiredMaterials': requiredMaterials.map((e) => e.toJson()).toList(),

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
    String? currentLocation,
    double? price,
    ValueGetter<String?>? imagePath, // Use ValueGetter for nullable updates
    String? category, // NEW: copy category
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
      currentLocation: currentLocation ?? this.currentLocation,
      price: price ?? this.price,
      imagePath: imagePath != null ? imagePath() : this.imagePath,
      category: category ?? this.category, // Include category in copyWith
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
