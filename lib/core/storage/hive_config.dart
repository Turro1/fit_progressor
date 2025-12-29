import 'package:hive_flutter/hive_flutter.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_hive_model.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_material_hive_model.dart';
import 'package:fit_progressor/features/clients/data/models/client_hive_model.dart';
import 'package:fit_progressor/features/cars/data/models/car_hive_model.dart';
import 'package:fit_progressor/features/materials/data/models/material_hive_model.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/sync_metadata_hive_model.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/pending_change_hive_model.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/connected_device_hive_model.dart';

/// Box names for Hive storage
class HiveBoxes {
  static const String repairs = 'repairs';
  static const String clients = 'clients';
  static const String cars = 'cars';
  static const String materials = 'materials';
  static const String settings = 'settings';
  static const String migration = 'migration';
  // Sync boxes
  static const String syncMetadata = 'sync_metadata';
  static const String pendingChanges = 'pending_changes';
  static const String connectedDevices = 'connected_devices';
}

/// Type IDs for Hive adapters
/// Must be unique and stable (don't change after release)
class HiveTypeIds {
  static const int repair = 0;
  static const int repairMaterial = 1;
  static const int repairStatus = 2;
  static const int client = 3;
  static const int car = 4;
  static const int material = 5;
  static const int materialUnit = 6;
  // Sync type IDs
  static const int syncMetadata = 7;
  static const int pendingChange = 8;
  static const int connectedDevice = 9;
}

/// Hive configuration and initialization
class HiveConfig {
  static bool _initialized = false;

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    _registerAdapters();

    // Open boxes
    await _openBoxes();

    _initialized = true;
  }

  static void _registerAdapters() {
    // Repairs
    if (!Hive.isAdapterRegistered(HiveTypeIds.repairStatus)) {
      Hive.registerAdapter(RepairStatusHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.repairMaterial)) {
      Hive.registerAdapter(RepairMaterialHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.repair)) {
      Hive.registerAdapter(RepairHiveModelAdapter());
    }

    // Clients
    if (!Hive.isAdapterRegistered(HiveTypeIds.client)) {
      Hive.registerAdapter(ClientHiveModelAdapter());
    }

    // Cars
    if (!Hive.isAdapterRegistered(HiveTypeIds.car)) {
      Hive.registerAdapter(CarHiveModelAdapter());
    }

    // Materials
    if (!Hive.isAdapterRegistered(HiveTypeIds.materialUnit)) {
      Hive.registerAdapter(MaterialUnitHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.material)) {
      Hive.registerAdapter(MaterialHiveModelAdapter());
    }

    // Sync
    if (!Hive.isAdapterRegistered(HiveTypeIds.syncMetadata)) {
      Hive.registerAdapter(SyncMetadataHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.pendingChange)) {
      Hive.registerAdapter(PendingChangeHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.connectedDevice)) {
      Hive.registerAdapter(ConnectedDeviceHiveModelAdapter());
    }
  }

  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<RepairHiveModel>(HiveBoxes.repairs),
      Hive.openBox<ClientHiveModel>(HiveBoxes.clients),
      Hive.openBox<CarHiveModel>(HiveBoxes.cars),
      Hive.openBox<MaterialHiveModel>(HiveBoxes.materials),
      Hive.openBox(HiveBoxes.settings),
      Hive.openBox(HiveBoxes.migration),
      // Sync boxes
      Hive.openBox<SyncMetadataHiveModel>(HiveBoxes.syncMetadata),
      Hive.openBox<PendingChangeHiveModel>(HiveBoxes.pendingChanges),
      Hive.openBox<ConnectedDeviceHiveModel>(HiveBoxes.connectedDevices),
    ]);
  }

  /// Get a typed box
  static Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

  /// Get settings box
  static Box get settingsBox => Hive.box(HiveBoxes.settings);

  /// Get migration box
  static Box get migrationBox => Hive.box(HiveBoxes.migration);

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAll() async {
    await Hive.box<RepairHiveModel>(HiveBoxes.repairs).clear();
    await Hive.box<ClientHiveModel>(HiveBoxes.clients).clear();
    await Hive.box<CarHiveModel>(HiveBoxes.cars).clear();
    await Hive.box<MaterialHiveModel>(HiveBoxes.materials).clear();
  }
}
