import 'package:hive/hive.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';
import 'package:fit_progressor/features/clients/domain/entities/client.dart';

/// Hive model for Client
class ClientHiveModel extends HiveObject {
  String id;
  String name;
  String phone;
  DateTime createdAt;
  int carCount;

  // Sync fields
  int version;
  DateTime updatedAt;
  String? lastSyncDeviceId;

  ClientHiveModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.carCount,
    this.version = 1,
    DateTime? updatedAt,
    this.lastSyncDeviceId,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Convert from domain entity
  factory ClientHiveModel.fromEntity(Client entity) {
    return ClientHiveModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      createdAt: entity.createdAt ?? DateTime.now(),
      carCount: entity.carCount,
    );
  }

  /// Convert to domain entity
  Client toEntity() {
    return Client(
      id: id,
      name: name,
      phone: phone,
      createdAt: createdAt,
      carCount: carCount,
    );
  }

  /// Serialize to JSON for sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'carCount': carCount,
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncDeviceId': lastSyncDeviceId,
    };
  }

  /// Deserialize from JSON for sync
  factory ClientHiveModel.fromJson(Map<String, dynamic> json) {
    return ClientHiveModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      carCount: json['carCount'] as int,
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastSyncDeviceId: json['lastSyncDeviceId'] as String?,
    );
  }
}

/// Manual adapter for ClientHiveModel
class ClientHiveModelAdapter extends TypeAdapter<ClientHiveModel> {
  @override
  final int typeId = HiveTypeIds.client;

  @override
  ClientHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      createdAt: fields[3] as DateTime,
      carCount: fields[4] as int,
      version: fields[5] as int? ?? 1,
      updatedAt: fields[6] as DateTime?,
      lastSyncDeviceId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClientHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.carCount)
      ..writeByte(5)
      ..write(obj.version)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.lastSyncDeviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
