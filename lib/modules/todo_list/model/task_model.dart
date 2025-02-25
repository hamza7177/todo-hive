import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String category;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  DateTime? completedAt; // New field for completion timestamp

  Task({
    required this.title,
    required this.category,
    required this.date,
    this.completedAt,
  });
}