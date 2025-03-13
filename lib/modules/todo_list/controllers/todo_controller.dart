import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../model/task_model.dart';

class TodoController extends GetxController {
  final Box<Task> taskBox = Hive.box<Task>('tasks');
  final Box<Task> completedTaskBox = Hive.box<Task>('completed_tasks');

  var selectedFilter = "All".obs;
  var tasks = <Task>[].obs;
  var completedTasks = <Task>[].obs;
  var selectedCategory = "".obs;
  var selectedUpdateCategory = "".obs;

  Timer? _cleanupTimer; // Timer for periodic cleanup

  @override
  void onInit() {
    fetchTasks();
    fetchCompletedTasks();
    startCleanupTimer(); // Start the timer for cleanup
    super.onInit();
  }

  @override
  void onClose() {
    _cleanupTimer?.cancel(); // Cancel the timer when the controller is disposed
    super.onClose();
  }

  void startCleanupTimer() {
    // Check every hour for completed tasks to delete
    _cleanupTimer = Timer.periodic(Duration(hours: 1), (timer) {
      cleanupOldCompletedTasks();
    });
  }

  void cleanupOldCompletedTasks() {
    final now = DateTime.now();
    final tasksToDelete = <int>[]; // Store keys of tasks to delete

    for (var task in completedTaskBox.values) {
      if (task.completedAt != null) {
        final durationSinceCompletion = now.difference(task.completedAt!);
        if (durationSinceCompletion.inHours >= 24) {
          int? taskKey = completedTaskBox.keys.cast<int?>().firstWhere(
                (key) => completedTaskBox.get(key) == task,
            orElse: () => null,
          );
          if (taskKey != null) {
            tasksToDelete.add(taskKey);
          }
        }
      }
    }

    // Delete the tasks
    for (var key in tasksToDelete) {
      completedTaskBox.delete(key);
    }

    fetchCompletedTasks(); // Refresh the completed tasks list
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
    update();
  }

  void fetchCompletedTasks() {
    completedTasks.assignAll(completedTaskBox.values.toList());
    update();
  }

  void addTask(String title, String category) {
    final task = Task(title: title, category: category, date: DateTime.now());
    taskBox.add(task);
    tasks.add(task);
    tasks.refresh();
    selectedCategory.value = "";
    update();
  }

  void deleteTask(Task task) {
    int? taskKey = taskBox.keys.cast<int?>().firstWhere(
          (key) => taskBox.get(key) == task,
      orElse: () => null,
    );
    if (taskKey != null) {
      taskBox.delete(taskKey);
      fetchTasks();
    }
  }

  void completeTask(Task task) {
    final completedTask = Task(
      title: task.title,
      category: task.category,
      date: task.date,
      completedAt: DateTime.now(),
    );
    completedTaskBox.add(completedTask);
    deleteTask(task);
    fetchCompletedTasks();
    Get.snackbar('Success', 'Task marked as completed');
  }

  List<Task> getFilteredTasks() {
    if (selectedFilter.value == "All") {
      return tasks.toList();
    } else if (selectedFilter.value == "Office Work") {
      return tasks.where((task) => task.category == "Office Work").toList();
    } else if (selectedFilter.value == "Wishlist") {
      return tasks.where((task) => task.category == "Wishlist").toList();
    } else if (selectedFilter.value == "Personal") {
      return tasks.where((task) => task.category == "Personal").toList();
    } else if (selectedFilter.value == "Birthday") {
      return tasks.where((task) => task.category == "Birthday").toList();
    }
    return tasks.where((task) => task.category == selectedCategory.value).toList();
  }

  List<Task> getFilteredCompletedTasks() {
    if (selectedFilter.value == "All") return completedTaskBox.values.toList();
    return completedTaskBox.values
        .where((task) => task.category == selectedFilter.value)
        .toList();
  }

  Map<DateTime, List<Task>> getTasksGroupedByDate() {
    final Map<DateTime, List<Task>> groupedTasks = {};
    for (var task in getFilteredTasks()) {
      final normalizedDate = DateTime(task.date.year, task.date.month, task.date.day);
      if (!groupedTasks.containsKey(normalizedDate)) {
        groupedTasks[normalizedDate] = [];
      }
      groupedTasks[normalizedDate]!.add(task);
    }
    return groupedTasks;
  }

  Map<DateTime, List<Task>> getCompletedTasksGroupedByDate() {
    final Map<DateTime, List<Task>> groupedTasks = {};
    for (var task in completedTasks) {
      final normalizedDate = DateTime(task.completedAt!.year, task.completedAt!.month, task.completedAt!.day);
      if (!groupedTasks.containsKey(normalizedDate)) {
        groupedTasks[normalizedDate] = [];
      }
      groupedTasks[normalizedDate]!.add(task);
    }
    return groupedTasks;
  }

  void uncompleteTask(Task task) {
    task.completedAt = null;
    int? taskKey = completedTaskBox.keys.cast<int?>().firstWhere(
          (key) => completedTaskBox.get(key) == task,
      orElse: () => null,
    );
    if (taskKey != null) {
      completedTaskBox.delete(taskKey);
      taskBox.add(task);
      fetchTasks();
      fetchCompletedTasks();
      Get.snackbar('Success', 'Task marked as active again');
    }
  }

  void updateTask(int index, String newTitle, String newCategory) {
    final task = tasks[index];
    task.title = newTitle;
    task.category = newCategory;
    int? taskKey = taskBox.keys.cast<int?>().firstWhere(
          (key) => taskBox.get(key) == task,
      orElse: () => null,
    );
    if (taskKey != null) {
      taskBox.put(taskKey, task);
      tasks.refresh();
      selectedUpdateCategory.value = "";
      update();
    }
  }
}