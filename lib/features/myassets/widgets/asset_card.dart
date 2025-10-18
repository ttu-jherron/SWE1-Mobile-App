import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
import '../widgets/add_favorite.dart';
import '../../assets/data/asset.dart';

// ADD this enum to define the styles
enum AssetCardStyle { home, myAssets }

class AssetCard extends StatefulWidget {
  final VoidCallback? onTap;
  final Asset asset;
  final AssetCardStyle style; // ADD this required style attribute

  const AssetCard({
    super.key,
    required this.asset,
    this.onTap,
    this.style = AssetCardStyle.myAssets, // Default to the existing style
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  @override
  Widget build(BuildContext context) {
    // Use a switch to return the correct style
    switch (widget.style) {
      case AssetCardStyle.home:
        return _buildHomeStyle(context);
      case AssetCardStyle.myAssets:
      default:
        return _buildMyAssetsStyle(context);
    }
  }

  // Builder for the 'Home' screen style
  Widget _buildHomeStyle(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: _buildImage(widget.asset.imagePath), // Use the robust image builder
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              widget.asset.brand,
              style: const TextStyle(color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.asset.title,
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

  // Builder for the 'MyAssets' screen style (the original code from this file)
  Widget _buildMyAssetsStyle(BuildContext context) {
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
                    // width: double.infinity, // REMOVED to fix layout bug
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0), // Added for consistency
                      child: _buildImage(widget.asset.imagePath),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm), // Use height instead of width

                // ✅ Brand text + Heart row
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
                      intSize: 20,
                    ),
                  ],
                ),

                // This SizedBox was redundant
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

  // Universal, robust image builder for both styles
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/bob.jpg', fit: BoxFit.cover);
    }

    // If it's a web URL (contains a dot, or starts with http)
    if (path.startsWith('http') || path.contains('.')) {
      final uri = Uri.parse(path);
      final fullPath = uri.hasScheme ? path : 'https://$path';

      return Image.network(
        fullPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
        },
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
      );
    }

    // Handle local file paths from image picker
    if (path.startsWith('file://') || path.startsWith('/')) {
      final file = path.startsWith('file://')
          ? File(Uri.parse(path).toFilePath())
          : File(path);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
      );
    }

    // Fallback for any other case
    return Image.asset('assets/images/bob.jpg', fit: BoxFit.cover);
  }
}
