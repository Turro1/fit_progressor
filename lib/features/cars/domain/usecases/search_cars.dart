import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class SearchCars implements UseCase<List<Car>, String> {
  final CarRepository carRepository;
  final ClientRepository clientRepository;

  SearchCars(this.carRepository, this.clientRepository);

  @override
  Future<Either<Failure, List<Car>>> call(String params) async {
    // Сначала получаем ВСЕ автомобили
    final carsEither = await carRepository.getCars();
    final clientsEither = await clientRepository.getAllClients();

    return carsEither.fold((failure) => Left(failure), (cars) {
      return clientsEither.fold((failure) => Left(failure), (clients) {
        // Заполняем clientName для всех автомобилей
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

        // Теперь фильтруем по запросу (поиск по всем полям)
        if (params.isEmpty) {
          return Right(carsWithClientName);
        }

        final lowercaseQuery = params.toLowerCase();
        final filteredCars = carsWithClientName.where((car) {
          return car.make.toLowerCase().contains(lowercaseQuery) ||
              car.model.toLowerCase().contains(lowercaseQuery) ||
              car.plate.toLowerCase().contains(lowercaseQuery) ||
              car.clientName.toLowerCase().contains(lowercaseQuery);
        }).toList();

        return Right(filteredCars);
      });
    });
  }
}
