import 'package:hive/hive.dart';

part 'connected_device_hive_model.g.dart';

/// Подключенное устройство (для сервера)
@HiveType(typeId: 9)
class ConnectedDeviceHiveModel extends HiveObject {
  @HiveField(0)
  String deviceId;

  @HiveField(1)
  String deviceName;

  @HiveField(2)
  String ipAddress;

  @HiveField(3)
  DateTime connectedAt;

  @HiveField(4)
  DateTime lastSeenAt;

  @HiveField(5)
  bool isOnline;

  @HiveField(6)
  DateTime? lastSyncAt;

  ConnectedDeviceHiveModel({
    required this.deviceId,
    required this.deviceName,
    required this.ipAddress,
    DateTime? connectedAt,
    DateTime? lastSeenAt,
    this.isOnline = true,
    this.lastSyncAt,
  })  : connectedAt = connectedAt ?? DateTime.now(),
        lastSeenAt = lastSeenAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'connectedAt': connectedAt.toIso8601String(),
      'lastSeenAt': lastSeenAt.toIso8601String(),
      'isOnline': isOnline,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  factory ConnectedDeviceHiveModel.fromJson(Map<String, dynamic> json) {
    return ConnectedDeviceHiveModel(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      ipAddress: json['ipAddress'] as String,
      connectedAt: json['connectedAt'] != null
          ? DateTime.parse(json['connectedAt'] as String)
          : null,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
    );
  }
}
