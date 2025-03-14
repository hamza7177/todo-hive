import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/modules/manage_project/controllers/manage_project_controller.dart';
import 'package:todo_hive/modules/manage_project/models/task.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../schedule_planner/widgets/priority_filter.dart';

class AddTaskScreen extends StatefulWidget {
  final int projectIndex;
  final int? taskIndex;
  final ProjectTask? task;

  AddTaskScreen({super.key, required this.projectIndex, this.taskIndex, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final ManageProjectController projectC = Get.find<ManageProjectController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Prepopulate fields if editing an existing task
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      projectC.selectedPriority.value = widget.task!.priority;
      projectC.taskStatus.value = widget.task!.status;
      projectC.selectedDateTime.value = widget.task!.dueDate;
      projectC.selectedDate.value = DateFormat('EEE, MMM d').format(widget.task!.dueDate);
    }

    // Optional: Add listeners for debugging focus issues
    titleFocusNode.addListener(() {
      if (titleFocusNode.hasFocus) {
        print("Title TextField gained focus");
      }
    });
    descriptionFocusNode.addListener(() {
      if (descriptionFocusNode.hasFocus) {
        print("Description TextField gained focus");
      }
    });
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Helper method to dismiss keyboard and prevent blink
  void _dismissKeyboard(BuildContext context) {
    if (titleFocusNode.hasFocus || descriptionFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(FocusNode()); // Shift focus to a dummy node
      Future.delayed(Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus(); // Ensure keyboard stays dismissed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
        ),
        title: Text(
          widget.task == null ? 'Add new Task' : 'Edit Task',
          style: AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: GestureDetector(
        onTap: () => _dismissKeyboard(context), // Dismiss keyboard on tap outside
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          children: [
            Text(
              'Task Name',
              style: AppTextStyle.mediumBlack16,
            ),
            SizedBox(height: 10),
            TextField(
              controller: titleController,
              focusNode: titleFocusNode, // Attach FocusNode
              decoration: InputDecoration(
                hintText: "Name your task...",
                hintStyle: AppTextStyle.regularBlack16.copyWith(color: Color(0xffAFAFAF)),
                filled: true,
                fillColor: AppColors.textFieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              minLines: 1,
              maxLines: 3,
              style: AppTextStyle.regularBlack16,
            ),
            SizedBox(height: 10),
            Text(
              'Set Due Date',
              style: AppTextStyle.mediumBlack16,
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                _dismissKeyboard(context); // Dismiss keyboard before picker
                await projectC.pickDate(context);
                // Small delay to prevent focus flicker
                await Future.delayed(Duration(milliseconds: 50));
                _dismissKeyboard(context); // Ensure no refocus after picker
              },
              child: Container(
                height: 51,
                width: 175,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xffF9F9F9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Obx(() => Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Color(0xffAFAFAF),
                    ),
                    SizedBox(width: 5),
                    Text(
                      projectC.selectedDate.value,
                      style: AppTextStyle.mediumBlack16,
                    ),
                  ],
                )),
              ),
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Description',
                  style: AppTextStyle.mediumBlack16,
                ),
                SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '(Optional)',
                    style: AppTextStyle.mediumBlack14.copyWith(color: Color(0xff8A8A8A)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              focusNode: descriptionFocusNode, // Attach FocusNode
              decoration: InputDecoration(
                hintText: "Write something here...",
                hintStyle: AppTextStyle.regularBlack16.copyWith(color: Color(0xffAFAFAF)),
                filled: true,
                fillColor: AppColors.textFieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              minLines: 3,
              maxLines: 5,
              style: AppTextStyle.regularBlack16,
            ),
            SizedBox(height: 10),
            Text(
              'Priority Level',
              style: AppTextStyle.mediumBlack16,
            ),
            SizedBox(height: 10),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Obx(() => PriorityFilter(
                      label: "Low",
                      isSelected: projectC.selectedPriority.value == "Low",
                      onTap: () => projectC.selectedPriority.value = "Low",
                    )),
                    const SizedBox(width: 8.0),
                    Obx(() => PriorityFilter(
                      label: "Medium",
                      isSelected: projectC.selectedPriority.value == "Medium",
                      onTap: () => projectC.selectedPriority.value = "Medium",
                    )),
                    const SizedBox(width: 8.0),
                    Obx(() => PriorityFilter(
                      label: "High",
                      isSelected: projectC.selectedPriority.value == "High",
                      onTap: () => projectC.selectedPriority.value = "High",
                    )),
                  ],
                ),
              ),
            ),
            if (widget.task != null) ...[
              SizedBox(height: 10),
              Text(
                'Status',
                style: AppTextStyle.mediumBlack16,
              ),
              SizedBox(height: 10),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => PriorityFilter(
                        label: "Pending",
                        isSelected: projectC.taskStatus.value == "Pending",
                        onTap: () => projectC.taskStatus.value = "Pending",
                      )),
                      const SizedBox(width: 8.0),
                      Obx(() => PriorityFilter(
                        label: "In Progress",
                        isSelected: projectC.taskStatus.value == "In Progress",
                        onTap: () => projectC.taskStatus.value = "In Progress",
                      )),
                      const SizedBox(width: 8.0),
                      Obx(() => PriorityFilter(
                        label: "Complete",
                        isSelected: projectC.taskStatus.value == "Complete",
                        onTap: () => projectC.taskStatus.value = "Complete",
                      )),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && projectC.selectedDateTime.value != null) {
                  final newTask = ProjectTask(
                    title: titleController.text,
                    description: descriptionController.text,
                    priority: projectC.selectedPriority.value,
                    status: widget.task == null ? "Pending" : projectC.taskStatus.value,
                    dueDate: projectC.selectedDateTime.value!,
                  );
                  if (widget.task == null) {
                    projectC.addTask(widget.projectIndex, newTask);
                  } else {
                    projectC.updateTaskStatus(widget.projectIndex, widget.taskIndex!, projectC.taskStatus.value);
                    final project = projectC.projectBox.getAt(widget.projectIndex);
                    project?.tasks = List<ProjectTask>.from(project.tasks); // Ensure modifiable
                    project?.tasks[widget.taskIndex!] = newTask;
                    project?.save();
                  }
                  // Clear the fields after saving/updating
                  titleController.clear();
                  descriptionController.clear();
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Please enter a title and select a due date');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Center(
                child: Text(
                  widget.task == null ? "Save the task" : "Update the task",
                  style: AppTextStyle.mediumBlack16.copyWith(color: AppColors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}