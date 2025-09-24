import 'package:flutter/material.dart';

void main() {
  runApp(const AddAssetPage());
}

// Defines the custom colors used across the app
const Color primaryDark = Color(0xFF2A323F);
const Color primaryYellow = Colors.yellow;
const Color lightGreyBackground = Color(0xFFF5F5F5);
const Color cardColor = Color(0xFFD9D9D9);

// A reusable widget for a heart icon that can be favorited
class AddFavorite extends StatefulWidget {
  const AddFavorite({super.key});

  @override
  State<AddFavorite> createState() => _AddFavoriteState();
}

class _AddFavoriteState extends State<AddFavorite> {
  bool _isClicked = false; 

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        _isClicked ? Icons.favorite : Icons.favorite_border,
        color: _isClicked ? Colors.red : const Color(0xFF2A323F),
        size: 22,
      ),
      onPressed: () {
        setState(() {
          _isClicked = !_isClicked;
        });
      },
    );
  }
}

// A reusable widget for a maintenance task card
class MaintenanceCard extends StatefulWidget {
  const MaintenanceCard({super.key});

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
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 2),
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

// Main class for the "Add Asset" page
class AddAssetPage extends StatelessWidget {
  const AddAssetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top section with "HE" logo
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: const BoxDecoration(
                color: primaryDark,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "HE",
                        style: TextStyle(
                          color: primaryYellow,
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
          // Scrollable middle section
          Expanded(
            child: Container(
              color: lightGreyBackground,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(height: 15),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60.0),
                          child: Text(
                            'Add Asset',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                          'Brand Name:', 'e.g., Apple', FontWeight.w500, cardColor, primaryDark),
                      const SizedBox(height: 16),
                      _buildTextField('Asset Name:', 'e.g., iPhone 13 Pro', FontWeight.w500,cardColor, primaryDark),
                      const SizedBox(height: 16),
                      _buildConditionDropdown(cardColor, primaryDark),
                      const SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.0),
                          child: Text(
                            "Bought From:",
                            style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildTextField('Store:', 'e.g., Store', FontWeight.w300, cardColor, primaryDark),
                      const SizedBox(height: 6),
                      _buildTextField('Address/Link:', 'e.g., 123 Main St / www.apple.com', FontWeight.w300, cardColor, primaryDark),
                      const SizedBox(height: 6),
                      _buildTextField('Phone Number:','e.g., +1 (123) 456-7890', FontWeight.w300, cardColor, primaryDark, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                     _buildTextField('Price:', 'e.g., \$15.99', FontWeight.w500,cardColor, primaryDark, keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical:10.0),
                        child: ElevatedButton(
                          onPressed: () => debugPrint("Save Asset pressed!"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A323F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save",
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
            ),
          ),
          // Bottom navigation bar
          Align(
            alignment: const Alignment(0.0, 1),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: primaryDark,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  children: [
                    _buildNavButton(Icons.home_outlined, 'Home'),
                    const SizedBox(width: 10),
                    _buildNavButton(Icons.agriculture_outlined, 'My Assets'),
                    const SizedBox(width: 10),
                    _buildNavButton(Icons.account_circle_outlined, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hintText, FontWeight fontWeight, Color cardColor, Color textColor,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
            child: Text(
              label,
              style: TextStyle(
              fontSize: 16,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
        ),
        SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: TextField(
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionDropdown(Color cardColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          child: Text(
            'Condition',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: <String>[
                'New',
                'Used - Like New',
                'Used - Good',
                'Used - Fair',
                'For Parts'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Handle value change
              },
              hint: const Text('Select Condition'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, String label) {
    return TextButton(
      onPressed: () => debugPrint('$label button pressed'),
      style: TextButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: primaryYellow,
            size: 24.0,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
