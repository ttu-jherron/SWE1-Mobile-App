import 'package:flutter/material.dart';
import '../../../../core/constants.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Color borderColor;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.borderColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: TypographyScale.field,
        color: Colors.black, // Set font color to black
      ),
      decoration: InputDecoration(
        // labelText: label, // Removed so only hint shows
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: TypographyScale.field,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
