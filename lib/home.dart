import 'package:flutter/material.dart';

//Runs the Program
void main() {
  runApp(const LandingPage());
}

//Contains the code for the landing page
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
            // Background color
            Container(color: Colors.white),

            // Top bar
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A323F),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "HE",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom bar
            Align(
              alignment: const Alignment(0.0, 1),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A323F),
                ),
              ),
            ),
            const Align(
              alignment: Alignment(-0.95, -0.65), // moves text above center
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Important:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // 👇 Closeable card in center
            Align(
              alignment: const Alignment(0.0, -0.48),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      NotificationCard(),
                      SizedBox(width: 10), // spacing between cards
                      NotificationCard(),
                    ],
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment(-0.95, -0.1), // moves text above center
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Upcoming Maintenance:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment(-0.95, 0.3), // moves text above center
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Favorite Assets:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Bottom buttons
            Align(
              alignment: const Alignment(0.0, .95),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  children: [
                    TextButton(
                      onPressed: () => debugPrint("Home button pressed"),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2A323F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_outlined,
                              color: Colors.yellow, size: 24.0),
                          Text("Home", style: TextStyle(fontSize: 17)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => debugPrint("My assets button pressed"),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2A323F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.agriculture_outlined,
                              color: Colors.yellow, size: 24.0),
                          Text("My Assets", style: TextStyle(fontSize: 17)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => debugPrint("Profile button pressed"),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2A323F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_circle_outlined,
                              color: Colors.yellow, size: 24.0),
                          Text(
                            "Profile", 
                            style: TextStyle(fontSize: 17)
                          ),
                        ],
                      ),
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

// 🔽 Define the CloseableCard separately
class NotificationCard extends StatefulWidget {
  const NotificationCard({Key? key}) : super(key: key);

  @override
  State<NotificationCard> createState() => _CloseableCardState();
}

class _CloseableCardState extends State<NotificationCard> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 275, // 👈 sets maximum card width
      ),
      child: Stack(
        children: [
          Card(
            color: const Color.fromARGB(255, 255, 245, 136),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                "Overdue maintenance on Pittsburgh Fiberglass Claw Hammer.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  _visible = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

