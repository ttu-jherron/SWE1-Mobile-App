import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import 'package:mobile_app/features/maintenance/data/maintenance_entry.dart';

/// Minimal fake user with the fields DataHandler reads.
class FakeUser {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String imageUrl;

  FakeUser({
    required this.id,
    this.email = '',
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.imageUrl = '',
  });
}

/// Minimal fake auth object that exposes the members DataHandler uses.
class FakeAuth {
  FakeUser? user;
  final List<void Function()> _listeners = [];

  void addListener(void Function() cb) => _listeners.add(cb);
  void removeListener(void Function() cb) => _listeners.remove(cb);

  Future<void> refreshClient() async {}
  Future<void> refreshEnvironment() async {}
}

void main() {
  const baseUrl = 'https://api.thehippoexchange.com';

  group('DataHandler maintenance flows', () {
    late FakeAuth auth;
    late http.Client client;
    late DataHandler handler;

    setUp(() {
      auth = FakeAuth();
      auth.user = FakeUser(id: 'user_test_1');
    });

    test('GET /maintenance returns list', () async {
      final maintenanceJson = [
        {
          'id': 'm1',
          'assetId': 'a1',
          'brandName': 'Brand',
          'productName': 'Product',
          'purchaseLocation': 'Store',
          'assetCategory': 'Tools',
          'costPaid': 12.34,
          'maintenanceDueDate': DateTime.now().toUtc().toIso8601String(),
          'maintenanceTitle': 'Tune up',
          'maintenanceDescription': 'Do stuff',
          'maintenanceStatus': 'pending',
          'preserveFromPrior': false,
          'isCompleted': false,
          'requiredTools': <String>[],
          'toolLocation': '',
          'recurrenceUnit': 0,
          'recurrenceInterval': 0,
        }
      ];

      client = MockClient((req) async {
        if (req.method == 'GET' && req.url.path.endsWith('/maintenance')) {
          return http.Response(jsonEncode(maintenanceJson), 200, headers: {
            'content-type': 'application/json'
          });
        }
        return http.Response('Not found', 404);
      });

      handler = DataHandler(auth: auth as dynamic, baseUrl: baseUrl, client: client);
      await handler.clearAllCache();

      final list = await handler.getMaintenance(force: true);
      expect(list, isNotEmpty);
      expect(list.first.id, equals('m1'));
    });

    test('GET /assets/{assetId}/maintenance returns asset-specific list', () async {
      final assetId = 'asset-123';
      final maintenanceJson = [
        {
          'id': 'm2',
          'assetId': assetId,
          'brandName': 'BrandB',
          'productName': 'ProductB',
          'purchaseLocation': 'StoreB',
          'assetCategory': 'Garden',
          'costPaid': 99.99,
          'maintenanceDueDate': DateTime.now().toUtc().toIso8601String(),
          'maintenanceTitle': 'Service',
          'maintenanceDescription': 'Do more',
          'maintenanceStatus': 'pending',
          'preserveFromPrior': false,
          'isCompleted': false,
          'requiredTools': <String>[],
          'toolLocation': '',
          'recurrenceUnit': 0,
          'recurrenceInterval': 0,
        }
      ];

      client = MockClient((req) async {
        if (req.method == 'GET' && req.url.path.endsWith('/assets/$assetId/maintenance')) {
          return http.Response(jsonEncode(maintenanceJson), 200, headers: {
            'content-type': 'application/json'
          });
        }
        return http.Response('Not found', 404);
      });

      handler = DataHandler(auth: auth as dynamic, baseUrl: baseUrl, client: client);
      await handler.clearAllCache();

      final list = await handler.getMaintenanceForAsset(assetId, force: true);
      expect(list, isNotEmpty);
      expect(list.first.assetId, equals(assetId));
      expect(list.first.id, equals('m2'));
    });

    test('POST /assets/{assetId}/maintenance creates maintenance and merges into cache', () async {
      final assetId = 'asset-create';
      final toCreate = MaintenanceEntry(
        id: '',
        assetId: assetId,
        brandName: 'NewBrand',
        productName: 'NewProduct',
        purchaseLocation: 'Shop',
        assetCategory: 'Category',
        costPaid: 10.0,
        maintenanceDueDate: DateTime.now().toUtc(),
        maintenanceTitle: 'New',
        maintenanceDescription: 'Desc',
        maintenanceStatus: 'pending',
        preserveFromPrior: false,
        isCompleted: false,
        requiredTools: <String>[],
        toolLocation: '',
        recurrenceUnit: 0,
        recurrenceInterval: 0,
      );

      // Server will respond with created object including id
      final created = Map<String, dynamic>.from(toCreate.toJson())..['id'] = 'created-1';

      client = MockClient((req) async {
        if (req.method == 'POST' && req.url.path.endsWith('/assets/$assetId/maintenance')) {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          // assetId should not be present in body per API design
          expect(body.containsKey('assetId'), isFalse);
          return http.Response(jsonEncode(created), 201, headers: {
            'content-type': 'application/json'
          });
        }
        return http.Response('Not found', 404);
      });

      handler = DataHandler(auth: auth as dynamic, baseUrl: baseUrl, client: client);
      await handler.clearAllCache();

      await handler.addMaintenance(toCreate);

      // After addMaintenance, the created item should be merged into cache
      final cached = handler.cachedMaintenance;
      expect(cached, isNotNull);
      expect(cached!.first.id, equals('created-1'));
    });

    test('PATCH /maintenance/{maintenanceId} updates maintenance and merges into cache', () async {
      final maintenanceId = 'patch-1';
      // existing cached maintenance
      final existing = MaintenanceEntry(
        id: maintenanceId,
        assetId: 'asset-x',
        brandName: 'Old',
        productName: 'OldProd',
        purchaseLocation: 'OldStore',
        assetCategory: 'OldCat',
        costPaid: 5.0,
        maintenanceDueDate: DateTime.now().toUtc(),
        maintenanceTitle: 'OldTitle',
        maintenanceDescription: 'OldDesc',
        maintenanceStatus: 'pending',
        preserveFromPrior: false,
        isCompleted: false,
        requiredTools: <String>[],
        toolLocation: '',
        recurrenceUnit: 0,
        recurrenceInterval: 0,
      );

      final updated = Map<String, dynamic>.from(existing.toJson())
        ..['maintenanceStatus'] = 'completed'
        ..['id'] = maintenanceId;

      client = MockClient((req) async {
        // Allow seeding via GET /maintenance
        if (req.method == 'GET' && req.url.path.endsWith('/maintenance')) {
          return http.Response(jsonEncode([existing.toJson()]), 200, headers: {
            'content-type': 'application/json'
          });
        }

        if (req.method == 'PATCH' && req.url.path.endsWith('/maintenance/$maintenanceId')) {
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          // we expect the patch to include the updated status
          expect(body['maintenanceStatus'], equals('completed'));
          return http.Response(jsonEncode(updated), 200, headers: {
            'content-type': 'application/json'
          });
        }
        return http.Response('Not found', 404);
      });

      handler = DataHandler(auth: auth as dynamic, baseUrl: baseUrl, client: client);
      await handler.clearAllCache();

      // Seed cache with existing via public GET so we don't access private members
      final seeded = await handler.getMaintenance(force: true);
      expect(seeded, isNotEmpty);
      expect(seeded.first.id, equals(maintenanceId));

      await handler.updateMaintenance(maintenanceId: maintenanceId, patch: {'maintenanceStatus': 'completed'});

      final cached = handler.cachedMaintenance;
      expect(cached, isNotNull);
      expect(cached!.first.maintenanceStatus, equals('completed'));
    });
  });
}
