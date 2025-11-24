import 'package:dartz/dartz.dart';

import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_library_local_data_source.dart';
import 'package:fit_progressor/features/cars/domain/entities/car_library.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_library_repository.dart';

class CarLibraryRepositoryImpl implements CarLibraryRepository {
  final CarLibraryLocalDataSource localDataSource;

  CarLibraryRepositoryImpl({required this.localDataSource});

 @override
  Future<Either<Failure, CarLibrary>> getCarLibrary() async {
    try {
      final library = await localDataSource.getCarLibrary();
      return Right(library);
    } on CacheException {
      return Left(CacheFailure(message: 'Cache error occurred while retrieving car library'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error occurred while retrieving car library: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCarMakes() async {
    try {
      final makes = await localDataSource.getCarMakes();
      return Right(makes);
    } on CacheException {
      return Left(CacheFailure(message: 'Cache error occurred while retrieving car makes'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error occurred while retrieving car makes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCarModels(String make) async {
    try {
      final models = await localDataSource.getCarModels(make);
      return Right(models);
    } on CacheException {
      return Left(CacheFailure(message: 'Cache error occurred while retrieving car models'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error occurred while retrieving car models: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToLibrary(String make, String model) async {
    try {
      await localDataSource.addToLibrary(make, model);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure(message: 'Cache error occurred while adding to car library'));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error occurred while adding to car library: $e'));
    }
  }
}