import 'dart:convert';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/exceptions/duplicate_exception.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class CarLocalDataSourceSharedPreferencesImpl implements CarLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String carsKey = 'cachedCars';

  CarLocalDataSourceSharedPreferencesImpl({required this.sharedPreferences});

  @override
  Future<CarModel> getCarById(String id) async {
    debugPrint('DEBUG: CarLocalDataSource - getCarById called for id: $id');
    final cars = await getCars();
    return cars.firstWhere(
      (car) => car.id == id,
      orElse: () => throw CacheException(message: 'Car with id $id not found'),
    );
  }

  @override
  Future<List<CarModel>> getCars() async {
    try {
      debugPrint('DEBUG: CarLocalDataSource - getCars called.');
      final jsonString = sharedPreferences.getString(carsKey);
      debugPrint(
        'DEBUG: CarLocalDataSource - Retrieved jsonString: $jsonString',
      );
      if (jsonString == null) {
        debugPrint(
          'DEBUG: CarLocalDataSource - No cached cars, returning empty list.',
        );
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      var result = jsonList.map((json) => CarModel.fromJson(json)).toList();
      debugPrint('DEBUG: CarLocalDataSource - Decoded ${result.length} cars.');
      return result;
    } catch (e) {
      debugPrint(
        'DEBUG: CarLocalDataSource - Error loading cars from cache: $e',
      );
      throw CacheException(message: 'Failed to load cars from cache: $e');
    }
  }

  @override
  Future<CarModel> addCar(CarModel car) async {
    try {
      debugPrint('DEBUG: CarLocalDataSource - addCar called for car: ${car.id}');
      var cars = await getCars();

      // Проверка уникальности номера
      final plateExists = cars.any((c) => c.plate == car.plate);
      if (plateExists) {
        throw DuplicateException(
          message: 'Автомобиль с номером ${car.plate} уже существует',
        );
      }

      debugPrint(
        'DEBUG: CarLocalDataSource - Cars before adding: ${cars.length}',
      );
      cars.add(car);
      debugPrint('DEBUG: CarLocalDataSource - Cars after adding: ${cars.length}');
      await _saveCars(cars);
      debugPrint('DEBUG: CarLocalDataSource - Car added successfully: ${car.id}');
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
      debugPrint(
        'DEBUG: CarLocalDataSource - updateCar called for car: ${car.id}',
      );
      final cars = await getCars();
      final index = cars.indexWhere((c) => c.id == car.id);
      if (index == -1) {
        debugPrint(
          'DEBUG: CarLocalDataSource - Car not found for update: ${car.id}',
        );
        throw Exception('Car not found');
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
      debugPrint(
        'DEBUG: CarLocalDataSource - Car updated successfully: ${car.id}',
      );
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
    debugPrint(
      'DEBUG: CarLocalDataSource - deleteCar called for carId: $carId',
    );
    final cars = await getCars();
    cars.removeWhere((c) => c.id == carId);
    await _saveCars(cars);
    debugPrint('DEBUG: CarLocalDataSource - Car deleted successfully: $carId');
  }

  @override
  Future<List<CarModel>> searchCars(String query) async {
    debugPrint(
      'DEBUG: CarLocalDataSource - searchCars called with query: $query',
    );
    final cars = await getCars();
    final lowercaseQuery = query.toLowerCase();
    final filteredCars = cars.where((car) {
      return car.make.toLowerCase().contains(lowercaseQuery) ||
          car.model.toLowerCase().contains(lowercaseQuery) ||
          car.plate.toLowerCase().contains(lowercaseQuery) ||
          car.clientName.toLowerCase().contains(lowercaseQuery);
    }).toList();
    debugPrint(
      'DEBUG: CarLocalDataSource - Found ${filteredCars.length} cars for query: $query',
    );
    return filteredCars;
  }

  @override
  Future<List<CarModel>> getCarsByClient(String clientId) async {
    debugPrint(
      'DEBUG: CarLocalDataSource - getCarsByClient called for clientId: $clientId',
    );
    final cars = await getCars();
    final clientCars = cars.where((car) => car.clientId == clientId).toList();
    debugPrint(
      'DEBUG: CarLocalDataSource - Found ${clientCars.length} cars for clientId: $clientId',
    );
    return clientCars;
  }

  Future<void> _saveCars(List<CarModel> cars) async {
    debugPrint(
      'DEBUG: CarLocalDataSource - _saveCars called. Saving ${cars.length} cars.',
    );
    final jsonList = cars.map((c) => c.toJson()).toList();
    final success = await sharedPreferences.setString(
      carsKey,
      json.encode(jsonList),
    );
    debugPrint('DEBUG: CarLocalDataSource - setString successful: $success');
    if (!success) {
      debugPrint(
        'DEBUG: CarLocalDataSource - Failed to save cars to SharedPreferences.',
      );
    }
  }
}
