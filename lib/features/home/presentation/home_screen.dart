import 'package:flutter/material.dart';
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

  final List<_FavAsset> favorites = [
    _FavAsset(
      brand: 'Predator',
      name: '350W Power Station',
      img: 'assets/images/Predator.jpg',
      idForDetail: 'asset_001',
    ),
    _FavAsset(
      brand: 'Niagara',
      name: '4 Gal Backpack Chemical Sprayer',
      img: 'assets/images/Niagara.jpg',
      idForDetail: 'asset_002',
    ),
    _FavAsset(
      brand: 'Derwent',
      name: 'Graphic Design',
      img: 'assets/images/bob.jpg',
      idForDetail: 'asset_003',
    ),
  ];
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
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
                message:
                    'Overdue maintenance on Pittsburgh Fiberglass Claw Hammer.',
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
                    // Navigate to detail
                    Navigator.pushNamed(
                      context,
                      AppRoutes.maintenance,
                      //AppRoutes.maintenanceDetail,
                      arguments: favorites.first.idForDetail, // demo id
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
                itemBuilder: (ctx, i) => AssetCard(
                  titleTop: favorites[i].brand,
                  titleBottom: favorites[i].name,
                  imageAsset: favorites[i].img,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.maintenance,
                      //AppRoutes.maintenanceDetail,
                      arguments: favorites[i].idForDetail,
                    );
                  },
                ),
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

class _FavAsset {
  final String brand;
  final String name;
  final String img;
  final String idForDetail;
  _FavAsset({
    required this.brand,
    required this.name,
    required this.img,
    required this.idForDetail,
  });
}
