import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/constants.dart';

class AlertBanner extends StatelessWidget {
  final String title;          // "Important"
  final String message;        // placeholder text
  final VoidCallback? onClose;

  const AlertBanner({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sandyYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.md, Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.black87),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 1, color: Colors.black45),
          Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              decoration: TextDecoration.underline, // matches mock emphasis
            ),
          ),
        ],
      ),
    );
  }
}
