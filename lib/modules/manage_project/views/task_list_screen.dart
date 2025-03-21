import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_hive/modules/manage_project/controllers/manage_project_controller.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../models/project.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  final int projectIndex;

  TaskListScreen({super.key, required this.projectIndex});

  final ManageProjectController projectC = Get.find<ManageProjectController>();

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
        title: ValueListenableBuilder(
          valueListenable: projectC.projectBox.listenable(),
          builder: (context, Box<Project> box, _) {
            final project = box.getAt(projectIndex);
            return Text(
              project?.title ?? 'Task List',
              style: AppTextStyle.mediumBlack20
                  .copyWith(fontWeight: FontWeight.w700),
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(
                      "Delete Project",
                      style: AppTextStyle.mediumBlack18,
                    ),
                    content: Text(
                      "Are you sure you want to delete this Project?",
                      style: AppTextStyle.regularBlack14,
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: const Color(0xffF0F0F0),
                            minimumSize: Size(100, 40),
                            elevation: 0),
                        child: Text(
                          'No',
                          style: AppTextStyle.mediumPrimary14,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          projectC.deleteProject(projectIndex);
                          Get.back(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: AppColors.primary,
                            minimumSize: Size(100, 40),
                            elevation: 0),
                        child: Text(
                          "Yes",
                          style: AppTextStyle.mediumBlack14
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: Image.asset(
                'assets/icons/ic_delete.png',
                height: 22,
              ),
            ),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: projectC.projectBox.listenable(),
        builder: (context, Box<Project> box, _) {
          final project = box.getAt(projectIndex);
          if (project == null || project.tasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks available. Add a new task!',
                style: AppTextStyle.regularBlack16,
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            itemCount: project.tasks.length,
            itemBuilder: (context, taskIndex) {
              final task = project.tasks[taskIndex];
              final isCompleted = task.status == 'Complete';
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 12, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyle.mediumBlack16.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isCompleted ? Color(0xffAFAFAF) : Colors.black,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task.description,
                            style: AppTextStyle.regularBlack14.copyWith(
                              fontSize: 13,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isCompleted
                                  ? Color(0xffAFAFAF)
                                  : Colors.black,
                            ),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                              popupMenuTheme: PopupMenuThemeData(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.more_vert,
                                color: Color(0xffAFAFAF),
                                size: 30,
                              ),
                              onSelected: (value) async {
                                if (value == "Edit") {
                                  Get.to(() => AddTaskScreen(
                                      projectIndex: projectIndex,
                                      taskIndex: taskIndex,
                                      task: task));
                                } else if (value == "Delete") {
                                  bool? shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: AppColors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        title: Column(
                                          children: [
                                            Image.asset(
                                                'assets/icons/ic_delete.webp',
                                                height: 74),
                                            const SizedBox(height: 10),
                                            Text(
                                              "Delete Task",
                                              style: AppTextStyle.mediumBlack18,
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          "Are you sure you want to delete this task?",
                                          style: AppTextStyle.regularBlack12,
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                backgroundColor:
                                                    const Color(0xffF0F0F0),
                                                minimumSize: Size(100, 40),
                                                elevation: 0),
                                            child: Text(
                                              'No',
                                              style:
                                                  AppTextStyle.mediumPrimary14,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                backgroundColor:
                                                    AppColors.primary,
                                                minimumSize: Size(100, 40),
                                                elevation: 0),
                                            child: Text(
                                              "Yes",
                                              style: AppTextStyle.mediumBlack14
                                                  .copyWith(
                                                      color: AppColors.white),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldDelete == true) {
                                    projectC.deleteTask(
                                        projectIndex, taskIndex);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: "Edit",
                                  child: Text(
                                    "Edit",
                                    style: AppTextStyle.regularBlack16,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "Delete",
                                  child: Text(
                                    "Delete",
                                    style: AppTextStyle.mediumBlack16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: Get.height * 0.003,
                        color: Color(0xffEEEEEE),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Priority Level: ${task.priority}',
                            style: AppTextStyle.mediumBlack14.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isCompleted
                                  ? Color(0xffAFAFAF)
                                  : Color(0xffAFAFAF),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status: ${task.status}',
                                  style: AppTextStyle.mediumBlack14.copyWith(
                                    color: task.status == 'Complete'
                                        ? Colors.green
                                        : task.status == 'In Progress'
                                            ? AppColors
                                                .orange // Yellow for "In Progress"
                                            : Colors.red, // Red for "Pending"
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => AddTaskScreen(projectIndex: projectIndex));
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
                "Add new Task",
                style:
                    AppTextStyle.mediumBlack16.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
