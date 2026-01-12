import 'package:hive/hive.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_model.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_hive_model.dart';
import 'repair_local_datasource.dart';

/// Hive implementation of RepairLocalDataSource
class RepairHiveDataSource implements RepairLocalDataSource {
  final ChangeTracker? changeTracker;

  RepairHiveDataSource({this.changeTracker});

  Box<RepairHiveModel> get _box => HiveConfig.getBox<RepairHiveModel>(HiveBoxes.repairs);

  @override
  Future<List<RepairModel>> getRepairs() async {
    try {
      final repairs = _box.values.toList();
      // Sort by date descending (newest first)
      repairs.sort((a, b) => b.date.compareTo(a.date));
      return repairs.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return RepairModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка загрузки ремонтов: $e');
    }
  }

  @override
  Future<RepairModel> getRepairById(String id) async {
    try {
      final hiveModel = _box.get(id);
      if (hiveModel == null) {
        throw CacheException(message: 'Ремонт не найден');
      }
      return RepairModel.fromEntity(hiveModel.toEntity());
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка получения ремонта: $e');
    }
  }

  @override
  Future<RepairModel> addRepair(RepairModel repair) async {
    try {
      final hiveModel = RepairHiveModel.fromEntity(repair);
      hiveModel.version = 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(repair.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: repair.id,
        entityType: EntityType.repair,
        operation: ChangeOperation.create,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return repair;
    } catch (e) {
      throw CacheException(message: 'Ошибка добавления ремонта: $e');
    }
  }

  @override
  Future<RepairModel> updateRepair(RepairModel repair) async {
    try {
      final existing = _box.get(repair.id);
      if (existing == null) {
        throw CacheException(message: 'Ремонт не найден');
      }

      final hiveModel = RepairHiveModel.fromEntity(repair);
      hiveModel.version = existing.version + 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(repair.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: repair.id,
        entityType: EntityType.repair,
        operation: ChangeOperation.update,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return repair;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка обновления ремонта: $e');
    }
  }

  @override
  Future<void> deleteRepair(String repairId) async {
    try {
      final existing = _box.get(repairId);
      final version = (existing?.version ?? 0) + 1;

      await _box.delete(repairId);

      // Отслеживаем удаление для синхронизации
      await changeTracker?.track(
        entityId: repairId,
        entityType: EntityType.repair,
        operation: ChangeOperation.delete,
        version: version,
        data: null,
      );
    } catch (e) {
      throw CacheException(message: 'Ошибка удаления ремонта: $e');
    }
  }

  @override
  Future<List<RepairModel>> searchRepairs(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final repairs = _box.values.where((repair) {
        return repair.partType.toLowerCase().contains(queryLower) ||
            repair.partPosition.toLowerCase().contains(queryLower) ||
            repair.description.toLowerCase().contains(queryLower) ||
            repair.carMake.toLowerCase().contains(queryLower) ||
            repair.carModel.toLowerCase().contains(queryLower);
      }).toList();

      repairs.sort((a, b) => b.date.compareTo(a.date));
      return repairs.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return RepairModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка поиска ремонтов: $e');
    }
  }

  @override
  Future<List<RepairModel>> getRepairsFiltered(RepairFilterParams params) async {
    try {
      Iterable<RepairHiveModel> result = _box.values;

      // Фильтрация по carId
      if (params.carId != null) {
        result = result.where((r) => r.carId == params.carId);
      }

      // Фильтрация по clientId
      if (params.clientId != null) {
        result = result.where((r) => r.clientId == params.clientId);
      }

      // Фильтрация по статусам
      if (params.statuses != null && params.statuses!.isNotEmpty) {
        result = result.where((r) => params.statuses!.contains(r.statusIndex));
      }

      // Фильтрация по датам
      if (params.dateFrom != null) {
        final startOfDay = DateTime(
          params.dateFrom!.year,
          params.dateFrom!.month,
          params.dateFrom!.day,
        );
        result = result.where((r) => !r.date.isBefore(startOfDay));
      }
      if (params.dateTo != null) {
        final endOfDay = DateTime(
          params.dateTo!.year,
          params.dateTo!.month,
          params.dateTo!.day,
          23,
          59,
          59,
        );
        result = result.where((r) => !r.date.isAfter(endOfDay));
      }

      // Сортировка по дате (новые первыми)
      var list = result.toList();
      list.sort((a, b) => b.date.compareTo(a.date));

      // Пагинация
      if (params.offset != null && params.offset! > 0) {
        list = list.skip(params.offset!).toList();
      }
      if (params.limit != null && params.limit! > 0) {
        list = list.take(params.limit!).toList();
      }

      return list.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return RepairModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка фильтрации ремонтов: $e');
    }
  }

  @override
  Future<int> getRepairsCount([RepairFilterParams? params]) async {
    try {
      if (params == null || !params.hasFilters) {
        return _box.length;
      }

      Iterable<RepairHiveModel> result = _box.values;

      if (params.carId != null) {
        result = result.where((r) => r.carId == params.carId);
      }
      if (params.clientId != null) {
        result = result.where((r) => r.clientId == params.clientId);
      }
      if (params.statuses != null && params.statuses!.isNotEmpty) {
        result = result.where((r) => params.statuses!.contains(r.statusIndex));
      }
      if (params.dateFrom != null) {
        final startOfDay = DateTime(
          params.dateFrom!.year,
          params.dateFrom!.month,
          params.dateFrom!.day,
        );
        result = result.where((r) => !r.date.isBefore(startOfDay));
      }
      if (params.dateTo != null) {
        final endOfDay = DateTime(
          params.dateTo!.year,
          params.dateTo!.month,
          params.dateTo!.day,
          23,
          59,
          59,
        );
        result = result.where((r) => !r.date.isAfter(endOfDay));
      }

      return result.length;
    } catch (e) {
      throw CacheException(message: 'Ошибка подсчёта ремонтов: $e');
    }
  }
}
