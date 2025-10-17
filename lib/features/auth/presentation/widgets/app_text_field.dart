import 'package:flutter/material.dart';
import 'package:mobile_app/core/colors.dart';
import '../../../../core/constants.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final Color? curserColor;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Color borderColor;
  final bool isRequired;
  final Color labelColor;
  final Color? textColor;
  final Color? cursorColor;

  // NEW: control IME composing underline + selection colors
  final bool enableSuggestions;
  final bool autocorrect;
  final Color? selectionColor;
  final Color? selectionHandleColor;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.curserColor,
    this.hint,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.borderColor = Colors.black,
    this.isRequired = false,
    this.labelColor = AppColors.darkText, // Default color
    this.textColor = AppColors.darkText,     // default: dark for Sign In
    this.cursorColor = AppColors.darkText,   // default: dark for Sign In
    this.enableSuggestions = false, // disable to avoid composing underline
    this.autocorrect = false,       // disable to avoid composing underline
    this.selectionColor,
    this.selectionHandleColor,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  OutlineInputBorder _outline(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2.0),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      );

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    // Create a label style using the provided color
    final TextStyle labelStyle = TextStyle(
      color: widget.labelColor,
      fontSize: TypographyScale.field,
    );

    final cursor = widget.cursorColor ?? AppColors.darkText;
    final txtColor = widget.textColor ?? AppColors.darkText;

    // Selection colors (the highlight and the draggable handle “blob”)
    final selColor = widget.selectionColor ?? txtColor.withOpacity(0.35);
    final handleColor = widget.selectionHandleColor ?? cursor;

    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: cursor,
        selectionColor: selColor,
        selectionHandleColor: handleColor,
      ),
      child: TextFormField(
        controller: widget.controller,
        cursorColor: cursor,
        obscureText: _obscureText,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: TextInputAction.done,
        enableSuggestions: widget.enableSuggestions, // removes composing underline
        autocorrect: widget.autocorrect,             // removes composing underline
        style: TextStyle(
          fontSize: TypographyScale.field,
          color: txtColor,
        ),
        decoration: InputDecoration(
          // Force outlined borders in all states (prevents underline)
          border: _outline(widget.borderColor),
          enabledBorder: _outline(widget.borderColor),
          focusedBorder: _outline(widget.borderColor),
          disabledBorder: _outline(widget.borderColor),
          errorBorder: _outline(Colors.red),
          focusedErrorBorder: _outline(Colors.red),

          label: widget.isRequired
              ? RichText(
                  text: TextSpan(
                    text: widget.label,
                    style: labelStyle,
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
              : Text(widget.label, style: labelStyle),
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: TypographyScale.field,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),

          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: widget.labelColor,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
        ),
      ),
    );
  }
}
