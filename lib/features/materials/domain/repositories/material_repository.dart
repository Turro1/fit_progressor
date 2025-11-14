import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/materials/domain/entities/material.dart';

// Репозиторий материалов
abstract class MaterialRepository {

  // Получить все материалы на складе
  Future<Either<Failure, List<Material>>> getAllMaterials();

  // Получить материал по ID
  Future<Either<Failure, Material>> getMaterialById(String id);
  
  // Добавить новый материал
  Future<Either<Failure, Material>> addMaterial(Material material);

  // Обновить существующий материал
  Future<Either<Failure, Material>> updateMaterial(Material material);

  // Удалить материал
  Future<Either<Failure, void>> deleteMaterial(String id);

  // Поиск материалов по запросу
  Future<Either<Failure, List<Material>>> searchMaterials(String query);
}