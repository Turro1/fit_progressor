import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/domain/entities/car.dart';

//Репозиторий автомобилей
abstract class CarRepository {

//Получить все автомобили
Future<Either<Failure, List<Car>>> getAllCars();

//Получить автомобиль по id
Future<Either<Failure, Car>> getCarById(String id);

//Добавить новый автомобиль
Future<Either<Failure, Car>> addCar(Car car);

//Обновить существующий автомобиль
Future<Either<Failure, Car>> updateCar(Car car);

//Удалить автомобиль
Future<Either<Failure, void>> deleteCar(String id); 

//Поиск автомобилей по запросу
Future<Either<Failure, List<Car>>> searchCars(String query);

//Получить количество ремонтов автомобиля
Future<Either<Failure, int>> getRepairCarsCount(String carId);
}