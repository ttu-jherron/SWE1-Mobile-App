import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:intl/intl.dart';
import 'add_maintenance_sheet.dart';
import '../data/maintenance_store.dart';
import '../data/maintenance_entry.dart';

enum FilterType { all, overdue, upcoming, history }
DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);

class AssetMaintenanceScreen extends StatefulWidget {
  final String assetId;
  const AssetMaintenanceScreen({super.key, required this.assetId});

  @override
  State<AssetMaintenanceScreen> createState() => _AssetMaintenanceScreenState();
}

class _AssetMaintenanceScreenState extends State<AssetMaintenanceScreen> {
  FilterType selectedFilter = FilterType.all;
  final _df = DateFormat('MMM dd, yyyy');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize and kick a fetch whenever we enter this route
    initializeMaintenanceStore(context);
    maintenanceStore.refresh(force: false);
  }

  List<MaintenanceEntry> getFilteredTasks() {
    final allEntries = maintenanceStore.allFor(widget.assetId);
    switch (selectedFilter) {
      case FilterType.overdue:
        return allEntries.where((entry) => entry.maintenanceStatus == 'Overdue').toList();
      case FilterType.upcoming:
        return allEntries.where((entry) => entry.maintenanceStatus == 'Upcoming').toList();
      case FilterType.history:
        return allEntries.where((entry) => entry.isCompleted || entry.maintenanceStatus == 'Completed').toList();
      default:
        return allEntries;
    }
  }

  List<MaintenanceEntry> get sortedTasksAsc {
    final filtered = getFilteredTasks();
    final tasksCopy = List<MaintenanceEntry>.from(filtered);
    tasksCopy.sort((a, b) => a.maintenanceDueDate.compareTo(b.maintenanceDueDate));
    return tasksCopy;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: maintenanceStore,
      builder: (context, _) {
        final items = sortedTasksAsc;
        return AppLayout(
          currentIndex: 2,
          body: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Text(
                      "Asset Maintenance",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Add maintenance',
                      icon: const Icon(Icons.add_circle, color: AppColors.ebonyClay, size: 28),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFF2A323F), // Dark navy background
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => const AddMaintenanceSheet(),
                        );
                        // Refresh after closing sheet in case something changed
                        maintenanceStore.refresh(force: true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),

                // Filter buttons
                Wrap(
                  spacing: Spacing.lg,
                  children: [
                    _buildFilterButton('All', FilterType.all),
                    _buildFilterButton('Overdue', FilterType.overdue),
                    _buildFilterButton('Upcoming', FilterType.upcoming),
                    _buildFilterButton('History', FilterType.history),
                  ],
                ),

                const SizedBox(height: Spacing.lg),

                // List
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'No maintenance found for this asset.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                          itemBuilder: (context, index) {
                            final e = items[index];
                            final statusColor = e.maintenanceStatus == 'Overdue'
                                ? Colors.red
                                : e.maintenanceStatus == 'Completed'
                                    ? Colors.green
                                    : e.maintenanceStatus == 'Upcoming'
                                        ? AppColors.darkGold
                                        : AppColors.ebonyClay;

                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.maintenanceEntryDetail,
                                  arguments: e,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(Spacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.build_circle, color: statusColor),
                                    const SizedBox(width: Spacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.maintenanceTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_df.format(e.maintenanceDueDate)} • ${e.maintenanceStatus}',
                                            style: TextStyle(color: statusColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: Spacing.sm),
                                    const Icon(Icons.chevron_right, color: AppColors.ebonyClay),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String text, FilterType type) {
    final isSelected = selectedFilter == type;
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: isSelected ? AppColors.ebonyClay : Colors.black45,
      ),
      onPressed: () => setState(() => selectedFilter = type),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}