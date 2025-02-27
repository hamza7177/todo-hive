// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroceryListAdapter extends TypeAdapter<GroceryList> {
  @override
  final int typeId = 6;

  @override
  GroceryList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroceryList(
      id: fields[0] as String,
      name: fields[1] as String,
      isStarred: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GroceryList obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isStarred);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroceryItemAdapter extends TypeAdapter<GroceryItem> {
  @override
  final int typeId = 7;

  @override
  GroceryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroceryItem(
      name: fields[0] as String,
      quantity: fields[1] as int,
      listId: fields[2] as String,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GroceryItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.listId)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
