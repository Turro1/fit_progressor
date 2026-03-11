import 'package:dartz/dartz.dart';

import 'package:car_repair_manager/core/error/failures/failure.dart';
import 'package:car_repair_manager/features/clients/domain/entities/client.dart';
import 'package:car_repair_manager/features/clients/domain/repositories/client_repository.dart';
import '../../../../core/usecases/usecase.dart';

class AddClient implements UseCase<Client, AddClientParams> {
  final ClientRepository repository;

  AddClient(this.repository);

  @override
  Future<Either<Failure, Client>> call(AddClientParams params) async {
    final client = Client(
      id: 'client_${DateTime.now().millisecondsSinceEpoch}',
      name: params.name,
      phone: params.phone,
      createdAt: DateTime.now(),
    );

    return await repository.addClient(client);
  }
}

class AddClientParams {
  final String name;
  final String phone;

  AddClientParams({required this.name, required this.phone});
}
