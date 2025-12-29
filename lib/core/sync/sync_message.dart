import 'dart:convert';

import 'package:uuid/uuid.dart';

/// Типы сообщений протокола синхронизации
enum SyncMessageType {
  // Управление соединением
  handshake,
  handshakeAck,
  disconnect,
  ping,
  pong,

  // Синхронизация данных
  syncRequest,
  syncResponse,

  // Инкрементальные изменения
  change,
  changeBatch,
  changeAck,

  // Конфликты
  conflictDetected,
  conflictResolved,
}

/// Тип операции изменения
enum ChangeOperation {
  create,
  update,
  delete,
}

/// Тип сущности
enum EntityType {
  client,
  car,
  repair,
  material,
}

/// Сообщение протокола синхронизации
class SyncMessage {
  final String messageId;
  final SyncMessageType type;
  final String deviceId;
  final DateTime timestamp;
  final Map<String, dynamic>? payload;

  SyncMessage({
    String? messageId,
    required this.type,
    required this.deviceId,
    DateTime? timestamp,
    this.payload,
  })  : messageId = messageId ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'type': type.name,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      if (payload != null) 'payload': payload,
    };
  }

  factory SyncMessage.fromJson(Map<String, dynamic> json) {
    return SyncMessage(
      messageId: json['messageId'] as String,
      type: SyncMessageType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory SyncMessage.fromJsonString(String jsonString) {
    return SyncMessage.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Фабричные методы для создания типовых сообщений

  /// Создать сообщение handshake
  factory SyncMessage.handshake({
    required String deviceId,
    required String deviceName,
    required String appVersion,
    DateTime? lastSyncTimestamp,
  }) {
    return SyncMessage(
      type: SyncMessageType.handshake,
      deviceId: deviceId,
      payload: {
        'deviceName': deviceName,
        'appVersion': appVersion,
        if (lastSyncTimestamp != null)
          'lastSyncTimestamp': lastSyncTimestamp.toIso8601String(),
      },
    );
  }

  /// Создать подтверждение handshake
  factory SyncMessage.handshakeAck({
    required String deviceId,
    required String serverName,
    required bool accepted,
    String? rejectReason,
  }) {
    return SyncMessage(
      type: SyncMessageType.handshakeAck,
      deviceId: deviceId,
      payload: {
        'serverName': serverName,
        'accepted': accepted,
        if (rejectReason != null) 'rejectReason': rejectReason,
      },
    );
  }

  /// Создать сообщение ping
  factory SyncMessage.ping({required String deviceId}) {
    return SyncMessage(
      type: SyncMessageType.ping,
      deviceId: deviceId,
    );
  }

  /// Создать сообщение pong
  factory SyncMessage.pong({required String deviceId}) {
    return SyncMessage(
      type: SyncMessageType.pong,
      deviceId: deviceId,
    );
  }

  /// Создать запрос полной синхронизации
  factory SyncMessage.syncRequest({
    required String deviceId,
    DateTime? since,
  }) {
    return SyncMessage(
      type: SyncMessageType.syncRequest,
      deviceId: deviceId,
      payload: {
        if (since != null) 'since': since.toIso8601String(),
      },
    );
  }

  /// Создать ответ с данными синхронизации
  factory SyncMessage.syncResponse({
    required String deviceId,
    required List<ChangePayload> changes,
    required DateTime syncTimestamp,
  }) {
    return SyncMessage(
      type: SyncMessageType.syncResponse,
      deviceId: deviceId,
      payload: {
        'changes': changes.map((c) => c.toJson()).toList(),
        'syncTimestamp': syncTimestamp.toIso8601String(),
      },
    );
  }

  /// Создать сообщение об изменении
  factory SyncMessage.change({
    required String deviceId,
    required ChangePayload change,
  }) {
    return SyncMessage(
      type: SyncMessageType.change,
      deviceId: deviceId,
      payload: change.toJson(),
    );
  }

  /// Создать пакет изменений
  factory SyncMessage.changeBatch({
    required String deviceId,
    required List<ChangePayload> changes,
  }) {
    return SyncMessage(
      type: SyncMessageType.changeBatch,
      deviceId: deviceId,
      payload: {
        'changes': changes.map((c) => c.toJson()).toList(),
      },
    );
  }

  /// Создать подтверждение получения изменения
  factory SyncMessage.changeAck({
    required String deviceId,
    required String changeId,
    required bool success,
    String? errorMessage,
  }) {
    return SyncMessage(
      type: SyncMessageType.changeAck,
      deviceId: deviceId,
      payload: {
        'changeId': changeId,
        'success': success,
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
    );
  }
}

/// Данные изменения сущности
class ChangePayload {
  final String changeId;
  final String entityId;
  final EntityType entityType;
  final ChangeOperation operation;
  final DateTime changedAt;
  final int version;
  final Map<String, dynamic>? data;

  ChangePayload({
    String? changeId,
    required this.entityId,
    required this.entityType,
    required this.operation,
    required this.changedAt,
    required this.version,
    this.data,
  }) : changeId = changeId ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'changeId': changeId,
      'entityId': entityId,
      'entityType': entityType.name,
      'operation': operation.name,
      'changedAt': changedAt.toIso8601String(),
      'version': version,
      if (data != null) 'data': data,
    };
  }

  factory ChangePayload.fromJson(Map<String, dynamic> json) {
    return ChangePayload(
      changeId: json['changeId'] as String,
      entityId: json['entityId'] as String,
      entityType: EntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
      ),
      operation: ChangeOperation.values.firstWhere(
        (e) => e.name == json['operation'],
      ),
      changedAt: DateTime.parse(json['changedAt'] as String),
      version: json['version'] as int,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
