import 'package:hive/hive.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/materials/data/models/material_model.dart';
import 'package:fit_progressor/features/materials/data/models/material_hive_model.dart';
import 'material_local_data_source.dart';

/// Hive implementation of MaterialLocalDataSource
class MaterialHiveDataSource implements MaterialLocalDataSource {
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
      await _box.put(material.id, hiveModel);
      return material;
    } catch (e) {
      throw CacheException(message: 'Ошибка добавления материала: $e');
    }
  }

  /// Update a single material
  Future<MaterialModel> updateMaterial(MaterialModel material) async {
    try {
      if (!_box.containsKey(material.id)) {
        throw CacheException(message: 'Материал не найден');
      }
      final hiveModel = MaterialHiveModel.fromEntity(material);
      await _box.put(material.id, hiveModel);
      return material;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка обновления материала: $e');
    }
  }

  /// Delete a single material
  Future<void> deleteMaterial(String id) async {
    try {
      await _box.delete(id);
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
