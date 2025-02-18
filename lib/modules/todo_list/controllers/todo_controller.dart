import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../model/task_model.dart';

class TodoController extends GetxController {
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  var selectedFilter = "All".obs;
  var tasks = <Task>[].obs;
  var selectedCategory =
      "No Specific".obs; // Default should be "All" for filtering consistency.

  @override
  void onInit() {
    fetchTasks();
    super.onInit();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    update();
  }

  void fetchTasks() {
    tasks.assignAll(taskBox.values.toList());
    update(); // Ensure UI refresh
  }

  void addTask(String title, String category) {
    final task = Task(title: title, category: category, date: DateTime.now());
    taskBox.add(task);
    tasks.add(task);
    tasks.refresh();
    selectedCategory.value == 'No Specific';
    update();
  }

  void deleteTask(Task task) {
    int? taskKey = taskBox.keys.cast<int?>().firstWhere(
          (key) => taskBox.get(key) == task,
          orElse: () => null,
        );

    if (taskKey != null) {
      taskBox.delete(taskKey);
      fetchTasks(); // Refresh the UI
    }
  }

  /// **Get tasks based on selected filter**
  List<Task> getFilteredTasks() {
    if (selectedFilter.value == "All") {
      return tasks.toList(); // Return all tasks
    } else if (selectedFilter.value == "Office Work") {
      return tasks.where((task) => task.category == "Office Work").toList();
    } else if (selectedFilter.value == "Wishlist") {
      return tasks.where((task) => task.category == "Wishlist").toList();
    } else if (selectedFilter.value == "Personal") {
      return tasks.where((task) => task.category == "Personal").toList();
    } else if (selectedFilter.value == "Birthday") {
      return tasks.where((task) => task.category == "Birthday").toList();
    }
    return tasks
        .where((task) => task.category == selectedCategory.value)
        .toList();
  }

  /// **Group tasks by date for UI display**
  Map<DateTime, List<Task>> getTasksGroupedByDate() {
    final Map<DateTime, List<Task>> groupedTasks = {};

    for (var task in getFilteredTasks()) {
      final normalizedDate =
          DateTime(task.date.year, task.date.month, task.date.day);

      if (!groupedTasks.containsKey(normalizedDate)) {
        groupedTasks[normalizedDate] = [];
      }
      groupedTasks[normalizedDate]!.add(task);
    }

    return groupedTasks;
  }
}
