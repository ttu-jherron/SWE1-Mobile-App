import 'package:flutter/material.dart';
import 'package:mobile_app/core/colors.dart';
import '../../../../core/constants.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Color borderColor;
  final bool isRequired;
  final Color labelColor;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.borderColor = Colors.black,
    this.isRequired = false,
    this.labelColor = AppColors.darkText, // Default color
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    // Create a label style using the provided color
    final TextStyle labelStyle = TextStyle(
      color: widget.labelColor, // Use the specified label color
      fontSize: TypographyScale.field,
    );

    return TextFormField(
      controller: widget.controller,
      cursorColor: Colors.black,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        fontSize: TypographyScale.field,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        // Use the custom label style with the specified color
        label: widget.isRequired
            ? RichText(
                text: TextSpan(
                  text: widget.label,
                  style: labelStyle, // Use the custom style
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: TypographyScale.field,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                widget.label,
                style: labelStyle, // Use the custom style
              ),
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: TypographyScale.field,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        // Add visibility toggle button if this is a password field
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
