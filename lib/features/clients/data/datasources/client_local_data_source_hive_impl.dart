import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/features/clients/data/datasources/client_local_data_source.dart';
import 'package:fit_progressor/features/clients/data/models/client_model.dart';
import 'package:hive/hive.dart';

/// Реализация через Hive (более производительно)
class ClientLocalDataSourceHiveImpl implements ClientLocalDataSource {
  static const String _boxName = 'clients';
  final HiveInterface hive;

  ClientLocalDataSourceHiveImpl({required this.hive});

  Box<ClientModel> get _box => hive.box<ClientModel>(_boxName);

  @override
  Future<List<ClientModel>> getAllClients() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get clients: $e');
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      final client = _box.get(id);
      if (client == null) {
        throw CacheException(message: 'Client not found: $id');
      }
      return client;
    } catch (e) {
      throw CacheException(message: 'Failed to get client: $e');
    }
  }

  @override
  Future<ClientModel> saveClient(ClientModel client) async {
    try {
      await _box.put(client.id, client);
      return client;
    } catch (e) {
      throw CacheException(message: 'Failed to save client: $e');
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      if (!_box.containsKey(client.id)) {
        throw CacheException(message: 'Client not found: ${client.id}');
      }
      await _box.put(client.id, client);
      return client;
    } catch (e) {
      throw CacheException(message: 'Failed to update client: $e');
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      if (!_box.containsKey(id)) {
        throw CacheException(message: 'Client not found: $id');
      }
      await _box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete client: $e');
    }
  }

  @override
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final allClients = _box.values.toList();
      final lowercaseQuery = query.toLowerCase();

      return allClients.where((client) {
        final nameMatch = client.name.toLowerCase().contains(lowercaseQuery);
        final phoneMatch =
            client.phone?.toLowerCase().contains(lowercaseQuery) ?? false;
        return nameMatch || phoneMatch;
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to search clients: $e');
    }
  }
}