import 'dart:async';
import 'dart:io';

import 'package:fit_progressor/core/sync/sync_config.dart';
import 'package:fit_progressor/core/sync/sync_message.dart';

/// Состояние подключения клиента
enum SyncConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Информация о сервере
class ServerInfo {
  final String serverId;
  final String serverName;
  final String serverIp;
  final int port;

  const ServerInfo({
    required this.serverId,
    required this.serverName,
    required this.serverIp,
    required this.port,
  });

  String get webSocketUrl => 'ws://$serverIp:$port';
}

/// Callback-типы для событий клиента
typedef OnConnected = void Function(ServerInfo server);
typedef OnDisconnected = void Function(String? reason);
typedef OnMessageReceived = void Function(SyncMessage message);
typedef OnSyncConnectionStateChanged = void Function(SyncConnectionState state);
typedef OnError = void Function(dynamic error);

/// WebSocket клиент для синхронизации
class SyncClient {
  WebSocket? _socket;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  SyncConnectionState _state = SyncConnectionState.disconnected;
  int _reconnectAttempts = 0;

  String _deviceId = '';
  String _deviceName = '';
  ServerInfo? _serverInfo;

  // Callbacks
  OnConnected? onConnected;
  OnDisconnected? onDisconnected;
  OnMessageReceived? onMessageReceived;
  OnSyncConnectionStateChanged? onSyncConnectionStateChanged;
  OnError? onError;

  /// Получить текущее состояние подключения
  SyncConnectionState get state => _state;

  /// Проверить подключен ли клиент
  bool get isConnected => _state == SyncConnectionState.connected;

  /// Получить информацию о сервере
  ServerInfo? get serverInfo => _serverInfo;

  /// Получить ID устройства
  String get deviceId => _deviceId;

  /// Подключиться к серверу
  Future<bool> connect({
    required String serverIp,
    required int port,
    required String deviceId,
    required String deviceName,
  }) async {
    if (_state == SyncConnectionState.connected ||
        _state == SyncConnectionState.connecting) {
      return _state == SyncConnectionState.connected;
    }

    _deviceId = deviceId;
    _deviceName = deviceName;
    _reconnectAttempts = 0;

    return _doConnect(serverIp, port);
  }

  /// Выполнить подключение
  Future<bool> _doConnect(String serverIp, int port) async {
    _setState(SyncConnectionState.connecting);

    try {
      final url = 'ws://$serverIp:$port';
      _socket = await WebSocket.connect(
        url,
        headers: {'User-Agent': 'FitProgressor/${SyncConfig.protocolVersion}'},
      ).timeout(
        Duration(seconds: SyncConfig.connectionTimeoutSeconds),
      );

      // Отправляем handshake
      final handshake = SyncMessage.handshake(
        deviceId: _deviceId,
        deviceName: _deviceName,
        appVersion: SyncConfig.protocolVersion,
      );
      _socket!.add(handshake.toJsonString());

      // Слушаем сообщения
      _socket!.listen(
        _handleMessage,
        onDone: _handleDone,
        onError: _handleError,
      );

      return true;
    } catch (e) {
      _setState(SyncConnectionState.disconnected);
      onError?.call(e);

      // Пробуем переподключиться
      if (_reconnectAttempts < SyncConfig.maxReconnectAttempts) {
        _scheduleReconnect(serverIp, port);
      }

      return false;
    }
  }

  /// Обработка входящего сообщения
  void _handleMessage(dynamic data) {
    try {
      final message = SyncMessage.fromJsonString(data as String);

      // Обработка handshake ack
      if (message.type == SyncMessageType.handshakeAck) {
        final accepted = message.payload?['accepted'] as bool? ?? false;

        if (accepted) {
          final serverName = message.payload?['serverName'] as String? ?? 'Unknown Server';

          _serverInfo = ServerInfo(
            serverId: message.deviceId,
            serverName: serverName,
            serverIp: _socket!.toString(), // Извлечь IP из socket сложно
            port: SyncConfig.defaultPort,
          );

          _setState(SyncConnectionState.connected);
          _reconnectAttempts = 0;
          _startPingTimer();
          onConnected?.call(_serverInfo!);
        } else {
          final reason = message.payload?['rejectReason'] as String?;
          disconnect(reason: reason);
        }
      }
      // Обработка ping
      else if (message.type == SyncMessageType.ping) {
        final pong = SyncMessage.pong(deviceId: _deviceId);
        _socket?.add(pong.toJsonString());
      }
      // Обработка pong - просто игнорируем, нужен для keep-alive
      else if (message.type == SyncMessageType.pong) {
        // Keep-alive успешен
      }
      // Обработка disconnect от сервера
      else if (message.type == SyncMessageType.disconnect) {
        final reason = message.payload?['reason'] as String?;
        _handleDisconnect(reason);
      }
      // Все остальные сообщения передаём наверх
      else {
        onMessageReceived?.call(message);
      }
    } catch (e) {
      onError?.call(e);
    }
  }

  /// Обработка закрытия соединения
  void _handleDone() {
    _handleDisconnect('Connection closed');
  }

  /// Обработка ошибки соединения
  void _handleError(dynamic error) {
    onError?.call(error);
    _handleDisconnect('Connection error');
  }

  /// Обработка отключения
  void _handleDisconnect(String? reason) {
    _stopPingTimer();
    _socket = null;

    if (_state == SyncConnectionState.connected && _serverInfo != null) {
      // Пробуем переподключиться
      if (_reconnectAttempts < SyncConfig.maxReconnectAttempts) {
        _scheduleReconnect(_serverInfo!.serverIp, _serverInfo!.port);
      } else {
        _setState(SyncConnectionState.disconnected);
        onDisconnected?.call(reason);
        _serverInfo = null;
      }
    } else {
      _setState(SyncConnectionState.disconnected);
      onDisconnected?.call(reason);
      _serverInfo = null;
    }
  }

  /// Отключиться от сервера
  Future<void> disconnect({String? reason}) async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopPingTimer();

    if (_socket != null) {
      try {
        final disconnectMsg = SyncMessage(
          type: SyncMessageType.disconnect,
          deviceId: _deviceId,
          payload: {'reason': reason ?? 'Client disconnected'},
        );
        _socket!.add(disconnectMsg.toJsonString());
        await _socket!.close();
      } catch (_) {
        // Игнорируем ошибки при закрытии
      }
    }

    _socket = null;
    _serverInfo = null;
    _setState(SyncConnectionState.disconnected);
    onDisconnected?.call(reason);
  }

  /// Отправить сообщение серверу
  void send(SyncMessage message) {
    if (_state != SyncConnectionState.connected || _socket == null) {
      throw StateError('Not connected to server');
    }

    try {
      _socket!.add(message.toJsonString());
    } catch (e) {
      onError?.call(e);
    }
  }

  /// Отправить изменение серверу
  void sendChange(ChangePayload change) {
    final message = SyncMessage.change(
      deviceId: _deviceId,
      change: change,
    );
    send(message);
  }

  /// Запросить полную синхронизацию
  void requestFullSync({DateTime? since}) {
    final message = SyncMessage.syncRequest(
      deviceId: _deviceId,
      since: since,
    );
    send(message);
  }

  /// Установить состояние
  void _setState(SyncConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      onSyncConnectionStateChanged?.call(_state);
    }
  }

  /// Запустить ping timer
  void _startPingTimer() {
    _pingTimer = Timer.periodic(
      Duration(seconds: SyncConfig.pingIntervalSeconds),
      (_) => _sendPing(),
    );
  }

  /// Остановить ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Отправить ping
  void _sendPing() {
    if (_state == SyncConnectionState.connected && _socket != null) {
      try {
        final ping = SyncMessage.ping(deviceId: _deviceId);
        _socket!.add(ping.toJsonString());
      } catch (e) {
        onError?.call(e);
      }
    }
  }

  /// Запланировать переподключение
  void _scheduleReconnect(String serverIp, int port) {
    _reconnectAttempts++;
    _setState(SyncConnectionState.reconnecting);

    _reconnectTimer = Timer(
      Duration(seconds: SyncConfig.reconnectDelaySeconds),
      () => _doConnect(serverIp, port),
    );
  }
}
