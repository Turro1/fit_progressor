import 'package:hive/hive.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/exceptions/duplicate_exception.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';
import 'package:fit_progressor/features/cars/data/models/car_model.dart';
import 'package:fit_progressor/features/cars/data/models/car_hive_model.dart';
import 'car_local_data_source.dart';

/// Hive implementation of CarLocalDataSource
class CarHiveDataSource implements CarLocalDataSource {
  final ChangeTracker? changeTracker;

  CarHiveDataSource({this.changeTracker});

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
      hiveModel.version = 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(car.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: car.id,
        entityType: EntityType.car,
        operation: ChangeOperation.create,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return car;
    } catch (e) {
      if (e is DuplicateException || e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка добавления автомобиля: $e');
    }
  }

  @override
  Future<CarModel> updateCar(CarModel car) async {
    try {
      final existing = _box.get(car.id);
      if (existing == null) {
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
      hiveModel.version = existing.version + 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(car.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: car.id,
        entityType: EntityType.car,
        operation: ChangeOperation.update,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return car;
    } catch (e) {
      if (e is DuplicateException || e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка обновления автомобиля: $e');
    }
  }

  @override
  Future<void> deleteCar(String carId) async {
    try {
      final existing = _box.get(carId);
      final version = (existing?.version ?? 0) + 1;

      await _box.delete(carId);

      // Отслеживаем удаление для синхронизации
      await changeTracker?.track(
        entityId: carId,
        entityType: EntityType.car,
        operation: ChangeOperation.delete,
        version: version,
        data: null,
      );
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

  @override
  Future<List<CarModel>> getCarsFiltered(CarFilterParams params) async {
    try {
      Iterable<CarHiveModel> result = _box.values;

      // Фильтрация по clientId
      if (params.clientId != null) {
        result = result.where((c) => c.clientId == params.clientId);
      }

      // Фильтрация по маркам
      if (params.makes != null && params.makes!.isNotEmpty) {
        result = result.where((c) => params.makes!.contains(c.make));
      }

      // Поиск по тексту
      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        final query = params.searchQuery!.toLowerCase();
        result = result.where((c) =>
            c.make.toLowerCase().contains(query) ||
            c.model.toLowerCase().contains(query) ||
            c.plate.toLowerCase().contains(query) ||
            c.clientName.toLowerCase().contains(query));
      }

      // Сортировка по дате создания (новые первыми)
      var list = result.toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Пагинация
      if (params.offset != null && params.offset! > 0) {
        list = list.skip(params.offset!).toList();
      }
      if (params.limit != null && params.limit! > 0) {
        list = list.take(params.limit!).toList();
      }

      return list.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return CarModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка фильтрации автомобилей: $e');
    }
  }

  @override
  Future<int> getCarsCount([CarFilterParams? params]) async {
    try {
      if (params == null || !params.hasFilters) {
        return _box.length;
      }

      Iterable<CarHiveModel> result = _box.values;

      if (params.clientId != null) {
        result = result.where((c) => c.clientId == params.clientId);
      }
      if (params.makes != null && params.makes!.isNotEmpty) {
        result = result.where((c) => params.makes!.contains(c.make));
      }
      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        final query = params.searchQuery!.toLowerCase();
        result = result.where((c) =>
            c.make.toLowerCase().contains(query) ||
            c.model.toLowerCase().contains(query) ||
            c.plate.toLowerCase().contains(query) ||
            c.clientName.toLowerCase().contains(query));
      }

      return result.length;
    } catch (e) {
      throw CacheException(message: 'Ошибка подсчёта автомобилей: $e');
    }
  }

  @override
  Future<List<String>> getUniqueMakes() async {
    try {
      final makes = _box.values.map((c) => c.make).toSet().toList();
      makes.sort();
      return makes;
    } catch (e) {
      throw CacheException(message: 'Ошибка получения марок: $e');
    }
  }
}
