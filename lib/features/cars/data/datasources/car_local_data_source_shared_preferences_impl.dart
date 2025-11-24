import 'dart:convert';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/features/cars/data/datasources/car_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';

class CarLocalDataSourceSharedPreferencesImpl implements CarLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CARS_KEY = 'CACHED_CARS';

  CarLocalDataSourceSharedPreferencesImpl({required this.sharedPreferences});

  @override
  Future<List<CarModel>> getCars() async {
    try{
        final jsonString = sharedPreferences.getString(CARS_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    var result =  jsonList.map((json) => CarModel.fromJson(json)).toList();
    return result;
    }
    catch(e){
    throw CacheException(message: 'Failed to load cars from cache: $e');
    }
  }

  @override
  Future<CarModel> addCar(CarModel car) async {
    var cars = await getCars();
    cars.add(car);
    await _saveCars(cars);
    return car;
  }

  @override
  Future<CarModel> updateCar(CarModel car) async {
    final cars = await getCars();
    final index = cars.indexWhere((c) => c.id == car.id);
    if (index == -1) {
      throw Exception('Car not found');
    }
    cars[index] = car;
    await _saveCars(cars);
    return car;
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
          car.plate.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<List<CarModel>> getCarsByClient(String clientId) async {
    final cars = await getCars();
    return cars.where((car) => car.clientId == clientId).toList();
  }

  Future<void> _saveCars(List<CarModel> cars) async {
    final jsonList = cars.map((c) => c.toJson()).toList();
    await sharedPreferences.setString(CARS_KEY, json.encode(jsonList));
  }
}