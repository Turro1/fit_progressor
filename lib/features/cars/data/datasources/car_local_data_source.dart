import 'package:fit_progressor/features/cars/data/models/car_model.dart';

abstract class CarLocalDataSource {
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
}