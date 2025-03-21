import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../../utils/widgets/custom_flash_bar.dart';
import '../controllers/todo_controller.dart';
import '../model/task_model.dart';

class CompletedTodoScreen extends StatelessWidget {
  final TodoController todoC = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'Completed Tasks',
          style: AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'View all your completed tasks here.',
              style: AppTextStyle.regularBlack16,
            ),
          ),
          Expanded(
            child: Obx(() {
              final groupedTasks = _getTasksGroupedByDate();
              if (groupedTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/ic_emptytodo.webp', height: 140),
                      SizedBox(height: 10),
                      Text(
                        'No completed tasks yet!',
                        style: AppTextStyle.mediumBlack18.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Text('Complete some tasks to see them here', style: AppTextStyle.regularBlack16),
                    ],
                  ),
                );
              }
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: groupedTasks.entries.map((entry) {
                  final date = entry.key;
                  final tasksForDate = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "${date.day}-${date.month}-${date.year}",
                          style: AppTextStyle.mediumBlack18.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...tasksForDate.map((task) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              height: 70,
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [

                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: AppTextStyle.mediumBlack16,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          'Completed: ${DateFormat('MMM d, h:mm a').format(task.completedAt!)}',
                                          style: AppTextStyle.regularBlack12.copyWith(color: Color(0xffCCCCCC)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      popupMenuTheme: PopupMenuThemeData(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                    child: PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert, color: Color(0xffAFAFAF)),
                                      onSelected: (value) async {
                                        if (value == "Delete") {
                                          bool? shouldDelete = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: AppColors.white,
                                              title: Text("Delete Completed Task", style: AppTextStyle.mediumBlack16),
                                              content: Text("Are you sure you want to delete this completed task?", style: AppTextStyle.regularBlack14),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xffF0F0F0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                                  child: Text('No', style: AppTextStyle.mediumPrimary14),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                                  child: Text("Yes", style: AppTextStyle.mediumBlack14.copyWith(color: AppColors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (shouldDelete == true) {
                                            task.delete();
                                            todoC.fetchCompletedTasks();
                                            CustomFlashBar.show(
                                              context: context,
                                              message: "Completed task deleted",
                                              isAdmin: true, // optional
                                              isShaking: false, // optional
                                              primaryColor: AppColors.primary, // optional
                                              secondaryColor: Colors.white, // optional
                                            );

                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(value: "Delete", child: Text("Delete", style: AppTextStyle.mediumBlack16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Task>> _getTasksGroupedByDate() {
    final Map<DateTime, List<Task>> groupedTasks = {};
    for (var task in todoC.completedTasks) {
      final normalizedDate = DateTime(task.completedAt!.year, task.completedAt!.month, task.completedAt!.day);
      if (!groupedTasks.containsKey(normalizedDate)) {
        groupedTasks[normalizedDate] = [];
      }
      groupedTasks[normalizedDate]!.add(task);
    }
    return groupedTasks;
  }
}