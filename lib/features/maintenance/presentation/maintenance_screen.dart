import 'package:flutter/material.dart';
import 'package:mobile_app/features/assets/data/asset_store.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:intl/intl.dart';
import 'add_maintenance_sheet.dart';
import '../data/maintenance_store.dart';
import '../data/maintenance_entry.dart';

enum FilterType { all, overdue, upcoming, completed }
DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});
  
  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  String _selectedFilter = 'All'; // or whatever your default is
  String? selectedAssetId;
  final _df = DateFormat('MMM dd, yyyy');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['filter'] != null) {
      setState(() {
        _selectedFilter = args['filter'];
      });
    }
    initializeMaintenanceStore(context);
    maintenanceStore.refresh(force: false);
  }

  List<MaintenanceEntry> getFilteredTasks() {
    List<MaintenanceEntry> allEntries;
    if (selectedAssetId != null) {
      allEntries = maintenanceStore.allFor(selectedAssetId!);
    } else {
      allEntries = maintenanceStore.getAll();
    }
    switch (_selectedFilter) {
      case 'Overdue':
        return allEntries.where((entry) => entry.maintenanceStatus == 'Overdue').toList();
      case 'Upcoming':
        return allEntries.where((entry) => entry.maintenanceStatus == 'Upcoming').toList();
      case 'Completed':
        return allEntries.where((entry) => entry.maintenanceStatus == 'Completed').toList();
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

  Future<void> _selectAsset() async {
    final assets = assetStore.all;
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Asset'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('All Assets'),
            ),
            ...assets().map((asset) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, asset.id),
              child: Text('${asset.brand} ${asset.name}'),
            )),
          ],
        );
      },
    );
    setState(() {
      selectedAssetId = chosen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: maintenanceStore,
      builder: (context, _) {
        final items = sortedTasksAsc;
        String assetName;
        if (selectedAssetId == null) {
          assetName = 'All Assets';
        } else {
          final asset = assetStore.getById(selectedAssetId!);
          assetName = asset != null ? '${asset.brand} ${asset.name}' : 'Unknown Asset';
        }

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
                      "Maintenance",
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
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => const AddMaintenanceSheet(),
                        );
                        maintenanceStore.refresh(force: true);
                      },
                    ),
                  ],
                ),
                // Clickable asset name below header
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: TextButton(
                    onPressed: _selectAsset,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.black54,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          assetName,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 16, color: Colors.black38),
                      ],
                    ),
                  ),
                ),

                // Filter buttons
                Wrap(
                  spacing: Spacing.lg,
                  children: [
                    _buildFilterButton('All', 'All'),
                    _buildFilterButton('Overdue', 'Overdue'),
                    _buildFilterButton('Upcoming', 'Upcoming'),
                    _buildFilterButton('Completed', 'Completed'),
                  ],
                ),

                const SizedBox(height: Spacing.lg),

                // List
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            selectedAssetId == null
                              ? 'No maintenance found.'
                              : 'No maintenance found for this asset.',
                            style: const TextStyle(color: Colors.black54),
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

  Widget _buildFilterButton(String text, String filter) {
    final isSelected = _selectedFilter == filter;
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: isSelected ? AppColors.ebonyClay : Colors.black45,
      ),
      onPressed: () => setState(() => _selectedFilter = filter),
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