import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fit_progressor/core/sync/sync_engine.dart';
import 'package:fit_progressor/core/sync/bloc/sync_event.dart';
import 'package:fit_progressor/core/sync/bloc/sync_state.dart';
import 'package:fit_progressor/core/sync/client/sync_client.dart';

/// BLoC для управления синхронизацией
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncEngine _syncEngine;

  SyncBloc(this._syncEngine) : super(const SyncState()) {
    on<SyncInitialize>(_onInitialize);
    on<SyncStartServer>(_onStartServer);
    on<SyncStopServer>(_onStopServer);
    on<SyncConnectToServer>(_onConnectToServer);
    on<SyncDisconnectFromServer>(_onDisconnectFromServer);
    on<SyncUpdateDeviceName>(_onUpdateDeviceName);
    on<SyncClientConnected>(_onClientConnected);
    on<SyncClientDisconnected>(_onClientDisconnected);
    on<SyncRefreshQrData>(_onRefreshQrData);
    // Internal events
    on<SyncModeChangedInternal>(_onModeChangedInternal);
    on<SyncStatusChangedInternal>(_onStatusChangedInternal);
    on<SyncErrorInternal>(_onErrorInternal);
    on<SyncConnectionStateChangedInternal>(_onSyncConnectionStateChangedInternal);
    on<SyncConnectedToServerInternal>(_onConnectedToServerInternal);

    // Подписываемся на события движка
    _setupEngineCallbacks();
  }

  /// Настроить callbacks движка
  void _setupEngineCallbacks() {
    // На Web платформе синхронизация не поддерживается
    if (kIsWeb) return;

    _syncEngine.onModeChanged = (mode) {
      if (!isClosed) {
        add(SyncModeChangedInternal(mode));
      }
    };

    _syncEngine.onStatusChanged = (status) {
      if (!isClosed) {
        add(SyncStatusChangedInternal(status));
      }
    };

    _syncEngine.onClientConnected = (deviceId) {
      if (!isClosed) {
        add(SyncClientConnected(deviceId));
      }
    };

    _syncEngine.onClientDisconnected = (deviceId) {
      if (!isClosed) {
        add(SyncClientDisconnected(deviceId));
      }
    };

    _syncEngine.onError = (error) {
      if (!isClosed) {
        add(SyncErrorInternal(error.toString()));
      }
    };

    // Подписываемся на состояние клиента
    _syncEngine.client.onSyncConnectionStateChanged = (connectionState) {
      if (!isClosed) {
        add(SyncConnectionStateChangedInternal(connectionState));
      }
    };

    _syncEngine.client.onConnected = (serverInfo) {
      if (!isClosed) {
        add(SyncConnectedToServerInternal(serverInfo));
      }
    };
  }

  // Internal event handlers

  void _onModeChangedInternal(
    SyncModeChangedInternal event,
    Emitter<SyncState> emit,
  ) {
    emit(state.copyWith(mode: event.mode));
  }

  void _onStatusChangedInternal(
    SyncStatusChangedInternal event,
    Emitter<SyncState> emit,
  ) {
    emit(state.copyWith(status: event.status));
  }

  void _onErrorInternal(
    SyncErrorInternal event,
    Emitter<SyncState> emit,
  ) {
    emit(state.copyWith(errorMessage: event.error));
  }

  void _onSyncConnectionStateChangedInternal(
    SyncConnectionStateChangedInternal event,
    Emitter<SyncState> emit,
  ) {
    emit(state.copyWith(connectionState: event.connectionState));
  }

  void _onConnectedToServerInternal(
    SyncConnectedToServerInternal event,
    Emitter<SyncState> emit,
  ) {
    emit(state.copyWith(
      serverInfo: event.serverInfo,
      connectionState: SyncConnectionState.connected,
    ));
  }

  /// Обработка инициализации
  Future<void> _onInitialize(
    SyncInitialize event,
    Emitter<SyncState> emit,
  ) async {
    // На Web платформе синхронизация не поддерживается
    if (kIsWeb) {
      emit(state.copyWith(
        isInitialized: true,
        deviceId: 'web-unsupported',
        deviceName: 'Web Browser',
        mode: SyncMode.none,
        clearError: true,
      ));
      return;
    }

    try {
      await _syncEngine.init();

      emit(state.copyWith(
        isInitialized: true,
        deviceId: _syncEngine.deviceId,
        deviceName: _syncEngine.deviceName,
        mode: _syncEngine.mode,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Обработка запуска сервера
  Future<void> _onStartServer(
    SyncStartServer event,
    Emitter<SyncState> emit,
  ) async {
    if (kIsWeb) {
      emit(state.copyWith(errorMessage: 'Синхронизация недоступна в веб-версии'));
      return;
    }

    emit(state.copyWith(clearError: true));

    try {
      final success = await _syncEngine.startServer(port: event.port);

      if (success) {
        final qrData = await _syncEngine.getServerQrData();

        emit(state.copyWith(
          mode: SyncMode.server,
          qrData: qrData,
          connectedClients: [],
        ));
      } else {
        emit(state.copyWith(
          errorMessage: 'Не удалось запустить сервер',
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Обработка остановки сервера
  Future<void> _onStopServer(
    SyncStopServer event,
    Emitter<SyncState> emit,
  ) async {
    if (kIsWeb) return;

    await _syncEngine.stopServer();

    emit(state.copyWith(
      mode: SyncMode.none,
      clearQrData: true,
      connectedClients: [],
    ));
  }

  /// Обработка подключения к серверу
  Future<void> _onConnectToServer(
    SyncConnectToServer event,
    Emitter<SyncState> emit,
  ) async {
    if (kIsWeb) {
      emit(state.copyWith(errorMessage: 'Синхронизация недоступна в веб-версии'));
      return;
    }

    emit(state.copyWith(
      connectionState: SyncConnectionState.connecting,
      clearError: true,
    ));

    try {
      final success = await _syncEngine.connectToServer(event.serverData);

      if (!success) {
        emit(state.copyWith(
          connectionState: SyncConnectionState.disconnected,
          errorMessage: 'Не удалось подключиться к серверу',
        ));
      }
      // Состояние обновится через callback onConnected
    } catch (e) {
      emit(state.copyWith(
        connectionState: SyncConnectionState.disconnected,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Обработка отключения от сервера
  Future<void> _onDisconnectFromServer(
    SyncDisconnectFromServer event,
    Emitter<SyncState> emit,
  ) async {
    if (kIsWeb) return;

    await _syncEngine.disconnectFromServer();

    emit(state.copyWith(
      mode: SyncMode.none,
      connectionState: SyncConnectionState.disconnected,
      clearServerInfo: true,
    ));
  }

  /// Обработка обновления имени устройства
  Future<void> _onUpdateDeviceName(
    SyncUpdateDeviceName event,
    Emitter<SyncState> emit,
  ) async {
    if (kIsWeb) return;

    await _syncEngine.setDeviceName(event.name);
    emit(state.copyWith(deviceName: event.name));
  }

  /// Обработка подключения клиента
  void _onClientConnected(
    SyncClientConnected event,
    Emitter<SyncState> emit,
  ) {
    if (kIsWeb) return;

    emit(state.copyWith(
      connectedClients: _syncEngine.server.connectedClients,
    ));
  }

  /// Обработка отключения клиента
  void _onClientDisconnected(
    SyncClientDisconnected event,
    Emitter<SyncState> emit,
  ) {
    if (kIsWeb) return;

    emit(state.copyWith(
      connectedClients: _syncEngine.server.connectedClients,
    ));
  }

  /// Обработка обновления QR данных
  Future<void> _onRefreshQrData(
    SyncRefreshQrData event,
    Emitter<SyncState> emit,
  ) async {
    if (kIsWeb) return;

    if (state.mode == SyncMode.server) {
      final qrData = await _syncEngine.getServerQrData();
      emit(state.copyWith(qrData: qrData));
    }
  }

  @override
  Future<void> close() {
    if (!kIsWeb) {
      _syncEngine.dispose();
    }
    return super.close();
  }
}
