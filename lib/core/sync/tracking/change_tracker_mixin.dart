import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';

/// Mixin для добавления отслеживания изменений в DataSources
mixin ChangeTrackerMixin {
  /// Получить экземпляр ChangeTracker
  ChangeTracker? get changeTracker;

  /// Отслеживать создание сущности
  Future<void> trackCreate({
    required EntityType entityType,
    required String entityId,
    required int version,
    required Map<String, dynamic> data,
  }) async {
    await changeTracker?.track(
      entityId: entityId,
      entityType: entityType,
      operation: ChangeOperation.create,
      version: version,
      data: data,
    );
  }

  /// Отслеживать обновление сущности
  Future<void> trackUpdate({
    required EntityType entityType,
    required String entityId,
    required int version,
    required Map<String, dynamic> data,
  }) async {
    await changeTracker?.track(
      entityId: entityId,
      entityType: entityType,
      operation: ChangeOperation.update,
      version: version,
      data: data,
    );
  }

  /// Отслеживать удаление сущности
  Future<void> trackDelete({
    required EntityType entityType,
    required String entityId,
    required int version,
  }) async {
    await changeTracker?.track(
      entityId: entityId,
      entityType: entityType,
      operation: ChangeOperation.delete,
      version: version,
      data: null,
    );
  }
}
