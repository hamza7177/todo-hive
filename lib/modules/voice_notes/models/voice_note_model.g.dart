// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoiceNoteAdapter extends TypeAdapter<VoiceNote> {
  @override
  final int typeId = 4;

  @override
  VoiceNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoiceNote(
      title: fields[0] as String,
      audioPath: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VoiceNote obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.audioPath)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
