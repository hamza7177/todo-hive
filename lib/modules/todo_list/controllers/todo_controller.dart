import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../model/task_model.dart';

class TodoController extends GetxController {
  final Box<Task> taskBox = Hive.box<Task>('tasks');
  final Box<Task> completedTaskBox = Hive.box<Task>('completed_tasks'); // New box for completed tasks

  var selectedFilter = "All".obs;
  var tasks = <Task>[].obs;
  var completedTasks = <Task>[].obs; // List for completed tasks
  var selectedCategory = "".obs;
  var selectedUpdateCategory = "".obs;

  @override
  void onInit() {
    fetchTasks();
    fetchCompletedTasks(); // Load completed tasks
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
    // Create a new instance for completed box
    final completedTask = Task(
      title: task.title,
      category: task.category,
      date: task.date,
      completedAt: DateTime.now(),
    );
    completedTaskBox.add(completedTask); // Add to completed box
    deleteTask(task); // Remove from active tasks
    fetchCompletedTasks(); // Refresh completed tasks
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