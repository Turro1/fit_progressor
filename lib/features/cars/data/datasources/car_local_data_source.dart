import 'package:fit_progressor/features/cars/data/models/car_model.dart';

/// Параметры фильтрации для getCarsFiltered
class CarFilterParams {
  final String? clientId;
  final List<String>? makes;
  final String? searchQuery;
  final int? limit;
  final int? offset;

  const CarFilterParams({
    this.clientId,
    this.makes,
    this.searchQuery,
    this.limit,
    this.offset,
  });

  bool get hasFilters =>
      clientId != null ||
      (makes != null && makes!.isNotEmpty) ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

abstract class CarLocalDataSource {
  Future<CarModel> getCarById(String id);

  // Получить список всех машин
  Future<List<CarModel>> getCars();

  // Добавить новую машину
  Future<CarModel> addCar(CarModel car);

  // Обновить информацию о машине
  Future<CarModel> updateCar(CarModel car);

  // Удалить машину по ID
  Future<void> deleteCar(String carId);

  // Поиск машин по модели или номеру
  Future<List<CarModel>> searchCars(String query);

  // Получить машины по ID клиента
  Future<List<CarModel>> getCarsByClient(String clientId);

  /// Загружает машины с фильтрацией на уровне datasource (оптимизация)
  Future<List<CarModel>> getCarsFiltered(CarFilterParams params);

  /// Возвращает общее количество машин (для пагинации)
  Future<int> getCarsCount([CarFilterParams? params]);

  /// Возвращает список уникальных марок машин
  Future<List<String>> getUniqueMakes();
}
