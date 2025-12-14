import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../entities/car_library.dart';

abstract class CarLibraryRepository {
  // Получить библиотеку машин
  Future<Either<Failure, CarLibrary>> getCarLibrary();

  // Получить список марок машин
  Future<Either<Failure, List<String>>> getCarMakes();

  // Получить список моделей машин по марке
  Future<Either<Failure, List<String>>> getCarModels(String make);

  // Добавить марку и модель в библиотеку
  Future<Either<Failure, void>> addToLibrary(String make, String model);
}
