import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/modules/schedule_planner/views/add_scheduler_screen.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../todo_list/widgets/todo_list_filter.dart';
import '../controllers/schedule_controller.dart';
import 'complete_schedule_screen.dart';

class ScheduleListScreen extends StatelessWidget {
  ScheduleListScreen({super.key});

  final ScheduleController scheduleC = Get.put(ScheduleController());

  String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final timeFormat = DateFormat('h.mm a');

    if (difference.inDays == 0) {
      return 'Today ${timeFormat.format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${timeFormat.format(dateTime)}';
    } else {
      return '${DateFormat('yyyy-MM-dd').format(dateTime)} ${timeFormat.format(dateTime)}';
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
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'Schedule Planner',
          style: AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle, color: AppColors.black),
            onPressed: () => Get.to(() => CompletedSchedulesScreen()),
          ),
        ],
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => TodoListFilter(
                        label: "All",
                        isSelected: scheduleC.selectedFilter.value == "All",
                        onTap: () => scheduleC.setFilter("All"),
                      )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                        label: "Low",
                        isSelected: scheduleC.selectedFilter.value == "Low",
                        onTap: () => scheduleC.setFilter("Low"),
                      )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                        label: "Medium",
                        isSelected: scheduleC.selectedFilter.value == "Medium",
                        onTap: () => scheduleC.setFilter("Medium"),
                      )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                        label: "High",
                        isSelected: scheduleC.selectedFilter.value == "High",
                        onTap: () => scheduleC.setFilter("High"),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredSchedules = scheduleC.schedules
                  .where((schedule) =>
              scheduleC.selectedFilter.value == "All" ||
                  schedule.priority == scheduleC.selectedFilter.value)
                  .toList();

              return filteredSchedules.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/ic_income.webp', height: 140),
                    const SizedBox(height: 10),
                    Text('Your schedule is empty',
                        style: AppTextStyle.mediumBlack18
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text('Start adding tasks now to stay on track!',
                        style: AppTextStyle.regularBlack16),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(14),
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = filteredSchedules[index];
                  final bgColor = Color(int.parse(
                      schedule.color.replaceFirst('#', '0xff')));

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    schedule.title,
                                    style: AppTextStyle.mediumBlack16
                                        .copyWith(fontWeight: FontWeight.w700),
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
                                    icon: Icon(Icons.more_vert, color: bgColor),
                                    onSelected: (value) async {
                                      if (value == "Complete") {
                                        scheduleC.completeSchedule(index);
                                      } else if (value == "Delete") {
                                        bool? shouldDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: AppColors.white,
                                              title: Text("Delete Schedule",
                                                  style: AppTextStyle.mediumBlack16),
                                              content: Text(
                                                "Are you sure you want to delete this schedule?",
                                                style: AppTextStyle.regularBlack14,
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    backgroundColor: Color(0xffF0F0F0),
                                                  ),
                                                  child: Text('No',
                                                      style: AppTextStyle.mediumPrimary14),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(true),
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    backgroundColor: AppColors.primary,
                                                  ),
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
                                        if (shouldDelete == true) {
                                          scheduleC.deleteSchedule(index);
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: "Complete",
                                        child: Text("Complete",
                                            style: AppTextStyle.regularBlack16),
                                      ),
                                      PopupMenuItem(
                                        value: "Delete",
                                        child: Text("Delete",
                                            style: AppTextStyle.mediumBlack16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              schedule.description,
                              style: AppTextStyle.regularBlack14,
                            ),
                            Row(
                              children: [
                                Text(
                                  formatDate(schedule.createdAt),
                                  style: AppTextStyle.regularBlack12
                                      .copyWith(color: bgColor),
                                ),
                                SizedBox(width: 5),
                                schedule.isReminder
                                    ? Text(
                                  '| Remind on: ${DateFormat('EEE, MMM d, hh:mm a').format(schedule.dateTime)}',
                                  style: AppTextStyle.regularBlack12
                                      .copyWith(color: bgColor),
                                )
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () => Get.to(() => AddSchedulerScreen()),
          backgroundColor: Colors.transparent,
          elevation: 0,           // Resting elevation
          highlightElevation: 0,   // Pressed elevation
          splashColor: Colors.transparent, // Removes ripple effect
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/icons/ic_add_shedule.webp'),
          ),
        ),
      ),
    );
  }
}