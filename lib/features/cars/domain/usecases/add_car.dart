import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_library_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class AddCar implements UseCase<Car, AddCarParams> {
  final CarRepository repository;
  final CarLibraryRepository libraryRepository;

  AddCar(this.repository, this.libraryRepository);

  @override
  Future<Either<Failure, Car>> call(AddCarParams params) async {
    final car = Car(
      id: 'car_${DateTime.now().millisecondsSinceEpoch}',
      clientId: params.clientId,
      make: params.make.toUpperCase(),
      model: params.model,
      plate: params.plate,
      createdAt: DateTime.now(),
    );
    
    // Добавляем в библиотеку
    await libraryRepository.addToLibrary(car.make, car.model);
    
    return await repository.addCar(car);
  }
}

class AddCarParams {
  final String clientId;
  final String make;
  final String model;
  final String plate;

  AddCarParams({
    required this.clientId,
    required this.make,
    required this.model,
    required this.plate,
  });
}