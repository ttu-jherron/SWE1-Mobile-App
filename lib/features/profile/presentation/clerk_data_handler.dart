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
  Map<String, dynamic> fetchProfile() {
    if (user == null) {
      return {};
    }
    
    // Extract user data
    return {
      'id': user!.id,
      'email': user!.email,
      'username': user!.username,
      'firstName': user!.firstName,
      'lastName': user!.lastName,
      'imageUrl': user!.imageUrl,
    };
  }
}