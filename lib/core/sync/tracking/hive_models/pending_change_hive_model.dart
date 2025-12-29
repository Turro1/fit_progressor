import 'dart:convert';

import 'package:hive/hive.dart';

part 'pending_change_hive_model.g.dart';

/// Ожидающее отправки изменение
@HiveType(typeId: 8)
class PendingChangeHiveModel extends HiveObject {
  @HiveField(0)
  String changeId;

  @HiveField(1)
  String entityId;

  @HiveField(2)
  String entityType;

  @HiveField(3)
  String operation;

  @HiveField(4)
  DateTime changedAt;

  @HiveField(5)
  int version;

  @HiveField(6)
  String? dataJson;

  @HiveField(7)
  bool isSent;

  @HiveField(8)
  List<String> sentToDevices;

  @HiveField(9)
  DateTime createdAt;

  PendingChangeHiveModel({
    required this.changeId,
    required this.entityId,
    required this.entityType,
    required this.operation,
    required this.changedAt,
    required this.version,
    this.dataJson,
    this.isSent = false,
    List<String>? sentToDevices,
    DateTime? createdAt,
  })  : sentToDevices = sentToDevices ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic>? get data =>
      dataJson != null ? jsonDecode(dataJson!) as Map<String, dynamic> : null;

  set data(Map<String, dynamic>? value) {
    dataJson = value != null ? jsonEncode(value) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'changeId': changeId,
      'entityId': entityId,
      'entityType': entityType,
      'operation': operation,
      'changedAt': changedAt.toIso8601String(),
      'version': version,
      'dataJson': dataJson,
      'isSent': isSent,
      'sentToDevices': sentToDevices,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PendingChangeHiveModel.fromJson(Map<String, dynamic> json) {
    return PendingChangeHiveModel(
      changeId: json['changeId'] as String,
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      operation: json['operation'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
      version: json['version'] as int,
      dataJson: json['dataJson'] as String?,
      isSent: json['isSent'] as bool? ?? false,
      sentToDevices: (json['sentToDevices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
