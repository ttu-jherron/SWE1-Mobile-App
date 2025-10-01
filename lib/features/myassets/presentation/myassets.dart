import 'package:flutter/material.dart';
import '../../../core/colors.dart';
// import '../../../core/routing.dart';
import '../widgets/asset_card.dart';
import '../presentation/viewasset.dart';
import '../../../core/layout/app_layout.dart';
//IMPORT: Import Asset and AssetRepository
import '../../assets/data/asset.dart';
import '../../assets/data/asset_repository.dart';
//ADDED: Import the AddAssetPage
import '../../asset_inventory/presentation/add_asset.dart';

class MyAssetsPage extends StatefulWidget {
  const MyAssetsPage({super.key});

  @override
  State<MyAssetsPage> createState() => _MyAssetsPageState();
}

class _MyAssetsPageState extends State<MyAssetsPage> {
  //CHANGE: State to hold the list of assets
  List<Asset> _assetList = [];
  
  @override
  void initState() {
    super.initState();
    //ADDED: Load assets from the repository on initialization
    _loadAssets();
  }
  
  void _loadAssets() {
    // In a real app, this would be an async call, but for the in-memory repo, it's fine
    try {
      final assets = assetRepository.getAll();
      setState(() {
        _assetList = assets;
      });
    } catch (e) {
      debugPrint("Error loading assets: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header row
          Container(
            height: MediaQuery.of(context).size.height * 0.13,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(30, 30, 4, 10),
            alignment: Alignment.topLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "My Assets",
                  style: TextStyle(
                    color: AppColors.ebonyClay,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  //CHANGE: Implement navigation to AddAssetPage
                  onPressed: () {
                    debugPrint("Add Asset was pressed!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppLayout(
                          currentIndex: 1, // Stay on the Assets tab
                          body: AddAssetPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.ebonyClay,
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Scrollable section
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Wrap(
                    children: _assetList.map((asset) {
                      return AssetCard(
                        asset: asset, 
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppLayout(
                                currentIndex: 1,
                                body: ViewAssetPage(
                                  asset: asset,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
