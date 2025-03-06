// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectTaskAdapter extends TypeAdapter<ProjectTask> {
  @override
  final int typeId = 9;

  @override
  ProjectTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectTask(
      title: fields[0] as String,
      description: fields[1] as String,
      priority: fields[2] as String,
      status: fields[3] as String,
      dueDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.dueDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
