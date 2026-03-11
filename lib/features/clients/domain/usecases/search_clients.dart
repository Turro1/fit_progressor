import 'package:dartz/dartz.dart';

import 'package:car_repair_manager/core/error/failures/failure.dart';
import 'package:car_repair_manager/core/usecases/usecase.dart';
import 'package:car_repair_manager/features/clients/domain/entities/client.dart';
import 'package:car_repair_manager/features/clients/domain/repositories/client_repository.dart';

class SearchClients implements UseCase<List<Client>, String> {
  final ClientRepository repository;

  SearchClients(this.repository);

  @override
  Future<Either<Failure, List<Client>>> call(String params) async {
    return await repository.searchClients(params);
  }
}
