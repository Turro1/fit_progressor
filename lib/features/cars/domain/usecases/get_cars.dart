import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class GetCars implements UseCase<List<Car>, NoParams> {
  final CarRepository carRepository;
  final ClientRepository clientRepository;

  GetCars(this.carRepository, this.clientRepository);

  @override
  Future<Either<Failure, List<Car>>> call(NoParams params) async {
    final carsEither = await carRepository.getCars();
    final clientsEither = await clientRepository.getAllClients();

    return carsEither.fold((failure) => Left(failure), (cars) {
      return clientsEither.fold((failure) => Left(failure), (clients) {
        final carsWithClientName = cars.map((car) {
          final client = clients.firstWhere(
            (cl) => cl.id == car.clientId,
            orElse: () => Client(
              id: '',
              name: 'Владелец не найден',
              phone: '',
              createdAt: DateTime.now(),
            ),
          );
          return car.copyWith(clientName: client.name);
        }).toList();
        return Right(carsWithClientName);
      });
    });
  }
}
