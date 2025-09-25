import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
//import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:intl/intl.dart';

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

  final List<Task> tasks = [
    Task(title: "Pittsburgh Hammer", description: "Re-fasten hammer head", date: DateTime(2025,9,12), isOverdue: true),
    Task(title: "Pittsburgh Fiberglass Hammer", description: "Re-fasten hammer head", date: DateTime(2025,8,12), isHistory: true),
    Task(title: "Predator 350W Power Station", description: "Recharge Station", date: DateTime(2025,9,1), isHistory: true),
    Task(title: "Pygmy Goat", description: "Vet Check Up", date: DateTime(2025,9,12), isHistory: true),
    Task(title: "Pygmy Goat", description: "Buy big family size feed for the elderly goats ONLY", date: DateTime(2025,10,9), isHistory: true),
    Task(title: "Pygmy Goat", description: "Trim Hooves", date: DateTime(2025,10,14), isHistory: true),
    Task(title: "Power Station", description: "Recharge station", date: DateTime(2025,10,1), isUpcoming: true),
    Task(title: "Pygmy Goat", description: "Vet checkup", date: DateTime(2025,4,21), isHistory: true),
    Task(title: "Pittsburgh Fiberglass Hammer", description: "Re-fasten hammer head", date: DateTime(2025,11,30), isUpcoming: true),
    Task(title: "Predator 350W Power Station", description: "Recharge Station", date: DateTime(2025,11,17), isUpcoming: true),
    Task(title: "Pygmy Goat", description: "Vet Check Up", date: DateTime(2025,12,23), isUpcoming: true),
    Task(title: "Pygmy Goat", description: "Buy big family size feed for the elderly goats ONLY", date: DateTime(2026,1,3), isUpcoming: true),
    Task(title: "Pygmy Goat", description: "Trim Hooves", date: DateTime(2026,1,7), isUpcoming: true),
  ];

  List<Task> getFilteredTasks() {
    switch (selectedFilter) {
      case FilterType.overdue:
        return tasks.where((t) => t.isOverdue).toList();
      case FilterType.upcoming:
        return tasks.where((t) => t.isUpcoming).toList();
      case FilterType.history:
        return tasks.where((t) => t.isHistory).toList();
      default:
        return tasks;
    }
  }

  List<Task> get sortedTasksAsc {
    List<Task> filteredTasks = getFilteredTasks();
    final tasksCopy = List<Task>.from(filteredTasks);
    tasksCopy.sort((a, b) => a.date.compareTo(b.date));
    return tasksCopy;
  }

  //TODO: function for making the date

  @override
  Widget build(BuildContext context) {

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
                  onPressed: () {}, // TODO: add maintenance routing page
                  icon: const Icon(Icons.add_circle,color: AppColors.ebonyClay,size: 28,),
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
              child: ListView.builder(//makes it scroll
                itemCount: sortedTasksAsc.length,
                itemBuilder: (context, index) {
                  final task = sortedTasksAsc[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    //Due Date
                    title: 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Flexible(
                        child: Text(  
                          DateFormat('MMM dd, yyyy').format(task.date),
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
                      if (task.isOverdue)
                        const Text("! Late", style: TextStyle(color: Colors.red)),
                      if (task.isHistory) ...[
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
                                TextSpan(text: task.title),
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
                                TextSpan(text: task.description), 
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

  Widget _buildFilterButton(String text, FilterType type) {
    double underlineThickness =  1;
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // removes all default padding
        minimumSize: Size(0, 0),  // prevents extra space
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // tighter tap area
      ),
      onPressed: () {
        setState((){  
          selectedFilter = type;
          underlineThickness = 0.0;}
        );
      },
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black87,
          fontSize: TypographyScale.button,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: Colors.black87,
          decorationThickness: underlineThickness,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}