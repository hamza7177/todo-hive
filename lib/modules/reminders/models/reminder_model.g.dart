// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderModelAdapter extends TypeAdapter<ReminderModel> {
  @override
  final int typeId = 2;

  @override
  ReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderModel(
      id: fields[0] as String,
      name: fields[1] as String,
      reminderType: fields[2] as String,
      dateTime: fields[3] as DateTime?,
      weekdays: (fields[4] as List).cast<int>(),
      intervalMinutes: fields[5] as int,
      intervalHours: fields[6] as int,
      isRepeating: fields[7] as bool,
      color: fields[8] as String,
      completedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.reminderType)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.weekdays)
      ..writeByte(5)
      ..write(obj.intervalMinutes)
      ..writeByte(6)
      ..write(obj.intervalHours)
      ..writeByte(7)
      ..write(obj.isRepeating)
      ..writeByte(8)
      ..write(obj.color)
      ..writeByte(9)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
