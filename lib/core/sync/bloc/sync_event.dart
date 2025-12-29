import 'package:equatable/equatable.dart';

import 'package:fit_progressor/core/sync/qr/qr_data_model.dart';
import 'package:fit_progressor/core/sync/sync_engine.dart';
import 'package:fit_progressor/core/sync/client/sync_client.dart';

/// Базовый класс событий синхронизации
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Инициализация синхронизации
class SyncInitialize extends SyncEvent {
  const SyncInitialize();
}

/// Запустить режим сервера
class SyncStartServer extends SyncEvent {
  final int port;

  const SyncStartServer({this.port = 8765});

  @override
  List<Object?> get props => [port];
}

/// Остановить сервер
class SyncStopServer extends SyncEvent {
  const SyncStopServer();
}

/// Подключиться к серверу
class SyncConnectToServer extends SyncEvent {
  final QrDataModel serverData;

  const SyncConnectToServer(this.serverData);

  @override
  List<Object?> get props => [serverData];
}

/// Отключиться от сервера
class SyncDisconnectFromServer extends SyncEvent {
  const SyncDisconnectFromServer();
}

/// Обновить имя устройства
class SyncUpdateDeviceName extends SyncEvent {
  final String name;

  const SyncUpdateDeviceName(this.name);

  @override
  List<Object?> get props => [name];
}

/// Событие подключения клиента (для сервера)
class SyncClientConnected extends SyncEvent {
  final String deviceId;

  const SyncClientConnected(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// Событие отключения клиента (для сервера)
class SyncClientDisconnected extends SyncEvent {
  final String deviceId;

  const SyncClientDisconnected(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// Обновить QR данные
class SyncRefreshQrData extends SyncEvent {
  const SyncRefreshQrData();
}

// ============================================
// Internal events (for engine callbacks)
// ============================================

/// Изменение режима синхронизации (внутреннее событие)
class SyncModeChangedInternal extends SyncEvent {
  final SyncMode mode;

  const SyncModeChangedInternal(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Изменение статуса синхронизации (внутреннее событие)
class SyncStatusChangedInternal extends SyncEvent {
  final SyncStatus status;

  const SyncStatusChangedInternal(this.status);

  @override
  List<Object?> get props => [status];
}

/// Ошибка синхронизации (внутреннее событие)
class SyncErrorInternal extends SyncEvent {
  final String error;

  const SyncErrorInternal(this.error);

  @override
  List<Object?> get props => [error];
}

/// Изменение состояния подключения (внутреннее событие)
class SyncConnectionStateChangedInternal extends SyncEvent {
  final SyncConnectionState connectionState;

  const SyncConnectionStateChangedInternal(this.connectionState);

  @override
  List<Object?> get props => [connectionState];
}

/// Успешное подключение к серверу (внутреннее событие)
class SyncConnectedToServerInternal extends SyncEvent {
  final ServerInfo serverInfo;

  const SyncConnectedToServerInternal(this.serverInfo);

  @override
  List<Object?> get props => [serverInfo];
}
