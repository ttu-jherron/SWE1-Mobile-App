import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/routing.dart';
// import '../widgets/add_favorite.dart';
import '../widgets/asset_card.dart';
// import '../../../core/layout/app_layout.dart';
// import 'package:intl/intl.dart';

//Contains the code for the landing page
class MyAssetsPage extends StatelessWidget {
  const MyAssetsPage({Key? key}) : super(key: key);

  @override
  State<MyAssetsPage> createState() => MyAssetsPageState();
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Removes the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Testing',
      home: Scaffold(
        body: Column(
          children: [
            // Top section (15%)
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              color: AppColors.ebonyClay,
              padding: const EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              child: const Text(
                "HE",
                style: TextStyle(
                  color: AppColors.sandyYellow,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              color: AppColors.nearWhite,
              padding: EdgeInsets.fromLTRB(30, 10, 4, 10),
              alignment: Alignment.topLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "My Assets",
                      style: TextStyle(
                        color: AppColors.ebonyClay,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //add button
                    IconButton(
                      onPressed: () {
                        debugPrint("Add asset was pressed");
                      },
                      icon: const Icon(
                        Icons.add_circle_outline_sharp,
                        color: AppColors.ebonyClay,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            // Middle scrollable section
            Expanded(
              child: Container(
                color: AppColors.nearWhite,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap (
                            children: [
                              AssetCard(),
                              AssetCard(),
                              AssetCard(),
                              AssetCard(),
                              AssetCard(),
                              AssetCard(),
                              AssetCard(),
                              AssetCard(),
                            ]
                          ),
                        ]
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom bar (15%)
            Align(
              alignment: const Alignment(0.0, 1),
              child: Container(
                //Sets the height of the blue to 15% of the screen
                height: MediaQuery.of(context).size.height * 0.15,
                width:MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: AppColors.ebonyClay,
                ),
                child: Align(
                child: Padding(
                //Adds a margin of 15
                padding: EdgeInsets.all(8),
                child: Wrap(
                    children: [
                      //Login button
                      TextButton(
                        onPressed: () {
                          //Message confirming button was pressed
                          debugPrint("Home button pressed");
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.ebonyClay,
                          foregroundColor: AppColors.nearWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column (
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              color: AppColors.sandyYellow,
                              size: 24.0,
                              semanticLabel: 'Image of a house',
                            ),
                            Text(
                              "Home",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ]
                        )
                      ),
                      //Adds a 8px gap between buttons
                      SizedBox(width: Spacing.sm),
                      //Sign up button
                      TextButton(
                          onPressed: () {
                            //Message confirming button was pressed
                            debugPrint("My assets button pressed");
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.ebonyClay,
                            foregroundColor: AppColors.nearWhite,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column (
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.agriculture_outlined,
                                color: AppColors.sandyYellow,
                                size: 24.0,
                                semanticLabel: 'Image of a tractor',
                              ),
                              Text(
                                "My Assets",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                           ]
                          )
                        ),
                        SizedBox(width: Spacing.sm),
                        TextButton(
                          onPressed: () {
                          //Message confirming button was pressed
                          debugPrint("Profile button pressed");
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.ebonyClay,
                          foregroundColor: AppColors.nearWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column (
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              color: AppColors.sandyYellow,
                              size: 24.0,
                              semanticLabel: 'Image of profile',
                            ),
                            Text(
                              "Profile",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ]
                        )
                      ),
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

// class AssetCard extends StatefulWidget {
//   final VoidCallback? onTap; // 👈 allows you to pass a function when tapped

//   const AssetCard({Key? key, this.onTap}) : super(key: key);

//   @override
//   State<AssetCard> createState() => _AssetCardState();
// }

// class _AssetCardState extends State<AssetCard> {
//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: const BoxConstraints(
//         minWidth: 140,
//         maxWidth: 140,
//         minHeight: 60,
//       ),
//       child: Card(
//         elevation: 0,
//         color: AppColors.nearWhite,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(4), // ripple follows shape
//           onTap: widget.onTap ?? () {
//             debugPrint("AssetCard tapped");
//           },
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(4, 10, 4, 10), // tighter padding
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image placeholder with its own Card aesthetic
//                 Card(
//                   margin: EdgeInsets.zero,
//                   color: AppColors.nearWhite,
//                   child: const SizedBox(
//                     height: 75,
//                     width: double.infinity,
//                     child: Center(
//                       child: Icon(
//                         Icons.image,
//                         size: 40,
//                         semanticLabel: 'Image of missing image',
//                         color: AppColors.ebonyClay,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: Spacing.xs),
//                 // Row with text + favorite
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text(
//                       "Predator",
//                       style: TextStyle(
//                         color: AppColors.ebonyClay,
//                         fontSize: 14,
//                         height: 1.0,
//                       ),
//                     ),
//                     AddFavorite(),
//                   ],
//                 ),
//                 SizedBox(width: Spacing.xs),
//                 // Description
//                 Text(
//                   "350 Power Station",
//                   style: TextStyle(
//                     color: AppColors.ebonyClay,
//                     fontSize: 14,
//                     height: 1.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// class AddFavorite extends StatefulWidget {
//   const AddFavorite({Key? key}) : super(key: key);

//   @override
//   State<AddFavorite> createState() => _AddFavoriteState();
// }

// class _AddFavoriteState extends State<AddFavorite> {
//   bool _isClicked = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent, // still tappable
//       onTap: () {
//         setState(() {
//           _isClicked = !_isClicked;
//         });
//       },
//       child: Icon(
//         _isClicked ? Icons.favorite : Icons.favorite_border,
//         color: _isClicked ? Colors.red : AppColors.ebonyClay,
//         size: 14, // exact match to your text size
//       ),
//     );
//   }
// }