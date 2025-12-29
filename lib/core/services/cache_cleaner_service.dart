import 'package:hive_flutter/hive_flutter.dart';

import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/pending_change_hive_model.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/sync_metadata_hive_model.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/connected_device_hive_model.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_hive_model.dart';
import 'package:fit_progressor/features/clients/data/models/client_hive_model.dart';
import 'package:fit_progressor/features/cars/data/models/car_hive_model.dart';
import 'package:fit_progressor/features/materials/data/models/material_hive_model.dart';

/// Результат операции очистки
class ClearResult {
  final bool success;
  final String message;
  final int clearedItems;

  ClearResult({
    required this.success,
    required this.message,
    this.clearedItems = 0,
  });

  factory ClearResult.success(String message, {int clearedItems = 0}) =>
      ClearResult(success: true, message: message, clearedItems: clearedItems);

  factory ClearResult.failure(String message) =>
      ClearResult(success: false, message: message);
}

/// Статистика данных для очистки
class CacheStats {
  final int repairsCount;
  final int clientsCount;
  final int carsCount;
  final int materialsCount;
  final int pendingChangesCount;
  final int syncedChangesCount;

  CacheStats({
    required this.repairsCount,
    required this.clientsCount,
    required this.carsCount,
    required this.materialsCount,
    required this.pendingChangesCount,
    required this.syncedChangesCount,
  });

  int get totalDataCount =>
      repairsCount + clientsCount + carsCount + materialsCount;

  bool get hasPendingChanges => pendingChangesCount > 0;

  bool get hasData => totalDataCount > 0;
}

/// Сервис для безопасной очистки локальных данных
class CacheCleanerService {
  final ChangeTracker _changeTracker;

  CacheCleanerService({required ChangeTracker changeTracker})
      : _changeTracker = changeTracker;

  /// Получить статистику данных
  Future<CacheStats> getStats() async {
    final repairsBox = Hive.box<RepairHiveModel>(HiveBoxes.repairs);
    final clientsBox = Hive.box<ClientHiveModel>(HiveBoxes.clients);
    final carsBox = Hive.box<CarHiveModel>(HiveBoxes.cars);
    final materialsBox = Hive.box<MaterialHiveModel>(HiveBoxes.materials);
    final pendingChangesBox =
        Hive.box<PendingChangeHiveModel>(HiveBoxes.pendingChanges);

    final pendingChanges = _changeTracker.getPendingChanges();
    final syncedChanges =
        pendingChangesBox.values.where((c) => c.isSent).length;

    return CacheStats(
      repairsCount: repairsBox.length,
      clientsCount: clientsBox.length,
      carsCount: carsBox.length,
      materialsCount: materialsBox.length,
      pendingChangesCount: pendingChanges.length,
      syncedChangesCount: syncedChanges,
    );
  }

  /// Очистить только старые синхронизированные изменения (безопасно)
  Future<ClearResult> clearSyncedChanges({Duration maxAge = const Duration(days: 7)}) async {
    try {
      final before = Hive.box<PendingChangeHiveModel>(HiveBoxes.pendingChanges).length;
      await _changeTracker.cleanupOldChanges(maxAge: maxAge);
      final after = Hive.box<PendingChangeHiveModel>(HiveBoxes.pendingChanges).length;
      final cleared = before - after;

      return ClearResult.success(
        'Очищено $cleared старых записей синхронизации',
        clearedItems: cleared,
      );
    } catch (e) {
      return ClearResult.failure('Ошибка очистки: $e');
    }
  }

  /// Очистить все метаданные синхронизации (pending changes, sync metadata)
  Future<ClearResult> clearSyncMetadata() async {
    try {
      final pendingBox =
          Hive.box<PendingChangeHiveModel>(HiveBoxes.pendingChanges);
      final metadataBox =
          Hive.box<SyncMetadataHiveModel>(HiveBoxes.syncMetadata);
      final devicesBox =
          Hive.box<ConnectedDeviceHiveModel>(HiveBoxes.connectedDevices);

      final cleared =
          pendingBox.length + metadataBox.length + devicesBox.length;

      await pendingBox.clear();
      await metadataBox.clear();
      await devicesBox.clear();

      return ClearResult.success(
        'Метаданные синхронизации очищены',
        clearedItems: cleared,
      );
    } catch (e) {
      return ClearResult.failure('Ошибка очистки метаданных: $e');
    }
  }

  /// Очистить все данные приложения (ремонты, клиенты, авто, материалы)
  Future<ClearResult> clearAllData() async {
    try {
      final stats = await getStats();
      final totalCleared = stats.totalDataCount;

      await HiveConfig.clearAll();

      return ClearResult.success(
        'Все данные очищены ($totalCleared записей)',
        clearedItems: totalCleared,
      );
    } catch (e) {
      return ClearResult.failure('Ошибка очистки данных: $e');
    }
  }

  /// Полная очистка - все данные + метаданные синхронизации
  Future<ClearResult> clearEverything() async {
    try {
      final stats = await getStats();

      // Очищаем данные
      await HiveConfig.clearAll();

      // Очищаем метаданные синхронизации
      await Hive.box<PendingChangeHiveModel>(HiveBoxes.pendingChanges).clear();
      await Hive.box<SyncMetadataHiveModel>(HiveBoxes.syncMetadata).clear();
      await Hive.box<ConnectedDeviceHiveModel>(HiveBoxes.connectedDevices)
          .clear();

      final totalCleared =
          stats.totalDataCount + stats.pendingChangesCount + stats.syncedChangesCount;

      return ClearResult.success(
        'Полная очистка выполнена',
        clearedItems: totalCleared,
      );
    } catch (e) {
      return ClearResult.failure('Ошибка полной очистки: $e');
    }
  }
}
