import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Profile {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final int userId;

  const Profile({required this.userId, required this.firstName, required this.lastName, required this.email, required this.phoneNumber});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'userId': int userId, 'firstName': String firstName, 'lastName': String lastName, 'email': String email, 'phoneNumber': String phoneNumber} => Profile(userId: userId, firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber),
      _ => throw const FormatException('Failed to load Profile.'),
    };
  }

  Future<Profile> createProfile() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>
      {
        'userId': userId.toString(),
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber
      }
      ),
    );
    if (kDebugMode) {
      debugPrint(response.statusCode.toString());
    }
    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return Profile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create profile.');
    }
  }
}