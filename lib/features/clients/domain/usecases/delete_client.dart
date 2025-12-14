import 'package:dartz/dartz.dart';

import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';
import '../../../../core/usecases/usecase.dart';

class DeleteClient implements UseCase<void, String> {
  final ClientRepository repository;

  DeleteClient(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteClient(params);
  }
}
