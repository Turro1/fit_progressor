import 'package:fit_progressor/features/cars/data/models/car_model.dart';

// Локальное хранилище автомобилей
abstract class CarLocalDataSource {

// Получить все автомобили 
Future<List<CarModel>> getAllCars();

// Получить автомобиль по ID
Future<CarModel> getCarById(String id);

// Сохранить автомобиль
Future<CarModel> saveCar(CarModel car);

// Обновить автомобиль
Future<CarModel> upadteCar(CarModel car);

// Удалить автомобиль
Future<void> deleteCar(String id);

// Поиск автомобилей
Future<List<CarModel>> searchCars(String query);
}