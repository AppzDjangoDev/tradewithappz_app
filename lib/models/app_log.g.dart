// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppLogAdapter extends TypeAdapter<AppLog> {
  @override
  final int typeId = 0;

  @override
  AppLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppLog(
      id: fields[0] as int,
      date: fields[1] as DateTime,
      timestamp: fields[2] as String,
      accessToken: fields[3] as String,
      clientId: fields[4] as String,
      misc: fields[5] as String,
      username: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.accessToken)
      ..writeByte(4)
      ..write(obj.clientId)
      ..writeByte(5)
      ..write(obj.misc)
      ..writeByte(6)
      ..write(obj.username);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
