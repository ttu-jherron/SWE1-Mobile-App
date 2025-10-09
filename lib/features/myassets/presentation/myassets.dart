import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../widgets/asset_card.dart';
import '../presentation/viewasset.dart';
import '../../../core/layout/app_layout.dart';
// CHANGE: Use DataHandler + Asset model instead of in‑memory repo
import 'package:mobile_app/core/data/data_handler.dart';
import '../../assets/data/asset.dart';
import '../../asset_inventory/presentation/add_asset.dart';

class MyAssetsPage extends StatefulWidget {
  const MyAssetsPage({super.key});

  @override
  State<MyAssetsPage> createState() => _MyAssetsPageState();
}

class _MyAssetsPageState extends State<MyAssetsPage> {
  List<Asset> _assetList = [];
  bool _loading = true;
  bool _error = false;
  StreamSubscription<List<Asset>>? _sub;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _initLoad();
  }

  Future<void> _initLoad() async {
    final handler = DataHandler.fromContext(context);
    // Stream for live updates
    _sub = handler.assetsStream.listen((assets) {
      if (!mounted) return;
      setState(() {
        _assetList = assets;
        _loading = false;
        _error = false;
      });
    });
    try {
      final assets = await handler.getAssets(); // cached or network
      if (!mounted) return;
      setState(() {
        _assetList = assets;
        _loading = false;
        _error = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _refresh() async {
    final handler = DataHandler.fromContext(context);
    try {
      final assets = await handler.getAssets(force: true, staleOk: false);
      if (!mounted) return;
      setState(() {
        _assetList = assets;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load assets'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = false;
                });
                _refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_assetList.isEmpty) {
      body = const Center(child: Text('No assets yet'));
    } else {
      body = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
    }

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
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
