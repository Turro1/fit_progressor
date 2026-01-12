import 'package:flutter/foundation.dart';

import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_hive_model.dart';
import 'package:fit_progressor/features/clients/data/models/client_hive_model.dart';
import 'package:fit_progressor/features/cars/data/models/car_hive_model.dart';
import 'package:fit_progressor/features/materials/data/models/material_hive_model.dart';

/// Сервис для применения изменений синхронизации к локальной базе данных
class SyncDataApplier {
  final ChangeTracker _changeTracker;

  SyncDataApplier(this._changeTracker);

  /// Применить входящее изменение к локальной базе
  Future<bool> applyChange(ChangePayload change) async {
    try {
      // Временно отключаем трекинг, чтобы не записывать входящие изменения
      // как новые локальные (избегаем циклической синхронизации)
      _changeTracker.setEnabled(false);

      final result = await _applyChangeInternal(change);

      _changeTracker.setEnabled(true);
      return result;
    } catch (e) {
      _changeTracker.setEnabled(true);
      debugPrint('SyncDataApplier: Error applying change: $e');
      return false;
    }
  }

  Future<bool> _applyChangeInternal(ChangePayload change) async {
    switch (change.entityType) {
      case EntityType.repair:
        return _applyRepairChange(change);
      case EntityType.client:
        return _applyClientChange(change);
      case EntityType.car:
        return _applyCarChange(change);
      case EntityType.material:
        return _applyMaterialChange(change);
    }
  }

  /// Применить изменение ремонта
  Future<bool> _applyRepairChange(ChangePayload change) async {
    final box = HiveConfig.getBox<RepairHiveModel>(HiveBoxes.repairs);

    switch (change.operation) {
      case ChangeOperation.create:
      case ChangeOperation.update:
        if (change.data == null) return false;

        final existing = box.get(change.entityId);

        // Проверяем версию для разрешения конфликтов
        if (existing != null && existing.version >= change.version) {
          // Локальная версия новее или равна - пропускаем
          debugPrint('SyncDataApplier: Skipping repair ${change.entityId}, local version ${existing.version} >= remote ${change.version}');
          return true;
        }

        final model = RepairHiveModel.fromJson(change.data!);
        model.version = change.version;
        model.updatedAt = change.changedAt;
        await box.put(change.entityId, model);
        debugPrint('SyncDataApplier: Applied ${change.operation.name} for repair ${change.entityId}');
        return true;

      case ChangeOperation.delete:
        await box.delete(change.entityId);
        debugPrint('SyncDataApplier: Deleted repair ${change.entityId}');
        return true;
    }
  }

  /// Применить изменение клиента
  Future<bool> _applyClientChange(ChangePayload change) async {
    final box = HiveConfig.getBox<ClientHiveModel>(HiveBoxes.clients);

    switch (change.operation) {
      case ChangeOperation.create:
      case ChangeOperation.update:
        if (change.data == null) return false;

        final existing = box.get(change.entityId);

        if (existing != null && existing.version >= change.version) {
          debugPrint('SyncDataApplier: Skipping client ${change.entityId}, local version ${existing.version} >= remote ${change.version}');
          return true;
        }

        final model = ClientHiveModel.fromJson(change.data!);
        model.version = change.version;
        model.updatedAt = change.changedAt;
        await box.put(change.entityId, model);
        debugPrint('SyncDataApplier: Applied ${change.operation.name} for client ${change.entityId}');
        return true;

      case ChangeOperation.delete:
        await box.delete(change.entityId);
        debugPrint('SyncDataApplier: Deleted client ${change.entityId}');
        return true;
    }
  }

  /// Применить изменение автомобиля
  Future<bool> _applyCarChange(ChangePayload change) async {
    final box = HiveConfig.getBox<CarHiveModel>(HiveBoxes.cars);

    switch (change.operation) {
      case ChangeOperation.create:
      case ChangeOperation.update:
        if (change.data == null) return false;

        final existing = box.get(change.entityId);

        if (existing != null && existing.version >= change.version) {
          debugPrint('SyncDataApplier: Skipping car ${change.entityId}, local version ${existing.version} >= remote ${change.version}');
          return true;
        }

        final model = CarHiveModel.fromJson(change.data!);
        model.version = change.version;
        model.updatedAt = change.changedAt;
        await box.put(change.entityId, model);
        debugPrint('SyncDataApplier: Applied ${change.operation.name} for car ${change.entityId}');
        return true;

      case ChangeOperation.delete:
        await box.delete(change.entityId);
        debugPrint('SyncDataApplier: Deleted car ${change.entityId}');
        return true;
    }
  }

  /// Применить изменение материала
  Future<bool> _applyMaterialChange(ChangePayload change) async {
    final box = HiveConfig.getBox<MaterialHiveModel>(HiveBoxes.materials);

    switch (change.operation) {
      case ChangeOperation.create:
      case ChangeOperation.update:
        if (change.data == null) return false;

        final existing = box.get(change.entityId);

        if (existing != null && existing.version >= change.version) {
          debugPrint('SyncDataApplier: Skipping material ${change.entityId}, local version ${existing.version} >= remote ${change.version}');
          return true;
        }

        final model = MaterialHiveModel.fromJson(change.data!);
        model.version = change.version;
        model.updatedAt = change.changedAt;
        await box.put(change.entityId, model);
        debugPrint('SyncDataApplier: Applied ${change.operation.name} for material ${change.entityId}');
        return true;

      case ChangeOperation.delete:
        await box.delete(change.entityId);
        debugPrint('SyncDataApplier: Deleted material ${change.entityId}');
        return true;
    }
  }

  /// Получить все данные для полной синхронизации
  Future<List<ChangePayload>> getAllData() async {
    final changes = <ChangePayload>[];

    // Добавляем все ремонты
    final repairsBox = HiveConfig.getBox<RepairHiveModel>(HiveBoxes.repairs);
    for (final repair in repairsBox.values) {
      changes.add(ChangePayload(
        entityId: repair.id,
        entityType: EntityType.repair,
        operation: ChangeOperation.create,
        changedAt: repair.updatedAt,
        version: repair.version,
        data: repair.toJson(),
      ));
    }

    // Добавляем всех клиентов
    final clientsBox = HiveConfig.getBox<ClientHiveModel>(HiveBoxes.clients);
    for (final client in clientsBox.values) {
      changes.add(ChangePayload(
        entityId: client.id,
        entityType: EntityType.client,
        operation: ChangeOperation.create,
        changedAt: client.updatedAt,
        version: client.version,
        data: client.toJson(),
      ));
    }

    // Добавляем все автомобили
    final carsBox = HiveConfig.getBox<CarHiveModel>(HiveBoxes.cars);
    for (final car in carsBox.values) {
      changes.add(ChangePayload(
        entityId: car.id,
        entityType: EntityType.car,
        operation: ChangeOperation.create,
        changedAt: car.updatedAt,
        version: car.version,
        data: car.toJson(),
      ));
    }

    // Добавляем все материалы
    final materialsBox = HiveConfig.getBox<MaterialHiveModel>(HiveBoxes.materials);
    for (final material in materialsBox.values) {
      changes.add(ChangePayload(
        entityId: material.id,
        entityType: EntityType.material,
        operation: ChangeOperation.create,
        changedAt: material.updatedAt,
        version: material.version,
        data: material.toJson(),
      ));
    }

    debugPrint('SyncDataApplier: getAllData returning ${changes.length} items');
    return changes;
  }
}
