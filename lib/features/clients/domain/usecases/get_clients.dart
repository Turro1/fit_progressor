import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/cars/domain/repositories/car_repository.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';

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
