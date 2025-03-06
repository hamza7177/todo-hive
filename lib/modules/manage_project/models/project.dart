import 'package:hive/hive.dart';
import 'task.dart';
part 'project.g.dart';

@HiveType(typeId: 8)
class Project extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dueDate;

  @HiveField(2)
  List<ProjectTask> tasks;

  Project({required this.title, required this.dueDate, List<ProjectTask>? tasks})
      : tasks = tasks != null ? List<ProjectTask>.from(tasks) : [];
}