// schedule_model.dart
import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 5)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String color;

  @HiveField(2)
  String description;

  @HiveField(3)
  String priority;

  @HiveField(4)
  bool isReminder;

  @HiveField(5)
  DateTime dateTime;

  @HiveField(6)
  String category;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  int id;

  @HiveField(9) // New field
  bool isCompleted;

  ScheduleModel({
    required this.title,
    required this.color,
    required this.description,
    required this.priority,
    required this.isReminder,
    required this.dateTime,
    required this.category,
    required this.createdAt,
    required this.id,
    this.isCompleted = false, // Default to false
  });
}