import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyDesign(),
    );
  }
}

class MyDesign extends StatefulWidget {
  const MyDesign({super.key});

  @override
  State<MyDesign> createState() => _MyDesignState();
}

class _MyDesignState extends State<MyDesign> {
  int _selectedIndex = 0;

  // ✨ FIX: State variables now hold the app's data.
  // These are initially empty and will be populated by your other program.
  final List<Map<String, String>> favoriteAssets = [];
  final List<Map<String, String>> upcomingMaintenance = [];
  // This is nullable, so if it's null, the card won't show.
  Map<String, String>? overdueAsset;

  // Helper function to build the "Important" notification card
  Widget _buildImportantCard() {
    // ✨ FIX: This card will only be built if 'overdueAsset' has data.
    if (overdueAsset == null) {
      // Return an empty, zero-sized widget if there's no overdue asset.
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0x99FEEF4C),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFF2A323F)),
              SizedBox(width: 8),
              Text(
                'Important',
                style: TextStyle(
                  color: Color(0xFF2A323F),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF79747E)),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: Color(0xFF2A323F), fontSize: 16),
              children: [
                const TextSpan(text: 'Overdue maintenance on '),
                TextSpan(
                  // Use the asset name from your data
                  text: overdueAsset!['name'],
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build the horizontal list of favorite assets
  Widget _buildFavoriteAssetsList() {
    // ✨ FIX: If the list is empty, show a placeholder message.
    if (favoriteAssets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text('No favorite assets yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }

    // This will build the list once 'favoriteAssets' has items.
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favoriteAssets.length,
        itemBuilder: (context, index) {
          final asset = favoriteAssets[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    asset['image']!,
                    width: 148,
                    height: 99,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(asset['brand']!, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(asset['name']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16), overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper function to build the list of upcoming maintenance items
  Widget _buildUpcomingMaintenanceList() {
    // ✨ FIX: If the list is empty, show a placeholder message.
    if (upcomingMaintenance.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text('No upcoming maintenance.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }
    
    // This will build the list once 'upcomingMaintenance' has items.
    return ListView.builder(
      shrinkWrap: true, // Needed for a ListView inside a Column
      physics: const NeverScrollableScrollPhysics(), // The outer SingleChildScrollView will handle scrolling
      itemCount: upcomingMaintenance.length,
      itemBuilder: (context, index) {
        final item = upcomingMaintenance[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(item['image']!, width: 56, height: 56, fit: BoxFit.cover),
            ),
            title: Text(item['date']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['name']!),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A323F),
        title: const Text(
          'HE',
          style: TextStyle(
            color: Color(0xFFFEEF4C),
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImportantCard(), // This will be invisible if there's no overdue asset
              const Text(
                'Upcoming Maintenance',
                style: TextStyle(
                  color: Color(0xFF2A323F),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildUpcomingMaintenanceList(),
              const SizedBox(height: 24),
              const Text(
                'Favorite Assets',
                style: TextStyle(
                  color: Color(0xFF2A323F),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildFavoriteAssetsList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF2A323F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'My Assets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}