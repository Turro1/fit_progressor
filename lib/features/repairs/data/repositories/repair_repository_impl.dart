import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_model.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';

class RepairRepositoryImpl implements RepairRepository {
  final RepairLocalDataSource localDataSource;

  RepairRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Repair>>> getRepairs({String? carId}) async {
    try {
      final repairs = await localDataSource.getRepairs();
      List<Repair> filteredRepairs = repairs;
      if (carId != null) {
        filteredRepairs = repairs
            .where((repair) => repair.carId == carId)
            .toList();
      }

      return Right(filteredRepairs);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }

  @override
  Future<Either<Failure, Repair>> getRepairById(String id) async {
    try {
      final repair = await localDataSource.getRepairById(id);
      return Right(repair);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }

  @override
  Future<Either<Failure, Repair>> addRepair(Repair repair) async {
    try {
      final repairModel = RepairModel.fromEntity(repair);
      final result = await localDataSource.addRepair(repairModel);
      return Right(result);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }

  @override
  Future<Either<Failure, Repair>> updateRepair(Repair repair) async {
    try {
      final repairModel = RepairModel.fromEntity(repair);
      final result = await localDataSource.updateRepair(repairModel);
      return Right(result);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRepair(String repairId) async {
    try {
      await localDataSource.deleteRepair(repairId);
      return const Right(null);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }

  @override
  Future<Either<Failure, List<Repair>>> searchRepairs(
    String query, {
    String? carId,
  }) async {
    try {
      final repairs = await localDataSource.searchRepairs(query);
      List<Repair> filteredRepairs = repairs;
      if (carId != null) {
        filteredRepairs = filteredRepairs
            .where((repair) => repair.carId == carId)
            .toList();
      }
      return Right(filteredRepairs);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }
}
