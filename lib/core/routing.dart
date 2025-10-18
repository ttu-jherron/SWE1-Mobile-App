import 'package:flutter/material.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/maintenance/presentation/maintenance_screen.dart';
import '../features/maintenance/presentation/maintenance_detail_screen.dart';
import '../features/maintenance/presentation/edit_maintenance.dart';
import '../features/myassets/presentation/myassets.dart';
import 'package:mobile_app/features/myassets/presentation/viewasset.dart';
import 'package:mobile_app/features/assets/data/asset.dart'; 

import 'layout/app_layout.dart';

import '../features/home/presentation/home_screen.dart' as home_feature;

class _AssetsScaffold extends StatelessWidget {
  const _AssetsScaffold();

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 1,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.maintenanceDetail, //defined in your routes
              arguments: 'asset_001', //burner ID for now
            );
          },
          child: const Text('Open Maintenance Page'),
        ),
      ),
    );
  }
}

class _MyAssetsScaffold extends StatelessWidget {
  const _MyAssetsScaffold();

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 1,
      body: const MyAssetsPage(), //
    );
  }
}

class AppRoutes {
  static const login = '/';
  static const signUp = '/signup';
  static const home = '/home';

  static const assets = '/assets';
  static const myAssets = '/myassets';
  static const viewAssets = '/viewassets';

  static const profile = '/profile';

  static const maintenance = '/maintenance';
  static const maintenanceDetail = '/maintenance/detail';
  static const maintenanceEdit = '/maintenance/edit';
  
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    signUp: (_) => const SignUpScreen(),

    // stubs:
    home: (_) => const home_feature.HomeScreen(),
    //home: (_) => const _HomeScaffold(), // see below
    assets: (_) => const _AssetsScaffold(),

    myAssets: (_) => const _MyAssetsScaffold(),
    viewAssets: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Asset;
      return AppLayout(
        currentIndex: 1, // My Assets tab index
        popOnCurrentTabTap: true, // NEW: tapping "My Assets" acts like close
        body: ViewAssetPage(asset: args),
      );
    },

    // new screens:
    profile: (_) => ProfileScreen(),
    maintenance: (_) => const MaintenanceScreen(),

    maintenanceDetail: (context) {
      // Screen will read ModalRoute.of(context)!.settings.arguments
      return const MaintenanceDetailScreen();
    },
    maintenanceEdit: (context) {
      // Screen will read ModalRoute.of(context)!.settings.arguments
      return const AddMaintenancePage();
    },
  };
}

