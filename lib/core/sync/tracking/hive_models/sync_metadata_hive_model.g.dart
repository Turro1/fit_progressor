// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metadata_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncMetadataHiveModelAdapter extends TypeAdapter<SyncMetadataHiveModel> {
  @override
  final int typeId = 7;

  @override
  SyncMetadataHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncMetadataHiveModel(
      deviceId: fields[0] as String,
      deviceName: fields[1] as String,
      lastFullSyncAt: fields[2] as DateTime?,
      isServer: fields[3] as bool,
      serverPort: fields[4] as int,
      connectedServerId: fields[5] as String?,
      connectedServerIp: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncMetadataHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.deviceName)
      ..writeByte(2)
      ..write(obj.lastFullSyncAt)
      ..writeByte(3)
      ..write(obj.isServer)
      ..writeByte(4)
      ..write(obj.serverPort)
      ..writeByte(5)
      ..write(obj.connectedServerId)
      ..writeByte(6)
      ..write(obj.connectedServerIp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncMetadataHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
