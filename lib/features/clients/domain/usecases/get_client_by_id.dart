import 'package:dartz/dartz.dart';
import 'package:car_repair_manager/core/error/failures/failure.dart';
import 'package:car_repair_manager/core/usecases/usecase.dart';
import 'package:car_repair_manager/features/clients/domain/entities/client.dart';
import 'package:car_repair_manager/features/clients/domain/repositories/client_repository.dart';

class GetClientById extends UseCase<Client, String> {
  final ClientRepository repository;

  GetClientById({required this.repository});

  @override
  Future<Either<Failure, Client>> call(String id) async {
    return await repository.getClientById(id);
  }
}
