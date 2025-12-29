import 'package:equatable/equatable.dart';

import 'package:fit_progressor/core/sync/sync_engine.dart';
import 'package:fit_progressor/core/sync/qr/qr_data_model.dart';
import 'package:fit_progressor/core/sync/server/sync_server.dart';
import 'package:fit_progressor/core/sync/client/sync_client.dart';

/// Состояние синхронизации
class SyncState extends Equatable {
  /// Инициализирован ли движок синхронизации
  final bool isInitialized;

  /// Текущий режим работы
  final SyncMode mode;

  /// Текущий статус
  final SyncStatus status;

  /// ID устройства
  final String deviceId;

  /// Имя устройства
  final String deviceName;

  /// Данные QR-кода (для сервера)
  final QrDataModel? qrData;

  /// Список подключенных клиентов (для сервера)
  final List<ConnectedClient> connectedClients;

  /// Информация о сервере (для клиента)
  final ServerInfo? serverInfo;

  /// Состояние подключения клиента
  final SyncConnectionState connectionState;

  /// Сообщение об ошибке
  final String? errorMessage;

  const SyncState({
    this.isInitialized = false,
    this.mode = SyncMode.none,
    this.status = SyncStatus.idle,
    this.deviceId = '',
    this.deviceName = '',
    this.qrData,
    this.connectedClients = const [],
    this.serverInfo,
    this.connectionState = SyncConnectionState.disconnected,
    this.errorMessage,
  });

  /// Проверить запущен ли сервер
  bool get isServerRunning => mode == SyncMode.server;

  /// Проверить подключен ли к серверу
  bool get isConnectedToServer =>
      mode == SyncMode.client && connectionState == SyncConnectionState.connected;

  /// Проверить активна ли синхронизация
  bool get isActive => mode != SyncMode.none;

  /// Проверить идёт ли синхронизация
  bool get isSyncing => status == SyncStatus.syncing;

  /// Проверить есть ли ошибка
  bool get hasError => errorMessage != null;

  /// Копировать с новыми значениями
  SyncState copyWith({
    bool? isInitialized,
    SyncMode? mode,
    SyncStatus? status,
    String? deviceId,
    String? deviceName,
    QrDataModel? qrData,
    List<ConnectedClient>? connectedClients,
    ServerInfo? serverInfo,
    SyncConnectionState? connectionState,
    String? errorMessage,
    bool clearError = false,
    bool clearQrData = false,
    bool clearServerInfo = false,
  }) {
    return SyncState(
      isInitialized: isInitialized ?? this.isInitialized,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      qrData: clearQrData ? null : (qrData ?? this.qrData),
      connectedClients: connectedClients ?? this.connectedClients,
      serverInfo: clearServerInfo ? null : (serverInfo ?? this.serverInfo),
      connectionState: connectionState ?? this.connectionState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        mode,
        status,
        deviceId,
        deviceName,
        qrData,
        connectedClients,
        serverInfo,
        connectionState,
        errorMessage,
      ];
}
