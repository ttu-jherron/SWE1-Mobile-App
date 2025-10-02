import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../widgets/add_favorite.dart';
import '../widgets/add_maintenance.dart';
import '../../asset_inventory/presentation/edit_asset.dart';
import '../../assets/data/asset.dart';
import '../../../core/layout/app_layout.dart';

class ViewAssetPage extends StatelessWidget {
  final Asset asset;
  const ViewAssetPage({super.key, required this.asset});

  // Same image logic as Home/MyAssets
  Widget _buildAssetImage(String? path) {
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
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
    );
  }

  String _formatCurrency(double price) => '\$${price.toStringAsFixed(2)}';

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.ebonyClay,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.ebonyClay,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (auto-sizes to fit title)
          SafeArea(
            bottom: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(30, 24, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      asset.title,
                      maxLines: 3, // allow wrapping
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        color: AppColors.ebonyClay,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(right: 6.0),
                    child: AddFavorite(intSize: 32),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.ebonyClay,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable content (unchanged)
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildAssetImage(asset.imagePath),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Details
                      const Text(
                        "Asset Details",
                        style: TextStyle(
                          color: AppColors.ebonyClay,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildDetailRow("Asset Name", asset.name),
                      _buildDetailRow("Condition", asset.condition),
                      _buildDetailRow("Location", asset.store),
                      _buildDetailRow("Bought From", asset.store),
                      _buildDetailRow("Price", _formatCurrency(asset.price)),
                      _buildDetailRow("Brand", asset.brand),
                      _buildDetailRow("ID", asset.id),

                      const SizedBox(height: 30),

                      // Maintenance placeholder (unchanged)
                      const Text(
                        "Next Maintenance",
                        style: TextStyle(
                          color: AppColors.ebonyClay,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            MaintenanceCard(),
                            MaintenanceCard(),
                            MaintenanceCard(),
                            MaintenanceCard(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Notes
                      const Text(
                        "Notes",
                        style: TextStyle(
                          color: AppColors.ebonyClay,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        asset.notes,
                        style: const TextStyle(
                          color: AppColors.ebonyClay,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Edit Asset button (unchanged)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            debugPrint("Edit Asset Button Pressed for ID: ${asset.id}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AppLayout(
                                  currentIndex: 1,
                                  body: EditAssetPage(asset: asset),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ebonyClay,
                            foregroundColor: AppColors.sandyYellow,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xl,
                              vertical: Spacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Radii.md),
                            ),
                          ),
                          child: const Text('Edit Asset'),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


