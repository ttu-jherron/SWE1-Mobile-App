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
        body: Stack(
          children: [
            // Sets the background color to yellow
            Container(color: Colors.white),

            // Creates the top blue section
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                //Sets the height of the blue to 10% of the screen
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A323F),
                ),
                child: Padding(
                  //Adds a margin of 15
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      //Aligns the text to the left
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //Aligns the text to the top
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //"Hippo" text
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
            Align(
              alignment: const Alignment(0.0, 1),
              child: Container(
                //Sets the height of the blue to 10% of the screen
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A323F),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.0, .95),
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
          ],
        ),
      ),
    );
  }
}