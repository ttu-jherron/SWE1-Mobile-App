// (userId field is now inside _MyAssetsPageState)
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
  // TODO: Replace with actual user ID from auth/session
  final String userId = 'user_33UeIDzYloCoZABaaCR1WPmV7MT';
  List<Asset> _assetList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final assets = await assetRepository.getAll(userId);
      setState(() {
        _assetList = assets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load assets';
        _isLoading = false;
      });
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
                  onPressed: () async {
                    debugPrint("Add Asset was pressed!");
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppLayout(
                          currentIndex: 1,
                          body: AddAssetPage(),
                        ),
                      ),
                    );
                    if (result != null) {
                      // Reload asset list after adding
                      await _loadAssets();
                    }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : SingleChildScrollView(
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
