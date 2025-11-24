import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../../domain/entities/repair.dart';
import '../../domain/entities/repair_status.dart';
import '../../domain/repositories/repair_repository.dart';
import '../datasources/repair_local_datasource.dart';
import '../models/repair_model.dart';

class RepairRepositoryImpl implements RepairRepository {
  final RepairLocalDataSource localDataSource;

  RepairRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Repair>>> getRepairs() async {
    try {
      final repairs = await localDataSource.getRepairs();
      return Right(repairs);
    } on CacheException {
      return Left(CacheFailure(message: ''));
    } catch (e) {
      return Left(CacheFailure(message: ''));
    }
  }

  @override
  Future<Either<Failure, Repair>> addRepair(Repair repair) async {
    try {
      final repairModel = RepairModel.fromEntity(repair);
      final result = await localDataSource.addRepair(repairModel);
      return Right(result);
    } on CacheException {
      return Left(CacheFailure(message: ''));
    } catch (e) {
      return Left(CacheFailure(message: ''));
    }
  }

  @override
  Future<Either<Failure, Repair>> updateRepair(Repair repair) async {
    try {
      final repairModel = RepairModel.fromEntity(repair);
      final result = await localDataSource.updateRepair(repairModel);
      return Right(result);
    } on CacheException {
      return Left(CacheFailure(message: ''));
    } catch (e) {
      return Left(CacheFailure(message: ''));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRepair(String repairId) async {
    try {
      await localDataSource.deleteRepair(repairId);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure(message: ''));
    } catch (e) {
      return Left(CacheFailure(message: ''));
    }
  }

  @override
  Future<Either<Failure, List<Repair>>> searchRepairs(String query) async {
    try {
      final repairs = await localDataSource.searchRepairs(query);
      return Right(repairs);
    } on CacheException {
      return Left(CacheFailure(message: ''));
    } catch (e) {
      return Left(CacheFailure(message: ''));
    }
  }

  @override
  Future<Either<Failure, List<Repair>>> getRepairsByStatus(
      RepairStatus status) async {
    try {
      final repairs = await localDataSource.getRepairsByStatus(status);
      return Right(repairs);
    } on CacheException {
      return Left(CacheFailure(message: ''));
    } catch (e) {
      return Left(CacheFailure(message: ''));
    }
  }

  @override
  Future<Either<Failure, List<Repair>>> getRepairsByCar(String carId) async {
    try {
      final repairs = await localDataSource.getRepairsByCar(carId);
      return Right(repairs);
    } on CacheException {
      return Left(CacheFailure(message: ''));
    } catch (e) {
      return Left(CacheFailure(message: ''));
    }
  }
}