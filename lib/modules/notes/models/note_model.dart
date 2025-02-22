import 'package:hive/hive.dart';

part 'note_model.g.dart'; // Run build_runner after creating this file

@HiveType(typeId: 1) // Unique ID for this model
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime dateTime;

  Note({
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
  });
}
