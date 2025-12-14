import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart'; // Using package import
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart'; // Using package import
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class GetRepairs implements UseCase<List<Repair>, NoParams> {
  final RepairRepository repairRepository;
  final CarRepository carRepository;
  final ClientRepository clientRepository;

  GetRepairs(this.repairRepository, this.carRepository, this.clientRepository);

  @override
  Future<Either<Failure, List<Repair>>> call(NoParams params) async {
    final repairsEither = await repairRepository.getRepairs();

    return repairsEither.fold((failure) => Left(failure), (repairs) async {
      List<Repair> repairsWithData = [];
      for (var repair in repairs) {
        // Fetch car details
        final carEither = await carRepository.getCarById(repair.carId);
        String? carMake;
        String? carModel;
        String? carPlate;
        carEither.fold(
          (failure) => null, // Handle failure, e.g., log it
          (car) {
            carMake = car.make;
            carModel = car.model;
            carPlate = car.plate;
          },
        );

        // Fetch client details
        final clientEither = await clientRepository.getClientById(repair.clientId);
        String? clientName;
        clientEither.fold(
          (failure) => null, // Handle failure, e.g., log it
          (client) {
            clientName = client.name;
          },
        );

        repairsWithData.add(repair.copyWith(
          carMake: carMake,
          carModel: carModel,
          carPlate: carPlate,
          clientName: clientName,
        ));
      }
      return Right(repairsWithData);
    });
  }
}
