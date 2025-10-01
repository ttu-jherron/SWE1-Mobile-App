import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../widgets/add_favorite.dart';
import '../widgets/add_maintenance.dart';
// 1. IMPORT: Add the necessary import for the destination page
import '../../asset_inventory/presentation/edit_asset.dart';
//IMPORT: Import Asset data structure
import '../../assets/data/asset.dart';
//IMPORT: Import AppLayout to wrap the next page
import '../../../core/layout/app_layout.dart';

//Updated to accept a single Asset object, use its data for details, and enable navigation 
//to EditAssetPage.

class ViewAssetPage extends StatelessWidget {
  // CHANGE: Replace multiple String parameters with a single Asset object
  final Asset asset;

  const ViewAssetPage({
    super.key,
    required this.asset,
    // Removed all individual string parameters
  });
  
  // Helper to format currency
  String _formatCurrency(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Helper to build a detail row
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
      // The body uses a Column to structure content vertically
      body: Column(
        children: [
          // Header Row (Top of the page)
          Container(
            height: MediaQuery.of(context).size.height * 0.13,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(30, 30, 4, 10),
            alignment: Alignment.topLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    // ⬅️ CHANGE: Use asset.title
                    asset.title,
                    style: const TextStyle(
                      color: AppColors.ebonyClay,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: AddFavorite(intSize: 32),
                ),
                // Back button
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
          
          // Scrollable middle section that expands to fill available space
          Expanded(
            child: Stack(
              children: [
                Container(
                  // Background color for the scrollable content area
                  color: const Color(0xFFF5F5F5),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. Top Image/Gallery Area (Placeholder) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.nearWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 80,
                                color: AppColors.ebonyClay,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // --- 2. Details Section ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Asset Details",
                                style: TextStyle(
                                  color: AppColors.ebonyClay,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Name
                              // ⬅️ CHANGE: Use asset.name
                              _buildDetailRow("Asset Name", asset.name),
                              
                              // Condition
                              // ⬅️ CHANGE: Use asset.condition
                              _buildDetailRow("Condition", asset.condition),
                              
                              // Location (Using store as location placeholder)
                              // ⬅️ CHANGE: Use asset.store
                              _buildDetailRow("Location", asset.store),
                              
                              // Bought From (Using store as boughtFrom placeholder)
                              // ⬅️ CHANGE: Use asset.store
                              _buildDetailRow("Bought From", asset.store),
                              
                              // Price
                              // ⬅️ CHANGE: Use asset.price
                              _buildDetailRow("Price", _formatCurrency(asset.price)),
                              
                              // Brand
                              // ⬅️ CHANGE: Use asset.brand
                              _buildDetailRow("Brand", asset.brand),

                              // Asset ID
                              // ⬅️ CHANGE: Use asset.id
                              _buildDetailRow("ID", asset.id), 
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // --- 3. Maintenance Section (Hardcoded Placeholder) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Next Maintenance",
                                style: TextStyle(
                                  color: AppColors.ebonyClay,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              
                              // Maintenance Cards Row
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        
                        // --- 4. Notes Section ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                // ⬅️ CHANGE: Use asset.notes
                                asset.notes, 
                                style: const TextStyle(
                                  color: AppColors.ebonyClay,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 150), // Extra space for scrolling past the floating button
                      ],
                    ),
                  ),
                ),
                
                // --- 9. Floating Action Button Container (Bottom Right) ---
                Positioned(
                  right: 30,
                  bottom: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.sandyYellow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit Asset Button
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              debugPrint("Edit Asset Button Pressed for ID: ${asset.id}");
                              // ⬅️ CHANGE: Navigation to EditAssetPage, passing the Asset object
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AppLayout(
                                    currentIndex: 1, // Stay on the Assets tab
                                    body: EditAssetPage(asset: asset), // Pass the current asset object
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ebonyClay,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Edit Asset",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // --- 10. Left and Right Vertical Wall Padding (for visual effect) ---\n
                // Left Wall
                Positioned(
                  left: 0,
                  top: 250,
                  bottom: 0,
                  width: 60, // width of wall, same as horizontal padding
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                // Right Wall
                Positioned(
                  right: 0,
                  top: 250,
                  bottom: 0,
                  width: 60, // same as horizontal padding
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

