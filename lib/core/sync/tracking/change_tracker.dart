import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/pending_change_hive_model.dart';

/// Callback для уведомления о новом изменении
typedef OnChangeTracked = Future<void> Function(ChangePayload change);

/// Отслеживает изменения данных для синхронизации
class ChangeTracker {
  static const String _pendingChangesBoxName = 'pending_changes';

  Box<PendingChangeHiveModel>? _box;
  bool _isEnabled = true;

  /// Callback для уведомления SyncEngine о новом изменении
  OnChangeTracked? onChangeTracked;

  /// Включить/выключить отслеживание изменений
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Проверить включено ли отслеживание
  bool get isEnabled => _isEnabled;

  /// Проверить инициализирован ли трекер
  bool get isInitialized => _box != null && _box!.isOpen;

  /// Инициализация трекера
  Future<void> init() async {
    if (!Hive.isBoxOpen(_pendingChangesBoxName)) {
      _box = await Hive.openBox<PendingChangeHiveModel>(_pendingChangesBoxName);
    } else {
      _box = Hive.box<PendingChangeHiveModel>(_pendingChangesBoxName);
    }
  }

  /// Получить box для pending changes
  Box<PendingChangeHiveModel> get box {
    // Автоматически получаем box если он уже открыт через HiveConfig
    if (_box == null || !_box!.isOpen) {
      if (Hive.isBoxOpen(_pendingChangesBoxName)) {
        _box = Hive.box<PendingChangeHiveModel>(_pendingChangesBoxName);
      } else {
        throw StateError('ChangeTracker not initialized. Call init() first or ensure HiveConfig.init() was called.');
      }
    }
    return _box!;
  }

  /// Записать изменение в очередь
  Future<void> track({
    required String entityId,
    required EntityType entityType,
    required ChangeOperation operation,
    required int version,
    Map<String, dynamic>? data,
  }) async {
    if (!_isEnabled) return;

    final changeId = const Uuid().v4();
    final now = DateTime.now();

    final pendingChange = PendingChangeHiveModel(
      changeId: changeId,
      entityId: entityId,
      entityType: entityType.name,
      operation: operation.name,
      changedAt: now,
      version: version,
      dataJson: data != null ? jsonEncode(data) : null,
      isSent: false,
      createdAt: now,
    );

    await box.put(changeId, pendingChange);

    // Уведомляем SyncEngine о новом изменении для немедленной синхронизации
    if (onChangeTracked != null) {
      final changePayload = ChangePayload(
        changeId: changeId,
        entityId: entityId,
        entityType: entityType,
        operation: operation,
        changedAt: now,
        version: version,
        data: data,
      );
      await onChangeTracked!(changePayload);
    }
  }

  /// Получить все несинхронизированные изменения
  List<PendingChangeHiveModel> getPendingChanges() {
    return box.values.where((c) => !c.isSent).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Получить изменения для конкретного устройства
  List<PendingChangeHiveModel> getChangesForDevice(String deviceId) {
    return box.values
        .where((c) => !c.sentToDevices.contains(deviceId))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Отметить изменение как отправленное устройству
  Future<void> markSentToDevice(String changeId, String deviceId) async {
    final change = box.get(changeId);
    if (change != null) {
      if (!change.sentToDevices.contains(deviceId)) {
        change.sentToDevices.add(deviceId);
      }
      await change.save();
    }
  }

  /// Отметить изменение как полностью синхронизированное
  Future<void> markFullySynced(String changeId) async {
    final change = box.get(changeId);
    if (change != null) {
      change.isSent = true;
      await change.save();
    }
  }

  /// Удалить старые синхронизированные изменения
  Future<void> cleanupOldChanges({Duration maxAge = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().subtract(maxAge);
    final toDelete = <String>[];

    for (final change in box.values) {
      if (change.isSent && change.createdAt.isBefore(cutoff)) {
        toDelete.add(change.changeId);
      }
    }

    for (final id in toDelete) {
      await box.delete(id);
    }
  }

  /// Очистить все pending changes
  Future<void> clearAll() async {
    await box.clear();
  }

  /// Преобразовать PendingChangeHiveModel в ChangePayload
  ChangePayload toChangePayload(PendingChangeHiveModel model) {
    return ChangePayload(
      changeId: model.changeId,
      entityId: model.entityId,
      entityType: EntityType.values.firstWhere(
        (e) => e.name == model.entityType,
      ),
      operation: ChangeOperation.values.firstWhere(
        (e) => e.name == model.operation,
      ),
      changedAt: model.changedAt,
      version: model.version,
      data: model.data,
    );
  }

  /// Преобразовать ChangePayload в PendingChangeHiveModel
  PendingChangeHiveModel fromChangePayload(ChangePayload payload) {
    return PendingChangeHiveModel(
      changeId: payload.changeId,
      entityId: payload.entityId,
      entityType: payload.entityType.name,
      operation: payload.operation.name,
      changedAt: payload.changedAt,
      version: payload.version,
      dataJson: payload.data != null ? jsonEncode(payload.data) : null,
      isSent: false,
    );
  }
}
