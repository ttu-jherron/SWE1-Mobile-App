import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

enum ButtonVariant { darkFilled, yellowFilled }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.darkFilled,
  });

  @override
  Widget build(BuildContext context) {
    final isYellow = variant == ButtonVariant.yellowFilled;

    return SizedBox(
      width: 160,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isYellow ? AppColors.sandyYellow : AppColors.ebonyClay,
          foregroundColor: isYellow ? Colors.black : Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm, horizontal: Spacing.xl),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: TypographyScale.button,
          ),
          elevation: isYellow ? 1 : 0,
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
