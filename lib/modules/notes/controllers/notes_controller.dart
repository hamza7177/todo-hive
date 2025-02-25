import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/note_model.dart';
import '../models/category_model.dart';

class NotesController extends GetxController {
  final Box<Note> notesBox = Hive.box<Note>('notes');
  final Box<Category> categoriesBox = Hive.box<Category>('categories');
  var notes = <Note>[].obs;
  var categories = <Category>[].obs;

  var selectedFilter = "All".obs;
  var selectedCategory = ''.obs;
  var selectedUpdateCategory = "".obs;
  var titleController = TextEditingController();
  var noteController = TextEditingController();
  var maxWords = 1500.obs;

  @override
  void onInit() {
    fetchNotes();
    fetchCategories();
    super.onInit();
  }

  void fetchNotes() {
    notes.assignAll(notesBox.values.toList());
    update();
  }

  void fetchCategories() {
    if (categoriesBox.isEmpty) {
      final defaultCategories = [
        Category(name: "Personal"),
        Category(name: "Work"),
        Category(name: "Random"),
        Category(name: "Shopping"),
      ];
      categoriesBox.addAll(defaultCategories);
    }
    categories.assignAll(categoriesBox.values.toList());
    update();
  }

  void addCategory(String name) {
    final category = Category(name: name);
    categoriesBox.add(category);
    categories.add(category);
    update();
  }

  void updateCategory(Category oldCategory, String newName) {
    final int? categoryKey = categoriesBox.keys.cast<int?>().firstWhere(
          (key) => categoriesBox.get(key) == oldCategory,
      orElse: () => null,
    );
    if (categoryKey != null) {
      oldCategory.name = newName;
      categoriesBox.put(categoryKey, oldCategory);
      for (var note in notes) {
        if (note.category == oldCategory.name) {
          note.category = newName;
          final int? noteKey = notesBox.keys.cast<int?>().firstWhere(
                (key) => notesBox.get(key) == note,
            orElse: () => null,
          );
          if (noteKey != null) {
            notesBox.put(noteKey, note);
          }
        }
      }
      categories.refresh();
      notes.refresh();
      if (selectedFilter.value == oldCategory.name) {
        selectedFilter.value = newName;
      }
      update();
    }
  }

  void deleteCategory(Category category) {
    final int? categoryKey = categoriesBox.keys.cast<int?>().firstWhere(
          (key) => categoriesBox.get(key) == category,
      orElse: () => null,
    );
    if (categoryKey != null) {
      // Update notes with this category to "Untitled"
      for (var note in notes) {
        if (note.category == category.name) {
          note.category = "Untitled"; // Or set to "" if preferred
          final int? noteKey = notesBox.keys.cast<int?>().firstWhere(
                (key) => notesBox.get(key) == note,
            orElse: () => null,
          );
          if (noteKey != null) {
            notesBox.put(noteKey, note);
          }
        }
      }
      // Delete the category from Hive
      categoriesBox.delete(categoryKey);
      categories.remove(category);
      if (selectedFilter.value == category.name) {
        selectedFilter.value = "All"; // Reset filter if deleted category was active
      }
      if (selectedCategory.value == category.name) {
        selectedCategory.value = ""; // Reset selected category
      }
      if (selectedUpdateCategory.value == category.name) {
        selectedUpdateCategory.value = ""; // Reset update category
      }
      notes.refresh();
      update();
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  void setCategory(String newCategory) {
    selectedCategory.value = newCategory;
    update();
  }

  void addNote(String title, String description, String category) {
    final task = Note(
        title: title,
        description: description,
        category: category,
        dateTime: DateTime.now());
    notesBox.add(task);
    notes.add(task);
    notes.refresh();
    selectedCategory.value = "";
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
      fetchNotes();
    }
  }

  List<Note> getFilteredNotes() {
    if (selectedFilter.value == "All") {
      return notes.toList();
    }
    return notes.where((task) => task.category == selectedFilter.value).toList();
  }

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

  void updateNote(int index, String newTitle, String newDescription, String newCategory) {
    final task = notes[index];
    task.title = newTitle;
    task.description = newDescription;
    task.category = newCategory;
    task.dateTime = DateTime.now();
    int? taskKey = notesBox.keys.cast<int?>().firstWhere(
          (key) => notesBox.get(key) == task,
      orElse: () => null,
    );
    if (taskKey != null) {
      notesBox.put(taskKey, task);
      notes.refresh();
      selectedUpdateCategory.value = "";
      update();
    }
  }

  int getWordCount() {
    return noteController.text.split(RegExp(r'\s+')).length;
  }
}