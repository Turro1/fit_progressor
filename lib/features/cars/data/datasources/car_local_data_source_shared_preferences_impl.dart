import 'dart:convert';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/exceptions/duplicate_exception.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';

class CarLocalDataSourceSharedPreferencesImpl implements CarLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String carsKey = 'cachedCars';

  CarLocalDataSourceSharedPreferencesImpl({required this.sharedPreferences});

  @override
  Future<CarModel> getCarById(String id) async {
    final cars = await getCars();
    return cars.firstWhere(
      (car) => car.id == id,
      orElse: () => throw CacheException(message: 'Car with id $id not found'),
    );
  }

  @override
  Future<List<CarModel>> getCars() async {
    try {
      final jsonString = sharedPreferences.getString(carsKey);
      if (jsonString == null) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CarModel.fromJson(json)).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to load cars from cache: $e');
    }
  }

  @override
  Future<CarModel> addCar(CarModel car) async {
    try {
      var cars = await getCars();

      // Проверка уникальности номера
      final plateExists = cars.any((c) => c.plate == car.plate);
      if (plateExists) {
        throw DuplicateException(
          message: 'Автомобиль с номером ${car.plate} уже существует',
        );
      }

      cars.add(car);
      await _saveCars(cars);
      return car;
    } catch (e) {
      if (e is DuplicateException) {
        rethrow;
      }
      throw CacheException(message: 'Failed to add car to cache: $e');
    }
  }

  @override
  Future<CarModel> updateCar(CarModel car) async {
    try {
      final cars = await getCars();
      final index = cars.indexWhere((c) => c.id == car.id);
      if (index == -1) {
        throw CacheException(message: 'Car not found');
      }

      // Проверка уникальности номера (исключая текущий автомобиль)
      final plateExists = cars.any(
        (c) => c.plate == car.plate && c.id != car.id,
      );
      if (plateExists) {
        throw DuplicateException(
          message: 'Автомобиль с номером ${car.plate} уже существует',
        );
      }

      cars[index] = car;
      await _saveCars(cars);
      return car;
    } catch (e) {
      if (e is DuplicateException) {
        rethrow;
      }
      throw CacheException(message: 'Failed to update car in cache: $e');
    }
  }

  @override
  Future<void> deleteCar(String carId) async {
    final cars = await getCars();
    cars.removeWhere((c) => c.id == carId);
    await _saveCars(cars);
  }

  @override
  Future<List<CarModel>> searchCars(String query) async {
    final cars = await getCars();
    final lowercaseQuery = query.toLowerCase();
    return cars.where((car) {
      return car.make.toLowerCase().contains(lowercaseQuery) ||
          car.model.toLowerCase().contains(lowercaseQuery) ||
          car.plate.toLowerCase().contains(lowercaseQuery) ||
          car.clientName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<List<CarModel>> getCarsByClient(String clientId) async {
    final cars = await getCars();
    return cars.where((car) => car.clientId == clientId).toList();
  }

  Future<void> _saveCars(List<CarModel> cars) async {
    final jsonList = cars.map((c) => c.toJson()).toList();
    await sharedPreferences.setString(carsKey, json.encode(jsonList));
  }
}
