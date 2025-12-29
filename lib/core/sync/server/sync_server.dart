import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fit_progressor/core/sync/sync_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';

/// Информация о подключенном клиенте
class ConnectedClient {
  final String deviceId;
  final String deviceName;
  final WebSocket socket;
  final String ipAddress;
  final DateTime connectedAt;
  DateTime lastSeenAt;

  ConnectedClient({
    required this.deviceId,
    required this.deviceName,
    required this.socket,
    required this.ipAddress,
    DateTime? connectedAt,
  })  : connectedAt = connectedAt ?? DateTime.now(),
        lastSeenAt = DateTime.now();

  void updateLastSeen() {
    lastSeenAt = DateTime.now();
  }
}

/// Callback-типы для событий сервера
typedef OnClientConnected = void Function(ConnectedClient client);
typedef OnClientDisconnected = void Function(String deviceId);
typedef OnMessageReceived = void Function(String deviceId, SyncMessage message);
typedef OnError = void Function(String deviceId, dynamic error);

/// WebSocket сервер для синхронизации
class SyncServer {
  HttpServer? _server;
  final Map<String, ConnectedClient> _clients = {};
  Timer? _pingTimer;

  bool _isRunning = false;
  int _port = SyncConfig.defaultPort;
  String _serverId = '';
  String _serverName = 'FitProgressor Server';

  // Callbacks
  OnClientConnected? onClientConnected;
  OnClientDisconnected? onClientDisconnected;
  OnMessageReceived? onMessageReceived;
  OnError? onError;

  /// Проверить запущен ли сервер
  bool get isRunning => _isRunning;

  /// Получить порт сервера
  int get port => _port;

  /// Получить ID сервера
  String get serverId => _serverId;

  /// Получить имя сервера
  String get serverName => _serverName;

  /// Получить список подключенных клиентов
  List<ConnectedClient> get connectedClients => _clients.values.toList();

  /// Получить количество подключенных клиентов
  int get clientCount => _clients.length;

  /// Запустить сервер
  Future<bool> start({
    required String serverId,
    String serverName = 'FitProgressor Server',
    int port = SyncConfig.defaultPort,
  }) async {
    if (_isRunning) {
      return true;
    }

    _serverId = serverId;
    _serverName = serverName;
    _port = port;

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        _port,
      );

      _isRunning = true;

      // Слушаем входящие соединения
      _server!.listen(
        _handleRequest,
        onError: (error) {
          onError?.call('server', error);
        },
      );

      // Запускаем ping timer
      _startPingTimer();

      return true;
    } catch (e) {
      _isRunning = false;
      onError?.call('server', e);
      return false;
    }
  }

  /// Остановить сервер
  Future<void> stop() async {
    _pingTimer?.cancel();
    _pingTimer = null;

    // Отключаем всех клиентов
    for (final client in _clients.values) {
      try {
        final disconnectMsg = SyncMessage(
          type: SyncMessageType.disconnect,
          deviceId: _serverId,
          payload: {'reason': 'Server shutting down'},
        );
        client.socket.add(disconnectMsg.toJsonString());
        await client.socket.close();
      } catch (_) {
        // Игнорируем ошибки при закрытии
      }
    }
    _clients.clear();

    await _server?.close(force: true);
    _server = null;
    _isRunning = false;
  }

  /// Обработка HTTP запроса (upgrade до WebSocket)
  void _handleRequest(HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      try {
        final socket = await WebSocketTransformer.upgrade(request);
        final ipAddress = request.connectionInfo?.remoteAddress.address ?? 'unknown';
        _handleWebSocket(socket, ipAddress);
      } catch (e) {
        onError?.call('server', e);
      }
    } else {
      // Возвращаем информацию о сервере для обычных HTTP запросов
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'name': _serverName,
          'id': _serverId,
          'protocol': SyncConfig.protocolVersion,
          'clients': _clients.length,
        }))
        ..close();
    }
  }

  /// Обработка WebSocket соединения
  void _handleWebSocket(WebSocket socket, String ipAddress) {
    String? clientDeviceId;

    socket.listen(
      (data) {
        try {
          final message = SyncMessage.fromJsonString(data as String);

          // Обработка handshake
          if (message.type == SyncMessageType.handshake) {
            clientDeviceId = message.deviceId;
            final deviceName = message.payload?['deviceName'] as String? ?? 'Unknown Device';

            // Создаём клиента
            final client = ConnectedClient(
              deviceId: message.deviceId,
              deviceName: deviceName,
              socket: socket,
              ipAddress: ipAddress,
            );

            _clients[message.deviceId] = client;

            // Отправляем подтверждение
            final ack = SyncMessage.handshakeAck(
              deviceId: _serverId,
              serverName: _serverName,
              accepted: true,
            );
            socket.add(ack.toJsonString());

            onClientConnected?.call(client);
          }
          // Обработка ping
          else if (message.type == SyncMessageType.ping) {
            _clients[message.deviceId]?.updateLastSeen();
            final pong = SyncMessage.pong(deviceId: _serverId);
            socket.add(pong.toJsonString());
          }
          // Обработка pong
          else if (message.type == SyncMessageType.pong) {
            _clients[message.deviceId]?.updateLastSeen();
          }
          // Все остальные сообщения
          else {
            _clients[message.deviceId]?.updateLastSeen();
            onMessageReceived?.call(message.deviceId, message);
          }
        } catch (e) {
          onError?.call(clientDeviceId ?? 'unknown', e);
        }
      },
      onDone: () {
        if (clientDeviceId != null) {
          _clients.remove(clientDeviceId);
          onClientDisconnected?.call(clientDeviceId!);
        }
      },
      onError: (error) {
        onError?.call(clientDeviceId ?? 'unknown', error);
        if (clientDeviceId != null) {
          _clients.remove(clientDeviceId);
          onClientDisconnected?.call(clientDeviceId!);
        }
      },
    );
  }

  /// Отправить сообщение конкретному клиенту
  void sendToClient(String deviceId, SyncMessage message) {
    final client = _clients[deviceId];
    if (client != null) {
      try {
        client.socket.add(message.toJsonString());
      } catch (e) {
        onError?.call(deviceId, e);
      }
    }
  }

  /// Отправить сообщение всем клиентам
  void broadcast(SyncMessage message, {String? exceptDeviceId}) {
    for (final client in _clients.values) {
      if (client.deviceId != exceptDeviceId) {
        try {
          client.socket.add(message.toJsonString());
        } catch (e) {
          onError?.call(client.deviceId, e);
        }
      }
    }
  }

  /// Отправить изменение всем клиентам
  void broadcastChange(ChangePayload change, {String? exceptDeviceId}) {
    final message = SyncMessage.change(
      deviceId: _serverId,
      change: change,
    );
    broadcast(message, exceptDeviceId: exceptDeviceId);
  }

  /// Запустить ping timer для проверки соединений
  void _startPingTimer() {
    _pingTimer = Timer.periodic(
      Duration(seconds: SyncConfig.pingIntervalSeconds),
      (_) => _pingClients(),
    );
  }

  /// Отправить ping всем клиентам
  void _pingClients() {
    final ping = SyncMessage.ping(deviceId: _serverId);
    final now = DateTime.now();
    final timeout = Duration(seconds: SyncConfig.pingIntervalSeconds * 2);

    // Проверяем таймауты и отправляем ping
    final toRemove = <String>[];
    for (final client in _clients.values) {
      if (now.difference(client.lastSeenAt) > timeout) {
        toRemove.add(client.deviceId);
      } else {
        try {
          client.socket.add(ping.toJsonString());
        } catch (_) {
          toRemove.add(client.deviceId);
        }
      }
    }

    // Удаляем отключенных клиентов
    for (final deviceId in toRemove) {
      _clients.remove(deviceId);
      onClientDisconnected?.call(deviceId);
    }
  }

  /// Отключить конкретного клиента
  Future<void> disconnectClient(String deviceId) async {
    final client = _clients.remove(deviceId);
    if (client != null) {
      try {
        final disconnectMsg = SyncMessage(
          type: SyncMessageType.disconnect,
          deviceId: _serverId,
          payload: {'reason': 'Disconnected by server'},
        );
        client.socket.add(disconnectMsg.toJsonString());
        await client.socket.close();
      } catch (_) {
        // Игнорируем ошибки при закрытии
      }
      onClientDisconnected?.call(deviceId);
    }
  }
}
