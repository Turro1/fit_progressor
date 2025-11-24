import '../models/car_library_model.dart';

abstract class CarLibraryLocalDataSource {
  // Получить библиотеку машин
  Future<CarLibraryModel> getCarLibrary();

  // Получить список марок машин
  Future<List<String>> getCarMakes();

  // Получить список моделей машин по марке
  Future<List<String>> getCarModels(String make);

  // Добавить марку и модель в библиотеку
  Future<void> addToLibrary(String make, String model);
}
