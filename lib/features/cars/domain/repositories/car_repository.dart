import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../entities/car.dart';

abstract class CarRepository {
  // Получить все машины
  Future<Either<Failure, List<Car>>> getCars();

  //  Добавить машину
  Future<Either<Failure, Car>> addCar(Car car);

  // Обновить машину
  Future<Either<Failure, Car>> updateCar(Car car);

  // Удалить машину
  Future<Either<Failure, void>> deleteCar(String carId);

  // Поиск машин по модели или номеру
  Future<Either<Failure, List<Car>>> searchCars(String query);

  // Получить машины по ID клиента
  Future<Either<Failure, List<Car>>> getCarsByClient(String clientId);
}