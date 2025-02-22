import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/note_model.dart';

class NotesController extends GetxController{
  final Box<Note> notesBox = Hive.box<Note>('notes');
  var notes = <Note>[].obs;

  var selectedFilter = "All".obs;
  var selectedCategory = ''.obs;
  var selectedUpdateCategory = "".obs;
  var titleController = TextEditingController();
  var noteController = TextEditingController();
  var maxWords = 1500.obs;


  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }


  void setCategory(String newCategory) {
    selectedCategory.value = newCategory;
    update();
  }

  void fetchNotes() {
    notes.assignAll(notesBox.values.toList());
    update(); // Ensure UI refresh
  }

  void addNote(String title,String description, String category) {
    final task = Note(title: title,description: description, category: category, dateTime: DateTime.now());
    notesBox.add(task);
    notes.add(task);
    notes.refresh();
    selectedCategory.value ="";
    titleController.clear();
    noteController.clear();
    update();
  }

  void deleteTask(Note task) {
    int? taskKey = notesBox.keys.cast<int?>().firstWhere(
          (key) => notesBox.get(key) == task,
      orElse: () => null,
    );

    if (taskKey != null) {
      notesBox.delete(taskKey);
      fetchNotes(); // Refresh the UI
    }
  }

  /// **Get notes based on selected filter**
  List<Note> getFilteredNotes() {
    if (selectedFilter.value == "All") {
      return notes.toList(); // Return all tasks
    } else if (selectedFilter.value == "Personal") {
      return notes.where((task) => task.category == "Personal").toList();
    } else if (selectedFilter.value == "Work") {
      return notes.where((task) => task.category == "Work").toList();
    } else if (selectedFilter.value == "Random") {
      return notes.where((task) => task.category == "Random").toList();
    } else if (selectedFilter.value == "Shopping") {
      return notes.where((task) => task.category == "Shopping").toList();
    }else if (selectedFilter.value == "Untitled") {
      return notes.where((task) => task.category == "Untitled").toList();
    }
    return notes
        .where((task) => task.category == selectedCategory.value)
        .toList();
  }

  /// **Group tasks by date for UI display**
  Map<DateTime, List<Note>> getTasksGroupedByDate() {
    final Map<DateTime, List<Note>> groupedTasks = {};

    for (var task in getFilteredNotes()) {
      final normalizedDate =
      DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day);

      if (!groupedTasks.containsKey(normalizedDate)) {
        groupedTasks[normalizedDate] = [];
      }
      groupedTasks[normalizedDate]!.add(task);
    }

    return groupedTasks;
  }

  void updateNote(int index, String newTitle,String newDescription, String newCategory) {
    final task = notes[index];
    task.title = newTitle;
    task.description = newDescription;
    task.category = newCategory;
    task.dateTime = DateTime.now();

    // Update the task in Hive
    int? taskKey = notesBox.keys.cast<int?>().firstWhere(
          (key) => notesBox.get(key) == task,
      orElse: () => null,
    );

    if (taskKey != null) {
      notesBox.put(taskKey, task);
      notes.refresh();
      selectedUpdateCategory.value="";// Refresh the observable list
      update(); // Ensure UI refresh
    }
  }

  int getWordCount() {
    return noteController.text.split(RegExp(r'\s+')).length;
  }

  @override
  void onInit() {
    fetchNotes();
    super.onInit();
  }
}