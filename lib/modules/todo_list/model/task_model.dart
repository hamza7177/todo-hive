import 'package:hive/hive.dart';

part 'task_model.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String category;

  @HiveField(2)
  DateTime date;

  Task({required this.title, required this.category, required this.date});
}
