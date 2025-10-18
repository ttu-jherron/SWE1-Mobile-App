import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
import '../../../maintenance/data/maintenance_item.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceItem item;
  final VoidCallback onTap;

  const MaintenanceCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.build_circle,
                color: item.maintenanceStatus == 'Overdue'
                    ? Colors.red
                    : item.maintenanceStatus == 'Completed'
                        ? Colors.green
                        : item.maintenanceStatus == 'Upcoming'
                        ? AppColors.darkGold
                        : AppColors.ebonyClay,
                size: 32,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(item.maintenanceDueDate),
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.maintenanceStatus == 'Overdue')
                        const Text('! Late  ',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700)),
                      Expanded(
                        child: Text(
                          item.maintenanceTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            const Icon(Icons.more_horiz, color: AppColors.ebonyClay),
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
