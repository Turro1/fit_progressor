import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/materials/data/models/material_model.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';
import '../datasources/material_local_data_source.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialLocalDataSource localDataSource;

  MaterialRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Material>>> getAllMaterials() async {
    try {
      final localMaterials = await localDataSource.getMaterials();
      return Right(localMaterials);
    } on CacheException {
      return Left(const CacheFailure(message: ''));
    }
  }

  @override
  Future<Either<Failure, Material>> getMaterialById(String id) async {
    try {
      final material = await localDataSource.getMaterialById(id);
      return Right(material);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Material>> addMaterial(Material material) async {
    try {
      final result = await localDataSource.addMaterial(
        MaterialModel.fromEntity(material),
      );
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Material>> updateMaterial(Material material) async {
    try {
      final result = await localDataSource.updateMaterial(
        MaterialModel.fromEntity(material),
      );
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMaterial(String id) async {
    try {
      await localDataSource.deleteMaterial(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
