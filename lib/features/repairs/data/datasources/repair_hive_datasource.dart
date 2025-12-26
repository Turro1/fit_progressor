import 'package:hive/hive.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_model.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_hive_model.dart';
import 'repair_local_datasource.dart';

/// Hive implementation of RepairLocalDataSource
class RepairHiveDataSource implements RepairLocalDataSource {
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
      await _box.put(repair.id, hiveModel);
      return repair;
    } catch (e) {
      throw CacheException(message: 'Ошибка добавления ремонта: $e');
    }
  }

  @override
  Future<RepairModel> updateRepair(RepairModel repair) async {
    try {
      if (!_box.containsKey(repair.id)) {
        throw CacheException(message: 'Ремонт не найден');
      }
      final hiveModel = RepairHiveModel.fromEntity(repair);
      await _box.put(repair.id, hiveModel);
      return repair;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка обновления ремонта: $e');
    }
  }

  @override
  Future<void> deleteRepair(String repairId) async {
    try {
      await _box.delete(repairId);
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
}
