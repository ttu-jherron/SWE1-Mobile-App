import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

class ClerkDataHandler {
  final clerk.User? user;
  
  // Constructor that takes user object
  const ClerkDataHandler({required this.user});
  
  // Static method to create from context
  static ClerkDataHandler fromContext(BuildContext context) {
    final auth = ClerkAuth.of(context);
    return ClerkDataHandler(user: auth.user);
  }

  // Method to fetch profile data
  Map<String, dynamic> fetchProfile({bool forceRefresh = false}) {
    if (user == null) {
      return {};
    }
    
    // Extract user data - always gets the latest from the user object
    return {
      'id': user!.id,
      'email': user!.email,
      'username': user!.username,
      'firstName': user!.firstName,
      'lastName': user!.lastName,
      'imageUrl': user!.imageUrl,
    };
  }
  
  // Helper method to refresh user data asynchronously (can be called from _fetchUserData)
  Future<void> refreshUserData(BuildContext context) async {
    try {
      final clerkAuth = ClerkAuth.of(context);
      await clerkAuth.refreshClient();
      await clerkAuth.refreshEnvironment();
      // This is the best we can do with the current Clerk SDK
      debugPrint('ClerkDataHandler: Refreshed client and environment');
    } catch (e) {
      debugPrint('ClerkDataHandler: Error refreshing user data: $e');
    }
  }
}