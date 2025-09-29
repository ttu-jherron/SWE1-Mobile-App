import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../widgets/add_favorite.dart';
import '../widgets/add_maintenance.dart';

class ViewAssetPage extends StatelessWidget {
  final String strAssetId;
  final String strName;
  final String strCondition;
  final String strLocation;
  final String strBoughtFrom;
  final String strPrice;

  const ViewAssetPage({
    Key? key,
    required this.strAssetId,
    required this.strName,
    required this.strCondition,
    required this.strLocation,
    required this.strBoughtFrom,
    required this.strPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
            //Scrollable middle section
            Expanded(
              child: Stack (
                children: [
                  Container(
                  color: Color(0xFFF5F5F5),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image card
                        Card(
                          color: const Color(0xFFD9D9D9),
                          child: SizedBox(
                            height: 175,
                            width: double.infinity,
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: AppColors.ebonyClay,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Name of asset and favorite button
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              //Favorite button
                              AddFavorite(intSize: 18),
                              //Name of asset
                              Text(
                                strName,
                                style: TextStyle(
                                  color: AppColors.ebonyClay,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.ebonyClay,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Condition of asset
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text condition
                          child: Text(
                            "Condition:",
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text condition of asset
                          child: Text(
                            strCondition,
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 16
                              ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Location of asset
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text location
                          child: Text(
                            "Location:",
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text location of asset
                          child: Text(
                            strLocation,
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 16
                              ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Where asset was bought from
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text bought from
                          child: Text(
                            "Bought From:",
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text where asset was bought from
                          child: Text(
                            strBoughtFrom,
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 16
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Price of asset
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text price
                          child: Text(
                            "Price:",
                            style: TextStyle(
                              color:AppColors.ebonyClay,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text price of asset
                          child: Text(
                            strPrice,
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 16
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Planned Maintenance and add button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Text planned maintenance
                                const Text(
                                  "Planned Maintenance",
                                  style: TextStyle(
                                    color: AppColors.ebonyClay,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                //add button
                                SizedBox(
                                  height: 26, // or whatever you want
                                  width: 24,
                                  child: IconButton(
                                    onPressed: () {
                                      debugPrint("Add maintenance pressed");
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.add_circle_outline_sharp,
                                      color: AppColors.ebonyClay,
                                      size: 20,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                      // Scrollable row of cards
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        //Row of upcoming maintenance
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 55.0),
                          child: Row(
                            children: const [
                              MaintenanceCard(),
                              MaintenanceCard(),
                              MaintenanceCard(),
                              MaintenanceCard(),
                            ],
                          ),
                        ),
                      ),
                      //Edit asset button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical:10.0),
                        child: ElevatedButton(
                          onPressed: () => debugPrint("Edit Asset pressed!"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ebonyClay,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Edit Asset",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 250,
                  bottom: 0,
                  width: 60, // width of wall, same as horizontal padding
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 250,
                  bottom: 0,
                  width: 60, // same as horizontal padding
                  child: Container(
                    color: const Color(0xFFF5F5F5),
                  ),
                ),
                ]
              ),
            ),
          ],
        ),
      // ),
    );
  }
}