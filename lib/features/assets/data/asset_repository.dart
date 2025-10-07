import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'asset.dart';

// I added two more dummy assets and a required getAll() method to simulate fetching all 
//assets for the list page.



class AssetRepository {
  final String _baseUrl = 'https://api.thehippoexchange.com';

  /// Get all assets for a user (requires X-User-Id header)
  Future<List<Asset>> getAll(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/assets'),
      headers: {'X-User-Id': userId},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Asset.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load assets: ${response.body}');
    }
  }

  /// Get asset by ID (requires X-User-Id header)
  Future<Asset> getById(String id, String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/assets/$id'),
      headers: {'X-User-Id': userId},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Asset.fromJson(data);
    } else {
      throw Exception('Asset not found: $id (${response.body})');
    }
  }

  /// Upload an image file and return the hosted URL
  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/assets/upload-image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path, contentType: MediaType('image', 'jpeg')));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String;
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

  /// Create a new asset via POST request to the API (requires X-User-Id header)
  Future<Asset> createAsset(Asset asset, String userId) async {
    final jsonBody = jsonEncode(asset.toJson());
    print('POST /assets body: $jsonBody');
    final response = await http.post(
      Uri.parse('$_baseUrl/assets'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId,
      },
      body: jsonBody,
    );
    print('API response status: ${response.statusCode}');
    print('API response body: ${response.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Asset.fromJson(data);
    } else {
      throw Exception('Failed to create asset: ${response.body}');
    }
  }
}

final assetRepository = AssetRepository();

