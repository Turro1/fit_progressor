import 'package:dartz/dartz.dart';

import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/features/clients/data/datasources/client_local_data_source.dart';
import 'package:fit_progressor/features/clients/data/models/client_model.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';
import 'package:fit_progressor/features/clients/domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientLocalDataSource localDataSource;

  ClientRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Client>> addClient(Client client) async {
    try {
      final clientModel = ClientModel.fromEntity(client);
      final result = await localDataSource.saveClient(clientModel);
      return Right(result);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while adding client'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while adding client: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteClient(String id) async {
    try {
      await localDataSource.deleteClient(id);
      return const Right(null);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while deleting client'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while deleting client: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Client>>> getAllClients() async {
    try {
      final clientModels = await localDataSource.getAllClients();
      final clients = clientModels.map((model) => model.toEntity()).toList();
      return Right(clients);
    } on CacheException catch (e) { // Catch the exception explicitly
      return Left(
        CacheFailure(message: 'Cache error occurred while retrieving clients: ${e.message}'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while retrieving clients: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Client>> getClientById(String id) async {
    try {
      final clients = await localDataSource.getClientById(id);
      return Right(clients);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while retrieving client'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while retrieving client: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Client>>> searchClients(String query) async {
    try {
      final clients = await localDataSource.searchClients(query);
      return Right(clients);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while searching clients'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while searching clients: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Client>> updateClient(Client client) async {
    try {
      final clientModel = ClientModel.fromEntity(client);
      final result = await localDataSource.updateClient(clientModel);
      return Right(result);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Cache error occurred while updating client'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Unexpected error occurred while updating client: $e',
        ),
      );
    }
  }
}
