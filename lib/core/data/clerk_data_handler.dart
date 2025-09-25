import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

class ClerkDataHandler {
  final ClerkAuthState auth;
  
  // Constructor that takes auth state
  const ClerkDataHandler({required this.auth});

  // Static variable to track last refresh time (shared across all instances)
  static DateTime _lastRefreshAttemptTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  // How often to allow refreshes (1 minute)
  static const Duration _refreshThreshold = Duration(minutes: 1);

  clerk.User? get user => auth.user;
  
  static ClerkDataHandler fromContext(BuildContext context) {
    final auth = ClerkAuth.of(context);
    return ClerkDataHandler(auth: auth);
  }

  Map<String, dynamic> fetchProfile() {
    if (user == null) {
      return {};
    }
    refreshUserData();
    
    return {
      'id': user!.id,
      'email': user!.email,
      'username': user!.username,
      'firstName': user!.firstName,
      'lastName': user!.lastName,
      'imageUrl': user!.imageUrl,
    };
  }
  
  Future<void> refreshUserData() async {
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
      
      debugPrint('ClerkDataHandler: Refreshed client and environment');
    } catch (e) {
      debugPrint('ClerkDataHandler: Error refreshing user data: $e');
    }
  }
  
  // Force refresh method that bypasses the time check (for manual refreshes)
  Future<void> forceRefreshUserData() async {
    try {
      // Update the last refresh time
      _lastRefreshAttemptTime = DateTime.now();
      
      await auth.refreshClient();
      await auth.refreshEnvironment();
      
      debugPrint('ClerkDataHandler: Force refreshed client and environment');
    } catch (e) {
      debugPrint('ClerkDataHandler: Error force refreshing user data: $e');
    }
  }
}