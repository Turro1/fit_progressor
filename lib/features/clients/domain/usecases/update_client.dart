import 'package:dartz/dartz.dart';
import 'package:car_repair_manager/core/error/failures/failure.dart';
import 'package:car_repair_manager/features/clients/domain/entities/client.dart';
import 'package:car_repair_manager/features/clients/domain/repositories/client_repository.dart';
import '../../../../core/usecases/usecase.dart';

class UpdateClient implements UseCase<Client, Client> {
  final ClientRepository repository;

  UpdateClient(this.repository);

  @override
  Future<Either<Failure, Client>> call(Client params) async {
    return await repository.updateClient(params);
  }
}
