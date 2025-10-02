import 'package:flutter/material.dart';
import 'package:mobile_app/features/assets/data/asset.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../maintenance/data/maintenance_item.dart';
import 'widgets/alert_banner.dart';
import 'widgets/maintenance_card.dart';
import 'widgets/asset_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showAlert = true;

  // --- PLACEHOLDER DATA (swap with backend later) ---
  final List<MaintenanceItem> upcoming = [
    MaintenanceItem(
      id: 'm1',
      title: 'Pittsburgh Fiberglass Claw Hammer',
      dueDate: DateTime.now().subtract(const Duration(days: 41)),
      isLate: true,
      thumbAsset: 'assets/images/Niagara.jpg',
    ),
    MaintenanceItem(
      id: 'm2',
      title: 'Predator 350W Power Station — Re-oil',
      dueDate: DateTime.now().add(const Duration(days: 12)),
      isLate: false,
      thumbAsset: 'assets/images/Predator.jpg',
    ),
    MaintenanceItem(
      id: 'm3',
      title: 'Graphic Design',
      dueDate: DateTime.now().add(const Duration(days: 12)),
      isLate: false,
      thumbAsset: 'assets/images/bob.jpg',
    ),
  ];

  final List<Asset> allAssets = [
    Asset(
      id: 'asset_001',
      brand: 'Predator',
      title: '350W Power Station',
      name: 'Predator 350W Power Station',
      condition: 'New',
      store: 'Harbor Freight',
      price: 299.0,
      imagePath: 'assets/images/Predator.jpg',
      completionDate: DateTime.now().subtract(const Duration(days: 30)),
      shortDescription: 'Portable power station',
      notes: 'Keep charged',
      requiredMaterials: const [],
      favorite: true,
    ),
    Asset(
      id: 'asset_002',
      brand: 'Niagara',
      title: '4 Gal Backpack Chemical Sprayer',
      name: 'Niagara 4 Gal Sprayer',
      condition: 'Used',
      store: 'Home Depot',
      price: 119.0,
      imagePath: 'assets/images/Niagara.jpg',
      completionDate: DateTime.now().subtract(const Duration(days: 10)),
      shortDescription: 'Backpack sprayer',
      notes: 'Rinse after use',
      requiredMaterials: const [],
      favorite: true,
    ),
    Asset(
      id: 'asset_003',
      brand: 'Derwent',
      title: 'Graphic Design',
      name: 'Derwent Graphic Design',
      condition: 'Used',
      store: 'Amazon',
      price: 49.0,
      imagePath: 'assets/images/bob.jpg',
      completionDate: DateTime.now().subtract(const Duration(days: 5)),
      shortDescription: 'Design kit',
      notes: 'Handle with care',
      requiredMaterials: const [],
      favorite: false,
    ),
  ];
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Compute favorites from all assets where favorite == true
    final List<Asset> favorites =
        allAssets.where((a) => a.favorite).toList(growable: false);

    return AppLayout(
      currentIndex: 0, // Home tab
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Spacing.xl, Spacing.lg, Spacing.xl, Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAlert)
              AlertBanner(
                title: 'Important',
                message: 'Overdue maintenance on Pittsburgh Fiberglass Claw Hammer.',
                onClose: () => setState(() => showAlert = false),
              ),
            const SizedBox(height: Spacing.xl),

            const _SectionTitle('Upcoming Maintenance'),
            const SizedBox(height: Spacing.md),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: upcoming.length,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
                itemBuilder: (ctx, i) => MaintenanceCard(
                  item: upcoming[i],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.maintenance,
                      arguments: upcoming[i].id,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: Spacing.xl),
            const _SectionTitle('Favorite Assets'),
            const SizedBox(height: Spacing.md),
            SizedBox(
              height: 200,
              child: favorites.isEmpty
                  ? const Center(child: Text('No favorites yet'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
                      itemBuilder: (ctx, i) {
                        final asset = favorites[i];
                        return AssetCard(
                          titleTop: asset.brand,
                          titleBottom: asset.title,
                          imageAsset: asset.imagePath ?? 'assets/images/bob.jpg',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.viewAssets,
                              arguments: asset,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 22,
        color: Color(0xFF3C4652),
      ),
    );
  }
}
