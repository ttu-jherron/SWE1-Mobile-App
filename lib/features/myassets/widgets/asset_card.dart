import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
import '../widgets/add_favorite.dart';
import '../../assets/data/asset.dart';

class AssetCard extends StatefulWidget {
  final VoidCallback? onTap;
  final Asset asset;

  const AssetCard({super.key, required this.asset, this.onTap});

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 160,
        minHeight: 60,
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: widget.onTap ??
              () => debugPrint("AssetCard tapped: ${widget.asset.name}"),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Card(
                  margin: EdgeInsets.zero,
                  color: AppColors.nearWhite,
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: ClipRRect(
                      child: _buildImage(widget.asset.imagePath),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),

                // ✅ Brand text + Heart row (fixed overflow)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.asset.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ebonyClay,
                          fontSize: 14,
                          height: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AddFavorite(
                      assetId: widget.asset.id,
                      intSize: 20, // slightly smaller to avoid layout overflow
                    ),
                  ],
                ),

                const SizedBox(width: Spacing.sm),
                Text(
                  widget.asset.title,
                  style: const TextStyle(
                    color: AppColors.ebonyClay,
                    fontSize: 14,
                    height: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/bob.jpg', fit: BoxFit.cover);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
    );
  }
}
