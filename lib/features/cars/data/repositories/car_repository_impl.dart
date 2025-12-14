import 'package:dartz/dartz.dart';

import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source.dart';
import 'package:fit_progressor/features/cars/data/models/car_model.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';

class CarRepositoryImpl implements CarRepository {
  final CarLocalDataSource localDataSource;

  CarRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Car>> getCarById(String id) async {
    try {
      final car = await localDataSource.getCarById(id);
      return Right(car);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while retrieving car by ID'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while retrieving car by ID: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Car>> addCar(Car car) async {
    try {
      final carModel = CarModel.fromEntity(car);
      final result = await localDataSource.addCar(carModel);
      return Right(result);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while adding car'),
      );
    } catch (e) {
      return Left(
        CacheFailure(message: 'Unexpected error occurred while adding car: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(String carId) async {
    try {
      await localDataSource.deleteCar(carId);
      return const Right(null);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while deleting car'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while deleting car: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getCars() async {
    try {
      final cars = await localDataSource.getCars();
      return Right(cars);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while retrieving cars'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while retrieving cars: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getCarsByClient(String clientId) async {
    try {
      final clients = await localDataSource.getCarsByClient(clientId);
      return Right(clients);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while retrieving car'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while retrieving car: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Car>>> searchCars(String query) async {
    try {
      final clients = await localDataSource.searchCars(query);
      return Right(clients);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while searching cars'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while searching cars: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Car>> updateCar(Car car) async {
    try {
      final clientModel = CarModel.fromEntity(car);
      final result = await localDataSource.updateCar(clientModel);
      return Right(result);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while updating client'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while updating client: $e',
        ),
      );
    }
  }
}
