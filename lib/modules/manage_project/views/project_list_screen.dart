import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/modules/manage_project/controllers/manage_project_controller.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../models/project.dart';
import 'add_project_screen.dart';
import 'task_list_screen.dart';

class ProjectListScreen extends StatelessWidget {
  ProjectListScreen({super.key});

  final ManageProjectController projectC = Get.put(ManageProjectController());

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
          'Project Management',
          style:
          AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your ultimate companion for seamless scheduling and effortless planning.',
                  style: AppTextStyle.mediumBlack16,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: projectC.projectBox.listenable(),
              builder: (context, Box<Project> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/ic_project_manager.webp',
                          height: 140,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your management needs some projects',
                          style: AppTextStyle.mediumBlack18.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Start adding projects to work on time!',
                          style: AppTextStyle.regularBlack16,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final project = box.getAt(index)!;
                    int completedTasks = project.tasks
                        .where((task) => task.status == "Complete")
                        .length;
                    double progress = project.tasks.isEmpty
                        ? 0
                        : (completedTasks / project.tasks.length) * 100;
                    // Filter tasks to only show "Pending" or "In Progress"
                    final filteredTasks = project.tasks
                        .where((task) =>
                    task.status == "Pending" ||
                        task.status == "In Progress")
                        .toList();
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              'Project: ${project.title}',
                              style: AppTextStyle.mediumBlack18
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            childrenPadding: EdgeInsets.zero,
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      'Progress',
                                      style: AppTextStyle.regularBlack14,
                                    ),
                                    Spacer(),
                                    Text(
                                      '${progress.toStringAsFixed(0)}%',
                                      style: AppTextStyle.regularBlack14
                                          .copyWith(color: Color(0xffAFAFAF)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.green,
                                  minHeight: 8, // Make the progress bar slightly taller
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Due Date ${DateFormat('MMM d, yyyy').format(project.dueDate)}',
                                  style: AppTextStyle.regularBlack14
                                      .copyWith(color: Color(0xffAFAFAF)),
                                ),
                              ],
                            ),
                            children: [
                              // Display filtered tasks (Pending or In Progress) as a list with red bullets
                              if (filteredTasks.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Column(
                                    children: filteredTasks.map((task) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: Container(
                                                margin: EdgeInsets.only(top: 4),
                                                width: 15,
                                                height: 15,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                task.title,
                                                style: AppTextStyle.regularBlack14
                                                    .copyWith(color: Color(0xff8A8A8A)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              // Add a button to navigate to TaskListScreen
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => TaskListScreen(projectIndex: index));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "View All Tasks",
                                      style: AppTextStyle.mediumBlack14
                                          .copyWith(color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => AddProjectScreen());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Resting elevation
          highlightElevation: 0,
          // Pressed elevation
          splashColor: Colors.transparent,
          // Removes ripple effect
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/icons/ic_add_project.png'),
          ),
        ),
      ),
    );
  }
}
