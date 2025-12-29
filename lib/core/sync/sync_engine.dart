import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:fit_progressor/core/sync/sync_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';
import 'package:fit_progressor/core/sync/server/sync_server.dart';
import 'package:fit_progressor/core/sync/client/sync_client.dart';
import 'package:fit_progressor/core/sync/tracking/change_tracker.dart';
import 'package:fit_progressor/core/sync/conflict/conflict_resolver.dart';
import 'package:fit_progressor/core/sync/qr/network_info_service.dart';
import 'package:fit_progressor/core/sync/qr/qr_data_model.dart';
import 'package:fit_progressor/core/sync/tracking/hive_models/sync_metadata_hive_model.dart';

/// Режим работы синхронизации
enum SyncMode {
  /// Не настроен
  none,

  /// Режим сервера (ПК)
  server,

  /// Режим клиента (телефон)
  client,
}

/// Статус синхронизации
enum SyncStatus {
  idle,
  syncing,
  error,
}

/// Callback для применения изменений к данным
typedef ApplyChangeCallback = Future<bool> Function(ChangePayload change);

/// Callback для получения всех данных для полной синхронизации
typedef GetAllDataCallback = Future<List<ChangePayload>> Function();

/// Главный движок синхронизации
class SyncEngine {
  final SyncServer _server = SyncServer();
  final SyncClient _client = SyncClient();
  final ChangeTracker _changeTracker;
  // TODO: использовать для разрешения конфликтов при синхронизации
  // ignore: unused_field
  final ConflictResolver _conflictResolver = ConflictResolver();
  final NetworkInfoService _networkInfo = NetworkInfoService();

  SyncMode _mode = SyncMode.none;
  SyncStatus _status = SyncStatus.idle;
  String _deviceId = '';
  String _deviceName = '';

  // Callbacks
  ApplyChangeCallback? onApplyChange;
  GetAllDataCallback? onGetAllData;
  void Function(SyncMode mode)? onModeChanged;
  void Function(SyncStatus status)? onStatusChanged;
  void Function(String deviceId)? onClientConnected;
  void Function(String deviceId)? onClientDisconnected;
  void Function(dynamic error)? onError;

  SyncEngine(this._changeTracker);

  /// Получить текущий режим
  SyncMode get mode => _mode;

  /// Получить текущий статус
  SyncStatus get status => _status;

  /// Получить ID устройства
  String get deviceId => _deviceId;

  /// Получить имя устройства
  String get deviceName => _deviceName;

  /// Проверить активна ли синхронизация
  bool get isActive => _mode != SyncMode.none;

  /// Получить сервер (для доступа к подключенным клиентам)
  SyncServer get server => _server;

  /// Получить клиент (для доступа к информации о сервере)
  SyncClient get client => _client;

  /// Получить ChangeTracker
  ChangeTracker get changeTracker => _changeTracker;

  /// Проверить доступна ли синхронизация на текущей платформе
  bool get isSupported => !kIsWeb;

  /// Инициализация движка
  Future<void> init() async {
    // Синхронизация не поддерживается на Web
    if (kIsWeb) {
      _deviceId = 'web-unsupported';
      _deviceName = 'Web Browser';
      return;
    }

    await _changeTracker.init();

    // Загружаем или создаём ID устройства
    await _loadOrCreateDeviceId();

    // Настраиваем callbacks сервера
    _server.onClientConnected = _handleServerClientConnected;
    _server.onClientDisconnected = _handleServerClientDisconnected;
    _server.onMessageReceived = _handleServerMessage;
    _server.onError = (deviceId, error) => onError?.call(error);

    // Настраиваем callbacks клиента
    _client.onConnected = _handleClientConnected;
    _client.onDisconnected = _handleClientDisconnected;
    _client.onMessageReceived = _handleClientMessage;
    _client.onError = (error) => onError?.call(error);
  }

  /// Загрузить или создать ID устройства
  Future<void> _loadOrCreateDeviceId() async {
    const boxName = 'sync_metadata';

    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<SyncMetadataHiveModel>(boxName);
    }

    final box = Hive.box<SyncMetadataHiveModel>(boxName);
    final metadata = box.get('device');

    if (metadata != null) {
      _deviceId = metadata.deviceId;
      _deviceName = metadata.deviceName;
    } else {
      _deviceId = const Uuid().v4();
      _deviceName = 'FitProgressor Device';

      final newMetadata = SyncMetadataHiveModel(
        deviceId: _deviceId,
        deviceName: _deviceName,
      );
      await box.put('device', newMetadata);
    }
  }

  /// Обновить имя устройства
  Future<void> setDeviceName(String name) async {
    _deviceName = name;

    const boxName = 'sync_metadata';
    final box = Hive.box<SyncMetadataHiveModel>(boxName);
    final metadata = box.get('device');

    if (metadata != null) {
      metadata.deviceName = name;
      await metadata.save();
    }
  }

  /// Запустить режим сервера
  Future<bool> startServer({int port = SyncConfig.defaultPort}) async {
    if (_mode == SyncMode.server && _server.isRunning) {
      return true;
    }

    // Останавливаем клиент если был запущен
    if (_mode == SyncMode.client) {
      await _client.disconnect();
    }

    final success = await _server.start(
      serverId: _deviceId,
      serverName: _deviceName,
      port: port,
    );

    if (success) {
      _setMode(SyncMode.server);
    }

    return success;
  }

  /// Остановить сервер
  Future<void> stopServer() async {
    await _server.stop();
    _setMode(SyncMode.none);
  }

  /// Получить данные для QR-кода
  Future<QrDataModel?> getServerQrData() async {
    if (_mode != SyncMode.server || !_server.isRunning) {
      return null;
    }

    final ip = await _networkInfo.getLocalIpAddress();
    if (ip == null) {
      return null;
    }

    return QrDataModel(
      serverIp: ip,
      port: _server.port,
      serverName: _deviceName,
      serverId: _deviceId,
    );
  }

  /// Подключиться к серверу
  Future<bool> connectToServer(QrDataModel serverData) async {
    if (_mode == SyncMode.client && _client.isConnected) {
      return true;
    }

    // Останавливаем сервер если был запущен
    if (_mode == SyncMode.server) {
      await _server.stop();
    }

    final success = await _client.connect(
      serverIp: serverData.serverIp,
      port: serverData.port,
      deviceId: _deviceId,
      deviceName: _deviceName,
    );

    if (success) {
      _setMode(SyncMode.client);
    }

    return success;
  }

  /// Отключиться от сервера
  Future<void> disconnectFromServer() async {
    await _client.disconnect();
    _setMode(SyncMode.none);
  }

  /// Отправить локальное изменение
  Future<void> broadcastLocalChange(ChangePayload change) async {
    if (_mode == SyncMode.server) {
      // Сервер рассылает изменение всем клиентам
      _server.broadcastChange(change);
    } else if (_mode == SyncMode.client && _client.isConnected) {
      // Клиент отправляет изменение серверу
      _client.sendChange(change);
    }
  }

  /// Обработка подключения клиента к серверу
  void _handleServerClientConnected(ConnectedClient client) {
    onClientConnected?.call(client.deviceId);

    // Отправляем все pending changes новому клиенту
    _sendPendingChangesToClient(client.deviceId);
  }

  /// Обработка отключения клиента от сервера
  void _handleServerClientDisconnected(String deviceId) {
    onClientDisconnected?.call(deviceId);
  }

  /// Обработка сообщения на сервере
  void _handleServerMessage(String deviceId, SyncMessage message) async {
    switch (message.type) {
      case SyncMessageType.syncRequest:
        await _handleSyncRequest(deviceId, message);
        break;

      case SyncMessageType.change:
        await _handleIncomingChange(message, fromDeviceId: deviceId);
        break;

      case SyncMessageType.changeBatch:
        await _handleChangeBatch(message, fromDeviceId: deviceId);
        break;

      case SyncMessageType.changeAck:
        _handleChangeAck(message);
        break;

      default:
        break;
    }
  }

  /// Обработка подключения к серверу (для клиента)
  void _handleClientConnected(ServerInfo server) {
    // Запрашиваем полную синхронизацию
    _client.requestFullSync();
  }

  /// Обработка отключения от сервера (для клиента)
  void _handleClientDisconnected(String? reason) {
    // Можно добавить логику повторного подключения
  }

  /// Обработка сообщения от сервера (для клиента)
  void _handleClientMessage(SyncMessage message) async {
    switch (message.type) {
      case SyncMessageType.syncResponse:
        await _handleSyncResponse(message);
        break;

      case SyncMessageType.change:
        await _handleIncomingChange(message);
        break;

      case SyncMessageType.changeBatch:
        await _handleChangeBatch(message);
        break;

      default:
        break;
    }
  }

  /// Обработка запроса полной синхронизации
  Future<void> _handleSyncRequest(String deviceId, SyncMessage message) async {
    _setStatus(SyncStatus.syncing);

    try {
      final since = message.payload?['since'] != null
          ? DateTime.parse(message.payload!['since'] as String)
          : null;

      // Получаем все данные через callback
      final changes = await onGetAllData?.call() ?? [];

      // Фильтруем по дате если указано
      final filteredChanges = since != null
          ? changes.where((c) => c.changedAt.isAfter(since)).toList()
          : changes;

      // Отправляем ответ
      final response = SyncMessage.syncResponse(
        deviceId: _deviceId,
        changes: filteredChanges,
        syncTimestamp: DateTime.now(),
      );

      _server.sendToClient(deviceId, response);
    } finally {
      _setStatus(SyncStatus.idle);
    }
  }

  /// Обработка ответа с данными синхронизации
  Future<void> _handleSyncResponse(SyncMessage message) async {
    _setStatus(SyncStatus.syncing);

    try {
      final changesJson = message.payload?['changes'] as List<dynamic>?;
      if (changesJson == null) return;

      for (final changeJson in changesJson) {
        final change = ChangePayload.fromJson(changeJson as Map<String, dynamic>);
        await _applyChange(change);
      }
    } finally {
      _setStatus(SyncStatus.idle);
    }
  }

  /// Обработка входящего изменения
  Future<void> _handleIncomingChange(SyncMessage message, {String? fromDeviceId}) async {
    final changeJson = message.payload;
    if (changeJson == null) return;

    final change = ChangePayload.fromJson(changeJson);
    final applied = await _applyChange(change);

    // Отправляем подтверждение
    final ack = SyncMessage.changeAck(
      deviceId: _deviceId,
      changeId: change.changeId,
      success: applied,
    );

    if (_mode == SyncMode.server && fromDeviceId != null) {
      _server.sendToClient(fromDeviceId, ack);

      // Рассылаем изменение другим клиентам
      if (applied) {
        _server.broadcastChange(change, exceptDeviceId: fromDeviceId);
      }
    } else if (_mode == SyncMode.client) {
      _client.send(ack);
    }
  }

  /// Обработка пакета изменений
  Future<void> _handleChangeBatch(SyncMessage message, {String? fromDeviceId}) async {
    final changesJson = message.payload?['changes'] as List<dynamic>?;
    if (changesJson == null) return;

    for (final changeJson in changesJson) {
      final change = ChangePayload.fromJson(changeJson as Map<String, dynamic>);
      await _applyChange(change);
    }
  }

  /// Обработка подтверждения изменения
  void _handleChangeAck(SyncMessage message) {
    final changeId = message.payload?['changeId'] as String?;
    final success = message.payload?['success'] as bool? ?? false;

    if (changeId != null && success) {
      _changeTracker.markSentToDevice(changeId, message.deviceId);
    }
  }

  /// Применить входящее изменение
  Future<bool> _applyChange(ChangePayload change) async {
    // Вызываем callback для применения изменения
    final applied = await onApplyChange?.call(change) ?? false;
    return applied;
  }

  /// Отправить pending changes новому клиенту
  Future<void> _sendPendingChangesToClient(String deviceId) async {
    final changes = _changeTracker.getChangesForDevice(deviceId);

    if (changes.isEmpty) return;

    // Отправляем пакетами
    for (var i = 0; i < changes.length; i += SyncConfig.batchSize) {
      final batch = changes.skip(i).take(SyncConfig.batchSize).toList();
      final payloads = batch.map((c) => _changeTracker.toChangePayload(c)).toList();

      final message = SyncMessage.changeBatch(
        deviceId: _deviceId,
        changes: payloads,
      );

      _server.sendToClient(deviceId, message);
    }
  }

  /// Установить режим
  void _setMode(SyncMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      onModeChanged?.call(_mode);
    }
  }

  /// Установить статус
  void _setStatus(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      onStatusChanged?.call(_status);
    }
  }

  /// Очистить ресурсы
  Future<void> dispose() async {
    await _server.stop();
    await _client.disconnect();
  }
}
