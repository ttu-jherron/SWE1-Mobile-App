import 'package:flutter/material.dart';
import '/../../core/colors.dart';

class LinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const LinkText({
    super.key,
    required this.text,
    required this.onTap,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.ebonyClay,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
