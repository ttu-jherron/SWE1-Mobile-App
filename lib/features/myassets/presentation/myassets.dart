import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../widgets/asset_card.dart';
import '../presentation/viewasset.dart';
import '../../../core/layout/app_layout.dart';
import '../../assets/data/asset.dart';
import '../../asset_inventory/presentation/add_asset.dart';
import '../../assets/data/asset_store.dart';

class MyAssetsPage extends StatefulWidget {
  const MyAssetsPage({super.key});

  @override
  State<MyAssetsPage> createState() => _MyAssetsPageState();
}

class _MyAssetsPageState extends State<MyAssetsPage> {
  bool _bound = false;
  bool _loading = true;
  bool _error = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bound) return;
    _bound = true;

    // Bind store once and kick an initial (cached-or-network) fetch
    assetStore.bind(context);
    _initialFetch();
  }

  Future<void> _initialFetch() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      await assetStore.refresh(force: false);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _refresh() async {
    try {
      await assetStore.refresh(force: true);
      if (!mounted) return;
      setState(() => _error = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppLayout(
                          currentIndex: 1,
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
                const Spacer(),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, color: AppColors.ebonyClay),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: Container(
                color: Colors.white,
                child: AnimatedBuilder(
                  animation: assetStore,
                  builder: (context, _) {
                    final List<Asset> assets = assetStore.all();

                    if (_loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_error) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Failed to load assets'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                _initialFetch();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (assets.isEmpty) {
                      return const Center(child: Text('No assets yet'));
                    }

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Wrap(
                          children: assets.map((asset) {
                            return AssetCard(
                              asset: asset,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AppLayout(
                                      currentIndex: 1,
                                      body: ViewAssetPage(asset: asset),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
