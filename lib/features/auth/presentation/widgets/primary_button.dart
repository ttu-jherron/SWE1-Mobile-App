import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

enum ButtonVariant { darkFilled, yellowFilled }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Changed to nullable to allow disabling
  final ButtonVariant variant;
  final bool isLoading; // New property to handle loading state

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.darkFilled,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isYellow = variant == ButtonVariant.yellowFilled;
    final backgroundColor = isYellow ? AppColors.sandyYellow : AppColors.ebonyClay;
    final foregroundColor = isYellow ? Colors.black : Colors.white;

    // The SizedBox wrapper with a fixed width has been removed.
    // The button will now size itself based on its content and parent constraints.
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm, horizontal: Spacing.xl),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: TypographyScale.button,
        ),
        elevation: isYellow ? 1 : 0,
      ),
      // If isLoading is true, onPressed is null, which disables the button.
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          // If loading, display a progress indicator.
          ? SizedBox(
              height: 24, // Constrain indicator size
              width: 24,
              child: CircularProgressIndicator(
                color: foregroundColor,
                strokeWidth: 2.5,
              ),
            )
          // Otherwise, display the text.
          : Text(text),
    );
  }
}