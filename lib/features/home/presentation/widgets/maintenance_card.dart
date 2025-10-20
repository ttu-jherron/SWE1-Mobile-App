import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mobile_app/features/assets/data/asset.dart';
import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
import '../../../maintenance/data/maintenance_item.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceItem item;
  final Asset asset;
  final VoidCallback onTap;

  const MaintenanceCard({
    super.key,
    required this.item,
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = asset?.imagePath;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, // reduced from 56
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                image: asset.imagePath != null && imagePath!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imagePath),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (asset.imagePath == null || asset.imagePath?.isEmpty == true)
                  ? Icon(Icons.build_circle, color: AppColors.ebonyClay, size: 28)
                  : null,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Prevents overflow
                children: [
                  AutoSizeText(
                    _formatDate(item.maintenanceDueDate),
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                    maxLines: 1,
                    minFontSize: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // Reduce spacing if needed
                  Row(
                    children: [
                      if (item.maintenanceStatus == 'Overdue')
                        const Text('! Late  ',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            )),
                      Expanded(
                        child: AutoSizeText(
                          item.maintenanceTitle,
                          maxLines: 1,
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            decoration: TextDecoration.none, // <-- Add this line
                          ),
                        ),
                      ),
                    ],
                  ),
                  AutoSizeText(
                    item.productName,
                    maxLines: 1,
                    minFontSize: 8,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${_mon[d.month]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  static const _mon = [
    '', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ];
}
