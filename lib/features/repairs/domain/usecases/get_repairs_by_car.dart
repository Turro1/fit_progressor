import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import '../entities/repair.dart';
import '../repositories/repair_repository.dart';

class GetRepairsByCar implements UseCase<List<Repair>, String> {
  final RepairRepository repairRepository;
  final ClientRepository clientRepository;

  GetRepairsByCar(this.repairRepository, this.clientRepository);

  @override
  Future<Either<Failure, List<Repair>>> call(String carId) async {
    final repairsEither = await repairRepository.getRepairsByCar(carId);

    return repairsEither.fold((failure) => Left(failure), (repairs) async {
      List<Repair> repairsWithClientData = [];
      for (var repair in repairs) {
        // Fetch client details
        final clientEither =
            await clientRepository.getClientById(repair.clientId);
        String? clientName;
        clientEither.fold(
          (failure) => null, // Handle failure, e.g., log it
          (client) {
            clientName = client.name;
          },
        );

        repairsWithClientData
            .add(repair.copyWith(clientName: clientName));
      }
      return Right(repairsWithClientData);
    });
  }
}
