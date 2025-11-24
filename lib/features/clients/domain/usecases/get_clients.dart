import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';


class GetClients implements UseCase<List<Client>, NoParams> {
  final ClientRepository repository;

  GetClients(this.repository);

  @override
  Future<Either<Failure, List<Client>>> call(NoParams params) async {
    return await repository.getAllClients();
  }
}