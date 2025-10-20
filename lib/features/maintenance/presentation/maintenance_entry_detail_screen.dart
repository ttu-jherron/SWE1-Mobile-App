import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/routing.dart';
import 'package:intl/intl.dart';
import '../data/maintenance_entry.dart';

class MaintenanceEntryDetailScreen extends StatefulWidget {
  final MaintenanceEntry entry;

  const MaintenanceEntryDetailScreen({super.key, required this.entry});

  @override
  State<MaintenanceEntryDetailScreen> createState() => _MaintenanceEntryDetailScreenState();
}

class _MaintenanceEntryDetailScreenState extends State<MaintenanceEntryDetailScreen> {
  late MaintenanceEntry _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
  }

  @override
  void didUpdateWidget(MaintenanceEntryDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != widget.entry) {
      _currentEntry = widget.entry;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _df = DateFormat('MMM dd, yyyy');

    return AppLayout(
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentEntry.maintenanceTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 3, // Allow wrapping up to 3 lines
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
              decoration: BoxDecoration(
                color: _currentEntry.maintenanceStatus == 'Overdue'
                    ? Colors.red.withOpacity(0.1)
                    : _currentEntry.maintenanceStatus == 'Completed'
                        ? Colors.green.withOpacity(0.1)
                        : _currentEntry.maintenanceStatus == 'Upcoming'
                            ? AppColors.darkGold.withOpacity(0.1)
                            : AppColors.ebonyClay.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentEntry.maintenanceStatus,
                style: TextStyle(
                  color: _currentEntry.maintenanceStatus == 'Overdue'
                      ? Colors.red
                      : _currentEntry.maintenanceStatus == 'Completed'
                          ? Colors.green
                          : _currentEntry.maintenanceStatus == 'Upcoming'
                              ? AppColors.darkGold
                              : AppColors.ebonyClay,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Due Date
            _buildDetailRow('Due Date', _df.format(_currentEntry.maintenanceDueDate)),
            const SizedBox(height: Spacing.md),

            // Description
            _buildDetailRow('Description', _currentEntry.maintenanceDescription),
            const SizedBox(height: Spacing.md),

            // Asset Info
            _buildDetailRow('Asset', '${_currentEntry.brandName} ${_currentEntry.productName}'),
            const SizedBox(height: Spacing.md),

            // Category
            _buildDetailRow('Category', _currentEntry.assetCategory),
            const SizedBox(height: Spacing.md),

            // Cost
            _buildDetailRow('Cost Paid', '\$${_currentEntry.costPaid.toStringAsFixed(2)}'),
            const SizedBox(height: Spacing.md),

            // Completed
            _buildDetailRow('Completed', _currentEntry.isCompleted ? 'Yes' : 'No'),
            const SizedBox(height: Spacing.xl),

            // Edit Button
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.maintenanceEdit, arguments: _currentEntry);
                if (result is MaintenanceEntry) {
                  setState(() {
                    _currentEntry = result;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ebonyClay,
                foregroundColor: AppColors.sandyYellow,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
              ),
              child: const Text('Edit Maintenance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}