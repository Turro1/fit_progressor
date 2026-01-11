import 'package:hive/hive.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/exceptions/duplicate_exception.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/cars/data/models/car_model.dart';
import 'package:fit_progressor/features/cars/data/models/car_hive_model.dart';
import 'car_local_data_source.dart';

/// Hive implementation of CarLocalDataSource
class CarHiveDataSource implements CarLocalDataSource {
  Box<CarHiveModel> get _box => HiveConfig.getBox<CarHiveModel>(HiveBoxes.cars);

  @override
  Future<List<CarModel>> getCars() async {
    try {
      final cars = _box.values.toList();
      // Sort by createdAt descending (newest first)
      cars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cars.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return CarModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка загрузки автомобилей: $e');
    }
  }

  @override
  Future<CarModel> getCarById(String id) async {
    try {
      final hiveModel = _box.get(id);
      if (hiveModel == null) {
        throw CacheException(message: 'Автомобиль не найден');
      }
      return CarModel.fromEntity(hiveModel.toEntity());
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка получения автомобиля: $e');
    }
  }

  @override
  Future<CarModel> addCar(CarModel car) async {
    try {
      // Check for duplicate plate
      final existingWithPlate = _box.values.firstWhere(
        (c) => c.plate.toLowerCase() == car.plate.toLowerCase() && c.id != car.id,
        orElse: () => CarHiveModel(
          id: '',
          clientId: '',
          make: '',
          model: '',
          plate: '',
          clientName: '',
          createdAt: DateTime.now(),
        ),
      );
      if (existingWithPlate.id.isNotEmpty) {
        throw DuplicateException(
          message: 'Автомобиль с номером ${car.plate} уже существует',
        );
      }

      final hiveModel = CarHiveModel.fromEntity(car);
      await _box.put(car.id, hiveModel);
      return car;
    } catch (e) {
      if (e is DuplicateException || e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка добавления автомобиля: $e');
    }
  }

  @override
  Future<CarModel> updateCar(CarModel car) async {
    try {
      if (!_box.containsKey(car.id)) {
        throw CacheException(message: 'Автомобиль не найден');
      }

      // Check for duplicate plate (excluding current car)
      final existingWithPlate = _box.values.firstWhere(
        (c) => c.plate.toLowerCase() == car.plate.toLowerCase() && c.id != car.id,
        orElse: () => CarHiveModel(
          id: '',
          clientId: '',
          make: '',
          model: '',
          plate: '',
          clientName: '',
          createdAt: DateTime.now(),
        ),
      );
      if (existingWithPlate.id.isNotEmpty) {
        throw DuplicateException(
          message: 'Автомобиль с номером ${car.plate} уже существует',
        );
      }

      final hiveModel = CarHiveModel.fromEntity(car);
      await _box.put(car.id, hiveModel);
      return car;
    } catch (e) {
      if (e is DuplicateException || e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка обновления автомобиля: $e');
    }
  }

  @override
  Future<void> deleteCar(String carId) async {
    try {
      await _box.delete(carId);
    } catch (e) {
      throw CacheException(message: 'Ошибка удаления автомобиля: $e');
    }
  }

  @override
  Future<List<CarModel>> searchCars(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final cars = _box.values.where((car) {
        return car.make.toLowerCase().contains(queryLower) ||
            car.model.toLowerCase().contains(queryLower) ||
            car.plate.toLowerCase().contains(queryLower) ||
            car.clientName.toLowerCase().contains(queryLower);
      }).toList();

      // Sort by createdAt descending (newest first)
      cars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cars.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return CarModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка поиска автомобилей: $e');
    }
  }

  @override
  Future<List<CarModel>> getCarsByClient(String clientId) async {
    try {
      final cars = _box.values.where((car) => car.clientId == clientId).toList();
      // Sort by createdAt descending (newest first)
      cars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cars.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return CarModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка загрузки автомобилей клиента: $e');
    }
  }
}
