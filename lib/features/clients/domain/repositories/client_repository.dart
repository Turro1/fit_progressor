import 'package:dartz/dartz.dart';
import 'package:fit_progressor/core/error/failures/failure.dart';
import '../entities/client.dart';

//Репозиторий клиентов
abstract class ClientRepository {

  /// Получить всех клиентов
  Future<Either<Failure, List<Client>>> getAllClients();

  /// Получить клиента по ID
  Future<Either<Failure, Client>> getClientById(String id);

  /// Добавить нового клиента
  Future<Either<Failure, Client>> addClient(Client client);

  /// Обновить существующего клиента
  Future<Either<Failure, Client>> updateClient(Client client);

  /// Удалить клиента
  Future<Either<Failure, void>> deleteClient(String id);

  /// Поиск клиентов по имени или телефону
  Future<Either<Failure, List<Client>>> searchClients(String query);

  /// Получить количество автомобилей клиента
  Future<Either<Failure, int>> getClientCarsCount(String clientId);
}