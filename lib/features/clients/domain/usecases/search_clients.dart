import 'package:dartz/dartz.dart';

import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/usecases/usecase.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';

class SearchClients implements UseCase<List<Client>, String> {
  final ClientRepository repository;

  SearchClients(this.repository);

  @override
  Future<Either<Failure, List<Client>>> call(String params) async {
    return await repository.searchClients(params);
  }
}