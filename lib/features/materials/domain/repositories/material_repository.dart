import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../entities/material.dart';

abstract class MaterialRepository {
  Future<Either<Failure, List<Material>>> getAllMaterials();
  Future<Either<Failure, Material>> getMaterialById(String id);
  Future<Either<Failure, Material>> addMaterial(Material material);
  Future<Either<Failure, Material>> updateMaterial(Material material);
  Future<Either<Failure, void>> deleteMaterial(String id);
}
