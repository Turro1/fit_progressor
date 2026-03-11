import 'package:dartz/dartz.dart';
import 'package:car_repair_manager/core/error/failures/failure.dart';
import 'package:car_repair_manager/core/usecases/usecase.dart';
import 'package:car_repair_manager/features/cars/domain/repositories/car_repository.dart';
import 'package:car_repair_manager/features/clients/domain/entities/client.dart';
import 'package:car_repair_manager/features/clients/domain/repositories/client_repository.dart';

class GetClients implements UseCase<List<Client>, NoParams> {
  final ClientRepository clientRepository;
  final CarRepository carRepository;

  GetClients(this.clientRepository, this.carRepository);

  @override
  Future<Either<Failure, List<Client>>> call(NoParams params) async {
    final clientsEither = await clientRepository.getAllClients();
    final carsEither = await carRepository.getCars();

    return clientsEither.fold((failure) => Left(failure), (clients) {
      return carsEither.fold((failure) => Left(failure), (cars) {
        final clientsWithCarCount = clients.map((client) {
          final carCount = cars
              .where((car) => car.clientId == client.id)
              .length;
          return client.copyWith(carCount: carCount);
        }).toList();
        return Right(clientsWithCarCount);
      });
    });
  }
}
