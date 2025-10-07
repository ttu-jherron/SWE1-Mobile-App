import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
import '../widgets/add_favorite.dart';
import '../../assets/data/asset.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;
  const AssetCard({super.key, required this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Two columns layout width (adjust if you want 3-up)
    final double cardWidth = (MediaQuery.of(context).size.width - 30*2 - 16) / 2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth.clamp(160, 320), // prevents overly narrow wrap width
        margin: const EdgeInsets.only(bottom: 18, right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row (title + favorite or status icon)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text gets remaining space
                Expanded(
                  child: Text(
                    asset.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ebonyClay,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  asset.favorite ? Icons.star : Icons.star_border,
                  size: 20,
                  color: asset.favorite ? AppColors.sandyYellow : Colors.black26,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Optional brand / category line
            Text(
              asset.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),

            // Price / location row (protect with Flexible widgets)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${asset.price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ebonyClay,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    asset.currentLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.caption?.copyWith(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

