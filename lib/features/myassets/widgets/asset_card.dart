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
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 140, minHeight: 60),
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: widget.onTap ?? () => debugPrint("AssetCard tapped: ${widget.asset.itemName}"),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image (same behavior as Home)
                Card(
                  margin: EdgeInsets.zero,
                  color: AppColors.nearWhite,
                  child: SizedBox(
                    height: 120, // was 75
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildImage(widget.asset.images.isNotEmpty ? widget.asset.images.first : null),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.asset.brandName,
                      style: const TextStyle(
                        color: AppColors.ebonyClay,
                        fontSize: 14,
                        height: 2.0,
                      ),
                    ),
                    const AddFavorite(),
                  ],
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  widget.asset.itemName,
                  style: const TextStyle(
                    color: AppColors.ebonyClay,
                    fontSize: 14,
                    height: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
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
        errorBuilder: (_, __, ___) => Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
      );
    }
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/bob.jpg', fit: BoxFit.cover));
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
    );
  }
}

