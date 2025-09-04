import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isRequired;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isRequired = false, // Default to not required
    this.isPassword = false, // Default to not a password field
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // State for toggling password visibility, only used if it's a password field
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

   @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      child: TextField(
        controller: widget.controller,
        cursorColor: Colors.black,
        obscureText: _obscureText,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          alignLabelWithHint: false,
          filled: false,
          // Use a RichText label to conditionally add the red asterisk
          label: RichText(
            text: TextSpan(
              text: widget.labelText,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
              children: widget.isRequired
                  ? [
                      const TextSpan(
                        text: " *",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          // Conditionally add the visibility icon only for password fields
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}