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

  ClientHiveModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.carCount,
  });

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
    );
  }

  @override
  void write(BinaryWriter writer, ClientHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.carCount);
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
