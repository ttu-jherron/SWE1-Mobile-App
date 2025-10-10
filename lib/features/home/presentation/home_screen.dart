import 'package:flutter/material.dart';
import 'package:mobile_app/features/assets/data/asset.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../maintenance/data/maintenance_item.dart';
import 'widgets/alert_banner.dart';
import 'widgets/maintenance_card.dart';
import '../../myassets/widgets/asset_card.dart';
import '../../assets/data/asset_store.dart';

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
  // ---------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bind to DataHandler via AssetStore (subscribes and fetches once)
    assetStore.bind(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: assetStore,
      builder: (context, _) {
        final assets = assetStore.all();
        final List<Asset> favorites =
            assets.where((a) => a.favorite == true).toList(growable: false);

        return AppLayout(
          currentIndex: 0, // Home tab
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.xl,
              Spacing.lg,
              Spacing.xl,
              Spacing.xl,
            ),
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
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.star_border,
                                size: 36,
                                color: Color(0xFF9AA3AD),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'You currently have not favorited any assets.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF3C4652),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Go to My Assets to favorite your assets.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF3C4652)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: favorites.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: Spacing.md),
                          itemBuilder: (ctx, i) {
                            final asset = favorites[i];
                            return AssetCard(
                              asset: asset,
                              style: AssetCardStyle.home,
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
      },
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
