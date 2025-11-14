import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/failures/cache_failure.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import 'package:fit_progressor/core/error/failures/validation_failure.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_local_data_source.dart';
import '../models/client_model.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientLocalDataSource localDataSource;

  ClientRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Client>>> getAllClients() async {
    try {
      final clientModels = await localDataSource.getAllClients();
      
      // Сортируем по имени
      clientModels.sort((a, b) => a.name.compareTo(b.name));
      
      // Конвертируем модели в entities
      final clients = clientModels.map((model) => model.toEntity()).toList();
      
      return Right(clients);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Client>> getClientById(String id) async {
    try {
      final clientModel = await localDataSource.getClientById(id);
      return Right(clientModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Client>> addClient(Client client) async {
    try {
      // Валидация
      if (client.name.trim().isEmpty) {
        return Left(ValidationFailure(message: 'Client name cannot be empty'));
      }

      final clientModel = ClientModel.fromEntity(client);
      final savedModel = await localDataSource.saveClient(clientModel);
      
      return Right(savedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Client>> updateClient(Client client) async {
    try {
      // Валидация
      if (client.name.trim().isEmpty) {
        return Left(ValidationFailure(message: 'Client name cannot be empty'));
      }

      final clientModel = ClientModel.fromEntity(client);
      final updatedModel = await localDataSource.updateClient(clientModel);
      
      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClient(String id) async {
    try {
      await localDataSource.deleteClient(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Client>>> searchClients(String query) async {
    try {
      if (query.trim().isEmpty) {
        // Если запрос пустой, возвращаем всех клиентов
        return getAllClients();
      }

      final clientModels = await localDataSource.searchClients(query);
      
      // Сортируем по релевантности (сначала точные совпадения)
      clientModels.sort((a, b) {
        final aStartsWith = a.name.toLowerCase().startsWith(query.toLowerCase());
        final bStartsWith = b.name.toLowerCase().startsWith(query.toLowerCase());
        
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;
        return a.name.compareTo(b.name);
      });
      
      final clients = clientModels.map((model) => model.toEntity()).toList();
      
      return Right(clients);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getClientCarsCount(String clientId) async {
    try {
      // Эта логика будет зависеть от CarRepository
      // Здесь показан пример, как это может быть реализовано
      
      // TODO: Внедрить зависимость от CarRepository
      // final carsResult = await carRepository.getCarsByClient(clientId);
      
      // return carsResult.fold(
      //   (failure) => Left(failure),
      //   (cars) => Right(cars.length),
      // );
      
      // Пока возвращаем 0
      return const Right(0);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get cars count: $e'));
    }
  }
}