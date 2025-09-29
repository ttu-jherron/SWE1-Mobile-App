import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:http/http.dart' as http;

class DataHandler {
  final ClerkAuthState auth;
  
  const DataHandler({required this.auth});

  // Static variable to track last refresh time (shared across all instances)
  static DateTime _lastRefreshAttemptTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  static const Duration _refreshThreshold = Duration(minutes: 1);

  clerk.User? get user => auth.user;
  String get clerkID => user!.id;
  
  static DataHandler fromContext(BuildContext context) {
    final auth = ClerkAuth.of(context);
    return DataHandler(auth: auth);
  }


  // =============================================================================
  // CLERK METHODS - Direct Clerk operations
  // =============================================================================

  Future<Map<String, dynamic>> clerkFetchProfile() async {
    if (user == null) {
      return {};
    }
    clerkRefreshUserData();
    
    return {
      'id': user!.id,
      'email': user!.email,
      'username': user!.username,
      'firstName': user!.firstName,
      'lastName': user!.lastName,
      'imageUrl': user!.imageUrl,
    };
  }
  
  Future<void> clerkRefreshUserData() async {
    final now = DateTime.now();
    
    // Avoid multiple refresh calls
    if (now.difference(_lastRefreshAttemptTime) < _refreshThreshold) {
      return;
    }
    
    try {
      // Update the last refresh time before making the API call
      _lastRefreshAttemptTime = now;
      
      await auth.refreshClient();
      await auth.refreshEnvironment();
      
      debugPrint('DataHandler: Refreshed client and environment');
    } catch (e) {
      debugPrint('DataHandler: Error refreshing user data: $e');
    }
  }
  
  // Force refresh method that bypasses the time check (for manual refreshes)
  Future<void> clerkForceRefreshUserData() async {
    try {
      // Update the last refresh time
      _lastRefreshAttemptTime = DateTime.now();
      
      await auth.refreshClient();
      await auth.refreshEnvironment();
      
      debugPrint('DataHandler: Force refreshed client and environment');
    } catch (e) {
      debugPrint('DataHandler: Error force refreshing user data: $e');
    }
  }

  // =============================================================================
  // BACKEND METHODS - Our backend API
  // =============================================================================

  Future<Map<String, dynamic>> backendFetchProfile() async {
    if (user == null) {
      throw Exception("User not found");
    }
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/profile'),
        headers: {
          'accept': '*/*',
          'X-User-Id': user!.id,  // Using the Clerk user ID
        },
      );
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('DataHandler: Backend profile fetched successfully');
        return data;
      } else {
        debugPrint('DataHandler: Backend request failed with status: ${response.statusCode}');
        debugPrint('DataHandler: Response body: ${response.body}');
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DataHandler: Error fetching backend profile: $e');
      rethrow;
    }
    
  }

}