import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_colors.dart';

import '../models/project.dart';
import '../models/task.dart';

class ManageProjectController extends GetxController {
  var selectedFilter = "All".obs;
  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  RxString selectedDate = 'Select Date'.obs;

  var selectedPriority = "Low".obs;
  var taskStatus = "Pending".obs;

  late Box<Project> projectBox;

  @override
  void onInit() {
    super.onInit();
    projectBox = Hive.box<Project>('projects');
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime selected = selectedDateTime.value ?? DateTime.now();

    final DateTime? picked = await showRoundedDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      theme: ThemeData(
        primaryColor: AppColors.primary,
      ),
      // Add height constraint
      height: MediaQuery.of(context).size.height * 0.4,
      // 70% of screen height
      // Customize appearance
      styleDatePicker: MaterialRoundedDatePickerStyle(
        // Apply your theme colors
        textStyleDayButton: TextStyle(color: AppColors.white, fontSize: 20),
        textStyleYearButton: TextStyle(color: AppColors.white, fontSize: 20),
        textStyleDayHeader: TextStyle(color: AppColors.primary, fontSize: 14),
        backgroundPicker: Colors.white,
        decorationDateSelected:
        BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        textStyleDayOnCalendarSelected: TextStyle(
            fontSize: 14, color: AppColors.white, fontWeight: FontWeight.bold),
        textStyleButtonPositive:
        TextStyle(fontSize: 14, color: AppColors.primary),
        textStyleButtonNegative: TextStyle(
          fontSize: 14,
          color: AppColors.primary,
        ),
        // // Add padding if needed
      ),
    );

    if (picked != null) {
      selectedDateTime.value = picked;
      selectedDate.value = DateFormat('EEE, MMM d').format(picked);
    }
  }

  void addProject(String title, DateTime dueDate) {
    final project = Project(title: title, dueDate: dueDate);
    projectBox.add(project);
    resetFields();
    update();
  }

  void addTask(int projectIndex, ProjectTask task) {
    final project = projectBox.getAt(projectIndex);
    if (project != null) {
      project.tasks = List<ProjectTask>.from(project.tasks);
      project.tasks.add(task);
      project.save();
      resetFields();
      update();
    }
  }

  void updateTaskStatus(int projectIndex, int taskIndex, String newStatus) {
    final project = projectBox.getAt(projectIndex);
    if (project != null && taskIndex < project.tasks.length) {
      project.tasks = List<ProjectTask>.from(project.tasks);
      project.tasks[taskIndex].status = newStatus;
      project.save();
      resetFields();
      update();
    }
  }

  void deleteTask(int projectIndex, int taskIndex) {
    final project = projectBox.getAt(projectIndex);
    if (project != null && taskIndex < project.tasks.length) {
      project.tasks = List<ProjectTask>.from(project.tasks);
      project.tasks.removeAt(taskIndex);
      project.save();
      update();
    }
  }

  void deleteProject(int projectIndex) {
    projectBox.deleteAt(projectIndex);
    update();
    Get.back(); // Navigate back to the ProjectListScreen after deletion
  }

  void resetFields() {
    selectedDateTime.value = null;
    selectedDate.value = 'Select Date';
    selectedPriority.value = "Low";
    taskStatus.value = "Pending";
  }
}