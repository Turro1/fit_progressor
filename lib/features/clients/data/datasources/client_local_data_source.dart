import '../models/client_model.dart';

abstract class ClientLocalDataSource {
  /// Получить всех клиентов из локального хранилища
  Future<List<ClientModel>> getAllClients();

  /// Получить клиента по ID
  Future<ClientModel> getClientById(String id);

  /// Сохранить клиента
  Future<ClientModel> saveClient(ClientModel client);

  /// Обновить клиента
  Future<ClientModel> updateClient(ClientModel client);

  /// Удалить клиента
  Future<void> deleteClient(String id);

  /// Поиск клиентов
  Future<List<ClientModel>> searchClients(String query);
}
