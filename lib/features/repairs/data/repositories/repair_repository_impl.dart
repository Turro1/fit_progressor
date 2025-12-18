import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import 'package:fit_progressor/features/repairs/data/datasources/repair_local_datasource.dart';
import 'package:fit_progressor/features/repairs/data/models/car_photo_model.dart';
import 'package:fit_progressor/features/repairs/data/models/repair_model.dart';
import 'package:fit_progressor/features/repairs/domain/entities/car_photo.dart';
import 'package:fit_progressor/features/repairs/domain/entities/repair.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';

class RepairRepositoryImpl implements RepairRepository {
  final RepairLocalDataSource localDataSource;
  final CarRepository carRepository;
  final ClientRepository clientRepository;

  RepairRepositoryImpl({
    required this.localDataSource,
    required this.carRepository,
    required this.clientRepository,
  });

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

class CarPhotoRepositoryImpl implements CarPhotoRepository {
  final CarPhotoLocalDataSource localDataSource;

  CarPhotoRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CarPhoto>>> getCarPhotos(String carId) async {
    try {
      final photos = await localDataSource.getCarPhotos(carId);
      return Right(photos);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }

  @override
  Future<Either<Failure, CarPhoto>> addCarPhoto(CarPhoto photo) async {
    try {
      final photoModel = CarPhotoModel.fromEntity(photo);
      final result = await localDataSource.addCarPhoto(photoModel);
      return Right(result);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCarPhoto(String photoId) async {
    try {
      await localDataSource.deleteCarPhoto(photoId);
      return const Right(null);
    } on CacheException {
      return Left(const CacheFailure(message: 'Ошибка кэша'));
    }
  }
}
