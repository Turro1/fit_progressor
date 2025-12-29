// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connected_device_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConnectedDeviceHiveModelAdapter
    extends TypeAdapter<ConnectedDeviceHiveModel> {
  @override
  final int typeId = 9;

  @override
  ConnectedDeviceHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConnectedDeviceHiveModel(
      deviceId: fields[0] as String,
      deviceName: fields[1] as String,
      ipAddress: fields[2] as String,
      connectedAt: fields[3] as DateTime?,
      lastSeenAt: fields[4] as DateTime?,
      isOnline: fields[5] as bool,
      lastSyncAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ConnectedDeviceHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.deviceName)
      ..writeByte(2)
      ..write(obj.ipAddress)
      ..writeByte(3)
      ..write(obj.connectedAt)
      ..writeByte(4)
      ..write(obj.lastSeenAt)
      ..writeByte(5)
      ..write(obj.isOnline)
      ..writeByte(6)
      ..write(obj.lastSyncAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectedDeviceHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
