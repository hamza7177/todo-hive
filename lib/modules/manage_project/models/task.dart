
import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 9)
class ProjectTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String priority;

  @HiveField(3)
  String status;

  @HiveField(4)
  DateTime dueDate;

  ProjectTask({
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
  });
}