import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
//import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';

enum FilterType { all, overdue, upcoming, history }

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

  @override
  Widget build(BuildContext context) {
    final filteredTasks = getFilteredTasks();

    return AppLayout(
      currentIndex: 2, // Maintenance tab
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
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
                  onPressed: () {}, // TODO: add maintenance action
                  icon: const Icon(Icons.add_circle,color: AppColors.ebonyClay,size: 28,),
                  ),
              ],
            ),
            // FILTER BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton("All", FilterType.all),
                SizedBox(
                  height: 50,
                  child: const VerticalDivider(
                    width: 0, // The space allocated for the divider
                    thickness: 2, // The actual thickness of the line
                    indent: 10, // Space from the top of the parent to the divider's start
                    endIndent: 10, // Space from the bottom of the parent to the divider's end
                    color: Colors.grey, // Color of the divider line
                  ),),
                _buildFilterButton("Overdue", FilterType.overdue),
                SizedBox(
                  height: 50,
                  child: const VerticalDivider(
                    width: 6, // The space allocated for the divider
                    thickness: 2, // The actual thickness of the line
                    indent: 10, // Space from the top of the parent to the divider's start
                    endIndent: 10, // Space from the bottom of the parent to the divider's end
                    color: Colors.grey, // Color of the divider line
                  ),),
                _buildFilterButton("Upcoming", FilterType.upcoming),
                SizedBox(
                  height: 50,
                  child: const VerticalDivider(
                    width: 6, // The space allocated for the divider
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return ListTile(
                    title: Text(
                      task.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w100,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.start,
                      ),
                    subtitle: 
                    Row(
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w100,
                            overflow: TextOverflow.ellipsis,
                          ),
                          textAlign: TextAlign.start,
                          ),
                        SizedBox(
                          child:
                          SizedBox(
                            width: 22,
                            child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                          ),),
                        Text(
                          task.description,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w100,
                            overflow: TextOverflow.ellipsis,
                          ),
                          textAlign: TextAlign.start,
                          ),
                      ],
                    ),
                      trailing: 
                      // task.isOverdue
                      //   ? const Text("! Late", style: TextStyle(color: Colors.red))
                      //   : null,
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.isOverdue)
                            const Text("! Late", style: TextStyle(color: Colors.red)),
                          if (task.isHistory) ...[
                            const SizedBox(width: 5), // optional spacing
                            Icon(Icons.check, color: Colors.lightGreenAccent, size: 16),
                            const SizedBox(width: 3),
                            const Text("Completed", style: TextStyle(color: Colors.lightGreenAccent)),
                          ],
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
    return TextButton(
      onPressed: () {
        setState(() => selectedFilter = type);
      },
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black87,
          fontSize: 17,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
    );
  }
}
//     return Scaffold(
//       appBar: AppBar(title: Text("Maintenance"),
//       Text("Maintenance",
//         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//         color: Colors.black87,
//         fontWeight: FontWeight.w800,
//         ),
//         textAlign: TextAlign.center,
//       ),
//       //padding
//       const SizedBox(width: Spacing.md),
//       //addMaintenance button
//       Icon(Icons.add_circle, color: AppColors.ebonyClay, size: 28)
//       ],),
//       body:
//           Padding(
//             padding: const EdgeInsets.all(37.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextButton(
//                       onPressed: () => setState(() => selectedFilter = FilterType.all),
//                       child: Text("All"),
//                     ),
//                     SizedBox(
//                       height: 50,
//                       child: const VerticalDivider(
//                         width: 35, // The space allocated for the divider
//                         thickness: 2, // The actual thickness of the line
//                         indent: 10, // Space from the top of the parent to the divider's start
//                         endIndent: 10, // Space from the bottom of the parent to the divider's end
//                         color: Colors.grey, // Color of the divider line
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () => setState(() => selectedFilter = FilterType.overdue),
//                       child: Text("Overdue"),
//                     ),
//                     SizedBox(
//                       height: 50,
//                       child: const VerticalDivider(
//                         width: 35, // The space allocated for the divider
//                         thickness: 2, // The actual thickness of the line
//                         indent: 10, // Space from the top of the parent to the divider's start
//                         endIndent: 10, // Space from the bottom of the parent to the divider's end
//                         color: Colors.grey, // Color of the divider line
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () => setState(() => selectedFilter = FilterType.upcoming),
//                       child: Text("Upcoming"),
//                     ),
                    
//                     TextButton(
//                       onPressed: () => setState(() => selectedFilter = FilterType.history),
//                       child: Text("History"),
//                     ),
//                   ],
//                 ),



//                 // //PAGE NAV BAR
//                 // IntrinsicHeight(
//                 //   child:
                  
//                 //     Row(
//                 //       crossAxisAlignment: CrossAxisAlignment.center,
//                 //       children: [
//                 //         Text("All",
//                 //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 //           color: Colors.black87,
//                 //           fontSize: 17,
//                 //           decoration: TextDecoration.underline,
//                 //           fontWeight: FontWeight.w600,
//                 //           ),
//                 //           textAlign: TextAlign.center,
//                 //         ),
                              
//                 //         SizedBox(
//                 //           height: 50,
//                 //           child: const VerticalDivider(
//                 //             width: 35, // The space allocated for the divider
//                 //             thickness: 2, // The actual thickness of the line
//                 //             indent: 10, // Space from the top of the parent to the divider's start
//                 //             endIndent: 10, // Space from the bottom of the parent to the divider's end
//                 //             color: Colors.grey, // Color of the divider line
//                 //           ),
//                 //         ),
                              
//                 //         TextButton(
//                 //           onPressed: () {
//                 //             setState(() {
//                 //               bool isOverdue = true;
//                 //             });
//                 //           },
//                 //           child: Text("Overdue",
//                 //             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 //             color: Colors.black87,
//                 //             fontSize: 17,
//                 //             fontWeight: FontWeight.w600,
//                 //             ),
//                 //             textAlign: TextAlign.center,
//                 //           ),
//                 //         ),
                              
//                 //         SizedBox(
//                 //           height:50,
//                 //           child: const VerticalDivider(
//                 //             width: 35, // The space allocated for the divider
//                 //             thickness: 2, // The actual thickness of the line
//                 //             indent: 10, // Space   from the top of the parent to the divider's start
//                 //             endIndent: 10, // Space from the bottom of the parent to the divider's end
//                 //             color: Colors.grey, // Color of the divider line
//                 //           ),
//                 //         ),
                              
//                 //         Text("Upcoming",
//                 //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 //           color: Colors.black87,
//                 //           fontSize: 17,
//                 //           fontWeight: FontWeight.w600,
//                 //           ),
//                 //           textAlign: TextAlign.center,
//                 //         ),
                              
//                 //         SizedBox(
//                 //           height: 50,
//                 //           child: const VerticalDivider(
//                 //             width: 35, // The space allocated for the divider
//                 //             thickness: 2, // The actual thickness of the line
//                 //             indent: 10, // Space from the top of the parent to the divider's start
//                 //             endIndent: 10, // Space from the bottom of the parent to the divider's end
//                 //             color: Colors.grey, // Color of the divider line
//                 //           ),
//                 //         ),
                              
//                 //         Text("History",
//                 //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 //             color: Colors.black87,
//                 //             fontSize: 17,
//                 //             fontWeight: FontWeight.w600,
//                 //           ),
//                 //           textAlign: TextAlign.center,
//                 //         ),
//                 //       ],
//                 //     ),
//                 // ),
                
//                 const SizedBox(height: Spacing.md),
            
//                 Expanded(
//                   child: ListView(
//                     children:[
//                       //START OF CONTENT              
//                       Column(
//                         children:[
//                           //DAY ONE
//                           Row( //CALANDER DATE + FLAG 
//                             children: [
//                               Text("Aug. 12, 2025",
//                                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                     color: Colors.black87,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w800,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
                                
//                                 //padding
//                                 const SizedBox(width: Spacing.xs),
                      
//                                 //FLAG - Optional
//                                 //TODO : Give option to show or not
//                                 Visibility(
//                                   visible: isOverdue || isAll,
//                                   child:
//                                     Text("! Late",
//                                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Theme.of(context).colorScheme.error,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w800,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                 ) 
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pittsburgh Fiberglass Hammer"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Re-fasten hammer head"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
                      
//                           SizedBox(height: Spacing.lg),
                      
//                           //DAY TWO
//                           Row( //CALANDER DATE
//                             children: [
//                               Text("Oct. 01, 2025",
//                                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                     color: Colors.black87,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w800,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
                                
//                                 //right padding
//                                 const SizedBox(width: Spacing.xs),
                      
//                                 //FLAG - Optional
//                                 //TODO : Give option to show or not
//                                 Visibility(
//                                   visible: false,
//                                   child: 
//                                     Text("! Late",
//                                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Theme.of(context).colorScheme.error,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w600,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                   )
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Predator 350W Power Station"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Recharge Station"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
                      
                      
//                           SizedBox(height: Spacing.lg),
                      
//                           //DAY THREE
//                           Row( //CALANDER DATE
//                             children: [
//                               Text("Oct. 09, 2025",
//                                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                     color: Colors.black87,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w600,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
                                
//                                 //padding
//                                 const SizedBox(width: Spacing.xs),
                      
//                                 //FLAG - Optional
//                                 //TODO : Give option to show or not
//                                 Visibility(
//                                   visible: false,
//                                   child: 
//                                     Text("! Late",
//                                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Theme.of(context).colorScheme.error,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w600,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                   )
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pygmy Goat"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Vet Check Up"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pygmy Goat"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Buy big family size feed for the elderly goats ONLY"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pygmy Goat"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Trim Hooves"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
                      
//                           SizedBox(height: Spacing.lg),
                      
//                           //duplicate information
//                           Row( //CALANDER DATE
//                             children: [
//                               Text("Aug. 12, 2025",
//                                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                     color: Colors.black87,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w800,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
                                
//                                 //padding
//                                 const SizedBox(width: Spacing.xs),
                      
//                                 //FLAG - Optional
//                                 //TODO : Give option to show or not
//                                 Visibility(
//                                   visible: true,
//                                   child:
//                                     Text("! Late",
//                                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Theme.of(context).colorScheme.error,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w800,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                 ) 
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pittsburgh Fiberglass Hammer"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Re-fasten hammer head"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
                      
//                           SizedBox(height: Spacing.lg),
                      
//                           //DAY TWO
//                           Row( //CALANDER DATE
//                             children: [
//                               Text("Oct. 01, 2025",
//                                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                     color: Colors.black87,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w800,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
                                
//                                 //padding
//                                 const SizedBox(width: Spacing.xs),
                      
//                                 //FLAG - Optional
//                                 //TODO : Give option to show or not
//                                 Visibility(
//                                   visible: false,
//                                   child: 
//                                     Text("! Late",
//                                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Theme.of(context).colorScheme.error,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w600,
//                                           ),
//                                           textAlign: TextAlign.left,
//                                         ),
//                                   )
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Predator 350W Power Station"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Recharge Station"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
                      
                      
//                           SizedBox(height: Spacing.lg),
                      
//                           //DAY THREE
//                           Row( //CALANDER DATE
//                             children: [
//                               Text("Oct. 09, 2025",
//                                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                     color: Colors.black87,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w600,
//                                     ),
//                                     textAlign: TextAlign.left,
//                                   ),
                                
//                                 //padding
//                                 const SizedBox(width: Spacing.xs),
                      
                                
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pygmy Goat"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Vet Check Up"), 
//                                         ] 
//                                       ),
//                                       //FLAG - Optional
//                                       //TODO : Give option to show or not
//                                       // Visibility(
//                                       //   visible: false,
//                                       //   child: 
//                                       //     Text("! Late",
//                                       //           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                       //           color: Theme.of(context).colorScheme.error,
//                                       //           fontSize: 17,
//                                       //           fontWeight: FontWeight.w600,
//                                       //           ),
//                                       //           textAlign: TextAlign.left,
//                                       //         ),
//                                       //   )
//                                   ),
//                               ),
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pygmy Goat"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Buy big family size feed for the elderly goats ONLY"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
                                    
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pygmy Goat"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Trim Hooves"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
//                           Row( //DETAILS of the maintence task
//                             children: [
//                               SizedBox(
//                                 width: 324,
//                                 child:
//                                   RichText(
//                                     text:
//                                       //asset name
//                                       TextSpan(
//                                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                           color: Colors.black87,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w100,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         children: [
//                                           const TextSpan( text: "Pygmy Goat"),
                      
//                                           WidgetSpan(
//                                             alignment: PlaceholderAlignment.middle, 
//                                             child:
//                                             SizedBox(
//                                               width: 22,
//                                               child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
//                                             ),
//                                           ),
//                                           //maintenance short description
//                                           const TextSpan( text: "Trim Hooves"), 
//                                         ] 
//                                       ),
//                                   ),
//                               ),
//                             ],
//                           ),
//                         ]
//                       )
//                   ],    
//                           ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }
// }