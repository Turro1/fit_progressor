import 'package:hive/hive.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';
import 'package:fit_progressor/features/materials/data/models/material_model.dart';
import 'package:fit_progressor/features/materials/data/models/material_hive_model.dart';
import 'material_local_data_source.dart';

/// Hive implementation of MaterialLocalDataSource
class MaterialHiveDataSource implements MaterialLocalDataSource {
  final ChangeTracker? changeTracker;

  MaterialHiveDataSource({this.changeTracker});

  Box<MaterialHiveModel> get _box => HiveConfig.getBox<MaterialHiveModel>(HiveBoxes.materials);

  @override
  Future<List<MaterialModel>> getMaterials() async {
    try {
      final materials = _box.values.toList();
      // Sort by name
      materials.sort((a, b) => a.name.compareTo(b.name));
      return materials.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return MaterialModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка загрузки материалов: $e');
    }
  }

  @override
  Future<void> cacheMaterials(List<MaterialModel> materials) async {
    try {
      // Clear and repopulate (for compatibility with existing interface)
      await _box.clear();
      for (final material in materials) {
        final hiveModel = MaterialHiveModel.fromEntity(material);
        hiveModel.version = 1;
        hiveModel.updatedAt = DateTime.now();
        await _box.put(material.id, hiveModel);
      }
    } catch (e) {
      throw CacheException(message: 'Ошибка сохранения материалов: $e');
    }
  }

  // Extended methods for better Hive utilization

  /// Get material by ID
  Future<MaterialModel> getMaterialById(String id) async {
    try {
      final hiveModel = _box.get(id);
      if (hiveModel == null) {
        throw CacheException(message: 'Материал не найден');
      }
      return MaterialModel.fromEntity(hiveModel.toEntity());
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка получения материала: $e');
    }
  }

  /// Add a single material
  Future<MaterialModel> addMaterial(MaterialModel material) async {
    try {
      final hiveModel = MaterialHiveModel.fromEntity(material);
      hiveModel.version = 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(material.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: material.id,
        entityType: EntityType.material,
        operation: ChangeOperation.create,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return material;
    } catch (e) {
      throw CacheException(message: 'Ошибка добавления материала: $e');
    }
  }

  /// Update a single material
  Future<MaterialModel> updateMaterial(MaterialModel material) async {
    try {
      final existing = _box.get(material.id);
      if (existing == null) {
        throw CacheException(message: 'Материал не найден');
      }

      final hiveModel = MaterialHiveModel.fromEntity(material);
      hiveModel.version = existing.version + 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(material.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: material.id,
        entityType: EntityType.material,
        operation: ChangeOperation.update,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return material;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка обновления материала: $e');
    }
  }

  /// Delete a single material
  Future<void> deleteMaterial(String id) async {
    try {
      final existing = _box.get(id);
      final version = (existing?.version ?? 0) + 1;

      await _box.delete(id);

      // Отслеживаем удаление для синхронизации
      await changeTracker?.track(
        entityId: id,
        entityType: EntityType.material,
        operation: ChangeOperation.delete,
        version: version,
        data: null,
      );
    } catch (e) {
      throw CacheException(message: 'Ошибка удаления материала: $e');
    }
  }

  /// Search materials by name
  Future<List<MaterialModel>> searchMaterials(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final materials = _box.values.where((material) {
        return material.name.toLowerCase().contains(queryLower);
      }).toList();

      materials.sort((a, b) => a.name.compareTo(b.name));
      return materials.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return MaterialModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка поиска материалов: $e');
    }
  }
}
