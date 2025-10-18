import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
//import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:intl/intl.dart';
//import 'edit_maintenance.dart';
import 'add_maintenance_sheet.dart';
import '../data/maintenance_store.dart';
import '../data/maintenance_entry.dart';

enum FilterType { all, overdue, upcoming, history }
DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);

class Task {
  final String title;
  final String description;
  final DateTime date;
  final bool isOverdue;
  final bool isUpcoming;
  final bool isHistory;

  Task({
    required this.title,
    required this.description,
    required this.date,
    this.isOverdue = false,
    this.isUpcoming = false,
    this.isHistory = false,
  });
}

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});
  
  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  FilterType selectedFilter = FilterType.all;

  @override
  void initState() {
    super.initState();
    // Initialize maintenance store
    initializeMaintenanceStore(context);
  }

  List<MaintenanceEntry> getFilteredTasks() {
    final allEntries = maintenanceStore.getAll();
    switch (selectedFilter) {
      case FilterType.overdue:
        return allEntries.where((entry) => entry.maintenanceStatus == 'Overdue').toList();
      case FilterType.upcoming:
        return allEntries.where((entry) => entry.maintenanceStatus == 'Upcoming').toList();
      case FilterType.history:
        return allEntries.where((entry) => entry.isCompleted).toList();
      default:
        return allEntries;
    }
  }

  List<MaintenanceEntry> get sortedTasksAsc {
    List<MaintenanceEntry> filteredTasks = getFilteredTasks();
    final tasksCopy = List<MaintenanceEntry>.from(filteredTasks);
    tasksCopy.sort((a, b) => a.maintenanceDueDate.compareTo(b.maintenanceDueDate));
    return tasksCopy;
  }

  //TODO: function for making the date

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: maintenanceStore,
      builder: (context, _) {
        return AppLayout(
          currentIndex: 2, // Maintenance tab
          body: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Maintenance",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    //padding
                    const SizedBox(width: Spacing.md),
                    //addMaintenance button
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (_) => const AddMaintenanceSheet(),
                        );
                      },
                      icon: const Icon(Icons.add_circle, color: AppColors.ebonyClay, size: 28),
                    ),

                  ],
                ),
                // FILTER BUTTONS
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center ,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _buildFilterButton("All", FilterType.all),
                    SizedBox(
                      height: 50,
                      child: const VerticalDivider(
                        width: 35, // The space allocated for the divider
                        thickness: 2, // The actual thickness of the line
                        indent: 10, // Space from the top of the parent to the divider's start
                        endIndent: 10, // Space from the bottom of the parent to the divider's end
                        color: Colors.grey, // Color of the divider line
                      ),),
                    _buildFilterButton("Overdue", FilterType.overdue),
                    SizedBox(
                      height: 50,
                      child: const VerticalDivider(
                        width: 35, // The space allocated for the divider
                        thickness: 2, // The actual thickness of the line
                        indent: 10, // Space from the top of the parent to the divider's start
                        endIndent: 10, // Space from the bottom of the parent to the divider's end
                        color: Colors.grey, // Color of the divider line
                      ),),
                    _buildFilterButton("Upcoming", FilterType.upcoming),
                    SizedBox(
                      height: 50,
                      child: const VerticalDivider(
                        width: 35, // The space allocated for the divider
                        thickness: 2, // The actual thickness of the line
                        indent: 10, // Space from the top of the parent to the divider's start
                        endIndent: 10, // Space from the bottom of the parent to the divider's end
                        color: Colors.grey, // Color of the divider line
                      ),),
                    _buildFilterButton("History", FilterType.history),
                  ],
                ),
            
                const SizedBox(height: 20),
            
                // LIST OF TASKS
                Expanded( //everything will dissapear if this is removed
                  child: sortedTasksAsc.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.build,
                              size: 48,
                              color: Color(0xFF9AA3AD),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No maintenance items yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF3C4652),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add maintenance schedules to your assets.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF3C4652)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(//makes it scroll
                        itemCount: sortedTasksAsc.length,
                        itemBuilder: (context, index) {
                          final entry = sortedTasksAsc[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            //Due Date
                            title:
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              Flexible(
                                child: Text(
                                  DateFormat('MMM dd, yyyy').format(entry.maintenanceDueDate),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.black87,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  textAlign: TextAlign.start,
                                  ),
                              ),
                              const SizedBox(width: Spacing.xs),
                              if (entry.maintenanceStatus == 'Overdue')
                                const Text("! Late", style: TextStyle(color: Colors.red)),
                              if (entry.isCompleted) ...[
                                const SizedBox(width: 5), // optional spacing
                                Icon(Icons.check, color: Colors.green, size: 16),
                                const SizedBox(width: 3),
                                const Text("Completed", style: TextStyle(color: Colors.green)),
                              ],
                            ],),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text:
                                    TextSpan(
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Colors.black87,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w100,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      children: [
                                        TextSpan(text: entry.maintenanceTitle),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: //circle icon
                                          SizedBox(
                                            width: 22,
                                            child: Center(
                                              child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5)
                                            ),
                                          ),
                                        ),
                                        //maintenance short description
                                        TextSpan(text: entry.maintenanceDescription),
                                      ]
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          )
        );
      }
    );
  }

  Widget _buildFilterButton(String text, FilterType type) {
    final isSelected = selectedFilter == type;
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // removes all default padding
        minimumSize: Size(0, 0),  // prevents extra space
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tighter tap area
      ),
      onPressed: () {
        setState(() {
          selectedFilter = type;
        });
      },
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black87,
          fontSize: TypographyScale.button,
          fontWeight: FontWeight.w600,
          decoration: isSelected ? TextDecoration.underline : TextDecoration.none,
          decorationColor: Colors.black87,
          decorationThickness: 2.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}