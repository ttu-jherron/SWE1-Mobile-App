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
            Container(color: Colors.yellow),

            // Creates the top blue section
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                //Sets the height of the blue to 40% of the screen
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A323F),
                  //Curves the corners of the blue section
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  //Adds a margin of 15
                  padding: EdgeInsets.all(15),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      //Aligns the text to the left
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //Aligns the text to the top
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //"Hippo" text
                        Text(
                          "Hippo",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //"Exchange" text
                        Text(
                          "Exchange",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //Adds a 8px gap
                        SizedBox(height: 8),
                        //"don't buy. borrow." text
                        Text(
                          "don't buy. borrow.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //Aligns the image
            Align(
              alignment: const Alignment(0.0, -0.23),
              child: Container(
                //Adds a 8px thick yellow boarder
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                //Adds the image
                child: ClipRRect(
                  //Makes the image circular
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/images/screwdriverimg.jpg',
                    width: 125,
                    height: 125,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Login and sign up buttons
            Align(
              alignment: const Alignment(0.0, 0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => debugPrint("Login pressed!"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A323F),
                      foregroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => debugPrint("Sign Up pressed!"),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: const Color(0xFF2A323F),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Chatgpt used to clean the code up and center image
