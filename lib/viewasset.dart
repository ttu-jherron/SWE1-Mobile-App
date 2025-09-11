import 'package:flutter/material.dart';

//Runs the Program
void main() {
  runApp(const LandingPage());
}

//Cantains the code for the landing page
class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Removes the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Testing',
      home: Scaffold(
        body: Column(
          children: [
            // Sets the background color to white
            Container(color: Colors.white),

            // Creates the top blue section
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                //Sets the height of the blue to 15% of the screen
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A323F),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      //Aligns the text to the left
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //Aligns the text to the top
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //"HE" text
                        Text(
                          "HE",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                                color: Color(0xFF2A323F),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Name of asset and favorite button
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              //Favorite button
                              AddFavorite(),
                              //Name of asset
                              Text(
                                "Pygmy Goat",
                                style: TextStyle(
                                  color: Color(0xFF2A323F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Condition of asset
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text condition
                          child: Text(
                            "Condition:",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text condition of asset
                          child: Text(
                            "Healthy",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
                              fontSize: 16
                              ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Location of asset
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text location
                          child: Text(
                            "Location:",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text location of asset
                          child: Text(
                            "My neighbor Phil",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
                              fontSize: 16
                              ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Where asset was bought from
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text bought from
                          child: Text(
                            "Bought From:",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text where asset was bought from
                          child: Text(
                            "Sale Barn - Triple Double Arena\n1234 Street Dr, Cookeville, TN, 38501\n(123) - 456 - 7890",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
                              fontSize: 16
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Price of asset
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text price
                          child: Text(
                            "Price:",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          //Text price of asset
                          child: Text(
                            "\$1,234.56",
                            style: TextStyle(
                              color: Color(0xFF2A323F),
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
                                    color: Color(0xFF2A323F),
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
                                      color: Color(0xFF2A323F),
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
                            backgroundColor: const Color(0xFF2A323F),
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
            Align(
              alignment: const Alignment(0.0, 1),
              child: Container(
                //Sets the height of the blue to 15% of the screen
                height: MediaQuery.of(context).size.height * 0.15,
                width:MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A323F),
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
                          backgroundColor: Color(0xFF2A323F),
                          foregroundColor: Colors.white,
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
                              color: Colors.yellow,
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
                      SizedBox(width: 10),
                      //Sign up button
                      TextButton(
                          onPressed: () {
                            //Message confirming button was pressed
                            debugPrint("My assets button pressed");
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF2A323F),
                            foregroundColor: Colors.white,
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
                                color: Colors.yellow,
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
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                          //Message confirming button was pressed
                          debugPrint("Profile button pressed");
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF2A323F),
                          foregroundColor: Colors.white,
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
                              color: Colors.yellow,
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

class AddFavorite extends StatefulWidget {
  const AddFavorite({Key? key}) : super(key: key);

  @override
  State<AddFavorite> createState() => _AddFavoriteState();
}

class _AddFavoriteState extends State<AddFavorite> {
  bool _isClicked = false; // state variable

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero, // remove extra padding so it aligns better
      constraints: const BoxConstraints(), // shrink clickable area
      icon: Icon(
        _isClicked ? Icons.favorite : Icons.favorite_border,
        color: _isClicked ? Colors.red : Color(0xFF2A323F),
        size: 22,
      ),
      onPressed: () {
        setState(() {
          _isClicked = !_isClicked; // flip state on click
        });
      },
    );
  }
}

class MaintenanceCard extends StatefulWidget {
  const MaintenanceCard({Key? key}) : super(key: key);

  @override
  State<MaintenanceCard> createState() => _MaintenanceCardState();
}

class _MaintenanceCardState extends State<MaintenanceCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 150,
        // minHeight: 40,
      ),
      child: Card(
        elevation: 0,
        color: const Color(0xFFF5F5F5),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Color(0xFF2A323F),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(0,0,10,2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Oct. 01, 2025",
                style: TextStyle(
                  color: Color(0xFF2A323F),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Take to vet",
                style: TextStyle(
                  color: Color(0xFF2A323F),
                  fontSize: 14,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

