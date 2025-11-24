import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_library_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class UpdateCar implements UseCase<Car, Car> {
  final CarRepository repository;
  final CarLibraryRepository libraryRepository;

  UpdateCar(this.repository, this.libraryRepository);

  @override
  Future<Either<Failure, Car>> call(Car params) async {
    // Обновляем библиотеку
    await libraryRepository.addToLibrary(params.make, params.model);
    return await repository.updateCar(params);
  }
}