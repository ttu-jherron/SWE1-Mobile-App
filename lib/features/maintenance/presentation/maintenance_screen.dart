import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
//import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';


class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 2, // Maintenance tab
      body:
          ListView(
            padding: const EdgeInsets.all(8.0),
            children:[
              //PAGE TITLE
              Row(
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
                  Icon(Icons.add_circle, color: AppColors.ebonyClay, size: 28)
                  ],
              ),
                
              const SizedBox(height: 14),
              //PAGE NAV BAR
              IntrinsicHeight(
                child:
                  Row(
                    children: [
                      Text("All",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                            
                      //divider
                      //const SizedBox(width: Spacing.xs),
                            
                      SizedBox(
                        height: 40,
                        child: const VerticalDivider(
                          width: 20, // The space allocated for the divider
                          thickness: 2, // The actual thickness of the line
                          indent: 10, // Space from the top of the parent to the divider's start
                          endIndent: 10, // Space from the bottom of the parent to the divider's end
                          color: Colors.grey, // Color of the divider line
                        ),
                      ),
                            
                      //const SizedBox(width: Spacing.xs),
                            
                      Text("Overdue",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                            
                      SizedBox(
                        height: 40,
                        child: const VerticalDivider(
                          width: 7, // The space allocated for the divider
                          thickness: 2, // The actual thickness of the line
                          indent: 10, // Space   from the top of the parent to the divider's start
                          endIndent: 10, // Space from the bottom of the parent to the divider's end
                          color: Colors.grey, // Color of the divider line
                        ),
                      ),
                            
                      //padding
                      const SizedBox(width: Spacing.xs),
                            
                      Text("Upcoming",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                            
                      SizedBox(
                        height: 40,
                        child: const VerticalDivider(
                          width: 7, // The space allocated for the divider
                          thickness: 2, // The actual thickness of the line
                          indent: 10, // Space from the top of the parent to the divider's start
                          endIndent: 10, // Space from the bottom of the parent to the divider's end
                          color: Colors.grey, // Color of the divider line
                        ),
                      ),
                            
                      //padding
                      const SizedBox(width: Spacing.xs),
                            
                      Text("History",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ),              
              
              const SizedBox(height: 45),
              
              //START OF CONTENT              
              Column(
                children:[
                  //DAY ONE
                  Row( //CALANDER DATE + FLAG 
                    children: [
                      Text("Aug. 12, 2025",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        
                        //padding
                        const SizedBox(width: Spacing.xs),
              
                        //FLAG - Optional
                        //TODO : Give option to show or not
                        Visibility(
                          visible: true,
                          child:
                            Text("! Late",
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                        ) 
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pittsburgh Fiberglass Hammer"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Re-fasten hammer head"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
              
                  SizedBox(height: Spacing.lg),
              
                  //DAY TWO
                  Row( //CALANDER DATE
                    children: [
                      Text("Oct. 01, 2025",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        
                        //padding
                        const SizedBox(width: Spacing.xs),
              
                        //FLAG - Optional
                        //TODO : Give option to show or not
                        Visibility(
                          visible: false,
                          child: 
                            Text("! Late",
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                          )
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Predator 350W Power Station"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Recharge Station"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
              
              
                  SizedBox(height: Spacing.lg),
              
                  //DAY THREE
                  Row( //CALANDER DATE
                    children: [
                      Text("Oct. 09, 2025",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        
                        //padding
                        const SizedBox(width: Spacing.xs),
              
                        //FLAG - Optional
                        //TODO : Give option to show or not
                        Visibility(
                          visible: false,
                          child: 
                            Text("! Late",
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                          )
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pygmy Goat"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Vet Check Up"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pygmy Goat"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Buy big family size feed for the elderly goats ONLY"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pygmy Goat"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Trim Hooves"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
              
                  SizedBox(height: Spacing.lg),
              
                  //duplicate information
                  Row( //CALANDER DATE
                    children: [
                      Text("Aug. 12, 2025",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        
                        //padding
                        const SizedBox(width: Spacing.xs),
              
                        //FLAG - Optional
                        //TODO : Give option to show or not
                        Visibility(
                          visible: true,
                          child:
                            Text("! Late",
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                        ) 
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pittsburgh Fiberglass Hammer"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Re-fasten hammer head"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
              
                  SizedBox(height: Spacing.lg),
              
                  //DAY TWO
                  Row( //CALANDER DATE
                    children: [
                      Text("Oct. 01, 2025",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        
                        //padding
                        const SizedBox(width: Spacing.xs),
              
                        //FLAG - Optional
                        //TODO : Give option to show or not
                        Visibility(
                          visible: false,
                          child: 
                            Text("! Late",
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                          )
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Predator 350W Power Station"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Recharge Station"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
              
              
                  SizedBox(height: Spacing.lg),
              
                  //DAY THREE
                  Row( //CALANDER DATE
                    children: [
                      Text("Oct. 09, 2025",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        
                        //padding
                        const SizedBox(width: Spacing.xs),
              
                        //FLAG - Optional
                        //TODO : Give option to show or not
                        Visibility(
                          visible: false,
                          child: 
                            Text("! Late",
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                          )
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pygmy Goat"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Vet Check Up"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pygmy Goat"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Buy big family size feed for the elderly goats ONLY"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
                  Row( //DETAILS of the maintence task
                    children: [
                      SizedBox(
                        width: 324,
                        child:
                          RichText(
                            text:
                              //asset name
                              TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w100,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  const TextSpan( text: "Pygmy Goat"),
              
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle, 
                                    child:
                                    SizedBox(
                                      width: 22,
                                      child: Icon(Icons.circle, color: AppColors.ebonyClay, size: 5, ),
                                    ),
                                  ),
                                  //maintenance short description
                                  const TextSpan( text: "Trim Hooves"), 
                                ] 
                              ),
                          ),
                      ),
                    ],
                  ),
                ]
              )
          ],    
        ),
    );
  }
}