import 'package:flutter/material.dart';
import 'package:mobile_app/core/colors.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import 'package:mobile_app/features/assets/data/asset.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../maintenance/data/maintenance_item.dart';
import '../../maintenance/data/maintenance_store.dart';
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
  bool _showOverdueBanner = true;

  @override
  void initState() {
    super.initState();
    // Clear any snackbar that might still be queued from the previous screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar(reason: SnackBarClosedReason.remove);
      _runOverdueCheckIfNeeded();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bind to DataHandler via AssetStore (subscribes and fetches once)
    assetStore.bind(context);
    // Initialize maintenance store
    initializeMaintenanceStore(context);
  }

  Future<void> _runOverdueCheckIfNeeded() async {
    if (await DataHandler.shouldRunOverdueCheck()) {
      final dh = DataHandler.fromContext(context);
      await dh.updateOverdueMaintenanceStatuses();
      await DataHandler.markOverdueCheckRan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([assetStore, maintenanceStore]),
      builder: (context, _) {
        final assets = assetStore.all();
        final List<Asset> favorites =
            assets.where((a) => a.favorite == true).toList(growable: false);
        final maintenanceEntries = maintenanceStore.getAll();
        final maintenanceItems = maintenanceEntries
            .map((entry) => MaintenanceItem.fromMaintenanceEntry(entry))
            .toList();

        final upcomingItems = maintenanceItems
            .where((item) => item.maintenanceStatus == 'Upcoming')
            .toList();

        // Count overdue items
        final overdueCount = maintenanceItems
            .where((item) => item.maintenanceStatus == 'Overdue')
            .length;

        final maxCards = 10;
        final showMore = upcomingItems.length > maxCards;
        final visibleItems = showMore ? upcomingItems.take(maxCards).toList() : upcomingItems;

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
                if (overdueCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.maintenance,
                          arguments: {'filter': 'Overdue'},
                        );
                      },
                      child: AlertBanner(
                        message: 'You have $overdueCount overdue maintenance tasks. '
                            'Tap to view them, or tap the X to dismiss.',
                        onClose: () {
                          setState(() {
                            _showOverdueBanner = false;
                          });
                        }, title: 'Important',
                      ),
                    ),
                  ),
                const SizedBox(height: Spacing.xl),

                const _SectionTitle('Upcoming Maintenance'),
                const SizedBox(height: Spacing.md),
                SizedBox(
                  height: 92,
                  child: upcomingItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.build,
                                size: 36,
                                color: Color(0xFF9AA3AD),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No maintenance items yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF3C4652),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add maintenance schedules to your assets.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF3C4652)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: showMore ? visibleItems.length + 1 : visibleItems.length,
                          separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
                          itemBuilder: (ctx, i) {
                            if (showMore && i == visibleItems.length) {
                              // Show More Card
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.maintenance,
                                    arguments: {'filter': 'Upcoming'},
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 120,
                                  height: 72, // Match the height of your other cards (48 image + padding)
                                  padding: const EdgeInsets.all(Spacing.md),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.arrow_forward, color: AppColors.ebonyClay, size: 28),
                                        SizedBox(height: 8),
                                        Text(
                                          'See All',
                                          style: TextStyle(
                                            color: AppColors.ebonyClay,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            final item = visibleItems[i];
                            final asset = assetStore.getById(item.assetId);

                            return MaintenanceCard(
                              item: item,
                              asset: asset,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.maintenanceEntryDetail,
                                  arguments: maintenanceEntries.firstWhere((e) => e.id == item.id),
                                );
                              },
                            );
                          },
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
