import 'package:hive/hive.dart';
import 'package:fit_progressor/core/error/exceptions/cache_exception.dart';
import 'package:fit_progressor/core/error/exceptions/duplicate_exception.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';
import 'package:fit_progressor/features/clients/data/models/client_model.dart';
import 'package:fit_progressor/features/clients/data/models/client_hive_model.dart';
import 'client_local_data_source.dart';

/// Hive implementation of ClientLocalDataSource
class ClientHiveDataSource implements ClientLocalDataSource {
  final ChangeTracker? changeTracker;

  ClientHiveDataSource({this.changeTracker});

  Box<ClientHiveModel> get _box => HiveConfig.getBox<ClientHiveModel>(HiveBoxes.clients);

  @override
  Future<List<ClientModel>> getAllClients() async {
    try {
      final clients = _box.values.toList();
      // Sort by name
      clients.sort((a, b) => a.name.compareTo(b.name));
      return clients.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return ClientModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка загрузки клиентов: $e');
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      final hiveModel = _box.get(id);
      if (hiveModel == null) {
        throw CacheException(message: 'Клиент не найден');
      }
      return ClientModel.fromEntity(hiveModel.toEntity());
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка получения клиента: $e');
    }
  }

  @override
  Future<ClientModel> saveClient(ClientModel client) async {
    try {
      // Check for duplicate phone
      final existingWithPhone = _box.values.firstWhere(
        (c) => c.phone == client.phone && c.id != client.id,
        orElse: () => ClientHiveModel(
          id: '',
          name: '',
          phone: '',
          createdAt: DateTime.now(),
          carCount: 0,
        ),
      );
      if (existingWithPhone.id.isNotEmpty) {
        throw DuplicateException(
          message: 'Клиент с номером ${client.phone} уже существует',
        );
      }

      final hiveModel = ClientHiveModel.fromEntity(client);
      hiveModel.version = 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(client.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: client.id,
        entityType: EntityType.client,
        operation: ChangeOperation.create,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return client;
    } catch (e) {
      if (e is DuplicateException || e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка сохранения клиента: $e');
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final existing = _box.get(client.id);
      if (existing == null) {
        throw CacheException(message: 'Клиент не найден');
      }

      // Check for duplicate phone (excluding current client)
      final existingWithPhone = _box.values.firstWhere(
        (c) => c.phone == client.phone && c.id != client.id,
        orElse: () => ClientHiveModel(
          id: '',
          name: '',
          phone: '',
          createdAt: DateTime.now(),
          carCount: 0,
        ),
      );
      if (existingWithPhone.id.isNotEmpty) {
        throw DuplicateException(
          message: 'Клиент с номером ${client.phone} уже существует',
        );
      }

      final hiveModel = ClientHiveModel.fromEntity(client);
      hiveModel.version = existing.version + 1;
      hiveModel.updatedAt = DateTime.now();
      await _box.put(client.id, hiveModel);

      // Отслеживаем изменение для синхронизации
      await changeTracker?.track(
        entityId: client.id,
        entityType: EntityType.client,
        operation: ChangeOperation.update,
        version: hiveModel.version,
        data: hiveModel.toJson(),
      );

      return client;
    } catch (e) {
      if (e is DuplicateException || e is CacheException) rethrow;
      throw CacheException(message: 'Ошибка обновления клиента: $e');
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      final existing = _box.get(id);
      final version = (existing?.version ?? 0) + 1;

      await _box.delete(id);

      // Отслеживаем удаление для синхронизации
      await changeTracker?.track(
        entityId: id,
        entityType: EntityType.client,
        operation: ChangeOperation.delete,
        version: version,
        data: null,
      );
    } catch (e) {
      throw CacheException(message: 'Ошибка удаления клиента: $e');
    }
  }

  @override
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final clients = _box.values.where((client) {
        return client.name.toLowerCase().contains(queryLower) ||
            client.phone.contains(query);
      }).toList();

      clients.sort((a, b) => a.name.compareTo(b.name));
      return clients.map((hiveModel) {
        final entity = hiveModel.toEntity();
        return ClientModel.fromEntity(entity);
      }).toList();
    } catch (e) {
      throw CacheException(message: 'Ошибка поиска клиентов: $e');
    }
  }
}
