import 'package:flutter/material.dart';
import '../../../../core/constants.dart';

class AssetCard extends StatelessWidget {
  final String titleTop;     // brand or short line, e.g., "Predator"
  final String titleBottom;  // name, e.g., "350W Power Station"
  final String imageAsset;
  final VoidCallback onTap;

  const AssetCard({
    super.key,
    required this.titleTop,
    required this.titleBottom,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16/10,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(titleTop, style: const TextStyle(color: Colors.black54)),
            Text(
              titleBottom,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF3C4652),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
