import 'package:hive/hive.dart';

part 'sync_metadata_hive_model.g.dart';

/// Метаданные синхронизации устройства
@HiveType(typeId: 7)
class SyncMetadataHiveModel extends HiveObject {
  @HiveField(0)
  String deviceId;

  @HiveField(1)
  String deviceName;

  @HiveField(2)
  DateTime? lastFullSyncAt;

  @HiveField(3)
  bool isServer;

  @HiveField(4)
  int serverPort;

  @HiveField(5)
  String? connectedServerId;

  @HiveField(6)
  String? connectedServerIp;

  SyncMetadataHiveModel({
    required this.deviceId,
    required this.deviceName,
    this.lastFullSyncAt,
    this.isServer = false,
    this.serverPort = 8765,
    this.connectedServerId,
    this.connectedServerIp,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'lastFullSyncAt': lastFullSyncAt?.toIso8601String(),
      'isServer': isServer,
      'serverPort': serverPort,
      'connectedServerId': connectedServerId,
      'connectedServerIp': connectedServerIp,
    };
  }

  factory SyncMetadataHiveModel.fromJson(Map<String, dynamic> json) {
    return SyncMetadataHiveModel(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      lastFullSyncAt: json['lastFullSyncAt'] != null
          ? DateTime.parse(json['lastFullSyncAt'] as String)
          : null,
      isServer: json['isServer'] as bool? ?? false,
      serverPort: json['serverPort'] as int? ?? 8765,
      connectedServerId: json['connectedServerId'] as String?,
      connectedServerIp: json['connectedServerIp'] as String?,
    );
  }
}
