import 'package:dartz/dartz.dart';

import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';
import 'package:fit_progressor/features/repairs/domain/repositories/repair_repository.dart';
import '../../../../core/usecases/usecase.dart';

class DeleteClient implements UseCase<void, String> {
  final ClientRepository repository;
  final CarRepository carRepository;
  final RepairRepository repairRepository;

  DeleteClient(this.repository, this.carRepository, this.repairRepository);

  @override
  Future<Either<Failure, void>> call(String clientId) async {
    // Cascade delete: first get all cars for this client
    final carsResult = await carRepository.getCarsByClient(clientId);

    // If we can get cars, delete all repairs for each car
    await carsResult.fold(
      (failure) async {
        // If we can't get cars, just continue - maybe there are none
      },
      (cars) async {
        // Delete all repairs for each car
        for (final car in cars) {
          final repairsResult = await repairRepository.getRepairs(
            carId: car.id,
          );
          await repairsResult.fold((failure) async {}, (repairs) async {
            // Delete each repair
            for (final repair in repairs) {
              await repairRepository.deleteRepair(repair.id);
            }
          });
          // Delete the car
          await carRepository.deleteCar(car.id);
        }
      },
    );

    // Finally, delete the client
    return await repository.deleteClient(clientId);
  }
}
