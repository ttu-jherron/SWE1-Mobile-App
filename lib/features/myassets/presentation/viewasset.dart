import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../widgets/add_favorite.dart';
import '../../asset_inventory/presentation/edit_asset.dart';
import '../../assets/data/asset.dart';
import '../../maintenance/data/maintenance_store.dart';
import '../../maintenance/data/maintenance_entry.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/routing.dart'; // add

final DateFormat _df = DateFormat('MMM dd, yyyy');

class ViewAssetPage extends StatefulWidget {
  final Asset asset;
  const ViewAssetPage({super.key, required this.asset});

  @override
  State<ViewAssetPage> createState() => _ViewAssetPageState();
}

class _ViewAssetPageState extends State<ViewAssetPage> {
  late Asset _asset;

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
  }

  Widget _buildAssetImage(String? path, {BoxFit fit = BoxFit.fitWidth}) {
    if (path == null || path.isEmpty) {
      return Image.asset('assets/images/bob.jpg', fit: fit);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final uri = Uri.parse(path);
      final fullPath = uri.hasScheme ? path : 'https://$path';

      return Image.network(
        fullPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          );
        },
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/bob.jpg', fit: BoxFit.cover),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/bob.jpg', fit: fit),
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/images/bob.jpg', fit: fit),
    );
  }

  String _formatCurrency(double price) => '\$${price.toStringAsFixed(2)}';

  String _formatEntry(MaintenanceEntry e) =>
      '${_df.format(e.maintenanceDueDate)} — ${e.maintenanceTitle}';

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
              style: const TextStyle(color: AppColors.ebonyClay, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxImageHeight = MediaQuery.of(context).size.height * 0.33;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Extra bottom padding so content clears the bottom nav (prevents overflow)
    final extraBottom = bottomInset + kBottomNavigationBarHeight + 24;

    return Scaffold(
      body: SafeArea(
        // added bottom safe area handling
        top: false,
        bottom: false, // we add custom padding instead
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                        _asset.title, // updated (was itemName)
                        maxLines: 3,
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
                    Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: AddFavorite(intSize: 32, assetId: _asset.id),
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

            // Content
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
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxImageHeight,
                              minWidth: double.infinity,
                            ),
                            child: Center(
                              child: _buildAssetImage(
                                _asset.imagePath, // updated
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          "Asset Details",
                          style: TextStyle(
                            color: AppColors.ebonyClay,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildDetailRow("Brand Name", _asset.brand), // updated
                        _buildDetailRow("Display Title", _asset.title),
                        _buildDetailRow(
                          "Condition",
                          _asset.condition,
                        ), // updated
                        _buildDetailRow(
                          "Location",
                          _asset.currentLocation,
                        ), // mapped from currentLocation
                        //_buildDetailRow("Bought From", asset.store), // no separate field; re-using
                        _buildDetailRow(
                          "Price",
                          _formatCurrency(_asset.price),
                        ), // updated
                        _buildDetailRow(
                          "Purchased",
                          _df.format(_asset.completionDate),
                        ),
                        _buildDetailRow("Category", _asset.shortDescription),
                        _buildDetailRow(
                          "Favorite",
                          _asset.favorite ? "Yes" : "No",
                        ),

                        const SizedBox(height: 30),
                        const Text(
                          "Next Maintenance",
                          style: TextStyle(
                            color: AppColors.ebonyClay,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        AnimatedBuilder(
                          animation: maintenanceStore,
                          builder: (context, _) {
                            final List<MaintenanceEntry> entries = [
                              ...maintenanceStore.allFor(_asset.id)
                                  .where((e) => e.localStatus == 'Upcoming') // <-- Only upcoming
                            ]..sort((a, b) => a.maintenanceDueDate.compareTo(b.maintenanceDueDate));
                            final MaintenanceEntry? next = entries.isEmpty
                                ? null
                                : entries.first;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  next == null ? '—' : _formatEntry(next),
                                  style: const TextStyle(
                                    color: AppColors.ebonyClay,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (entries.isNotEmpty)
                                  SizedBox(
                                    height: 96,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: entries.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                                      itemBuilder: (ctx, i) {
                                        final e = entries[i];
                                        return _MaintChip(
                                          dateLabel: _df.format(e.maintenanceDueDate),
                                          title: e.maintenanceTitle,
                                          status: e.localStatus, // <-- Use localStatus
                                          onTap: () async {
                                            final result = await Navigator.pushNamed(
                                              context,
                                              AppRoutes.maintenanceEntryDetail,
                                              arguments: e,
                                            );
                                            if (result == true) {
                                              await maintenanceStore.refresh(force: true); // <-- Force refresh
                                              setState(() {}); // <-- Rebuild to show updated status
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AppLayout(
                                        currentIndex: 1,
                                        body: EditAssetPage(asset: _asset),
                                      ),
                                    ),
                                  );
                                  if (result is Asset) {
                                    setState(() {
                                      _asset = result;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.ebonyClay,
                                  foregroundColor: AppColors.sandyYellow,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Spacing.xl,
                                    vertical: Spacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Radii.md,
                                    ),
                                  ),
                                ),
                                child: const Text('Edit Asset'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.maintenance, // Use your maintenance screen route
                                    arguments: {
                                      'assetId': _asset.id, // Pass the asset ID as a filter argument
                                    },
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
                                    borderRadius: BorderRadius.circular(
                                      Radii.md,
                                    ),
                                  ),
                                ),
                                child: const Text('View Maintenance'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(height: extraBottom), // CHANGED
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintChip extends StatelessWidget {
  final String dateLabel;
  final String title;
  final String status;
  final VoidCallback onTap;

  const _MaintChip({
    required this.dateLabel,
    required this.title,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.build_circle,
                color: status == 'Overdue'
                    ? Colors.red
                    : status == 'Completed'
                        ? Colors.green
                        : status == 'Upcoming'
                            ? AppColors.darkGold
                            : AppColors.ebonyClay,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ebonyClay,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.ebonyClay),
          ],
        ),
      ),
    );
  }
}