import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/custom_flash_bar.dart';
import '../controllers/reminder_controller.dart';
import '../models/reminder_model.dart';

class CompletedTasksScreen extends StatelessWidget {
  final ReminderController controller = Get.find<ReminderController>();

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
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'View all your completed reminders here.',
              style: AppTextStyle.regularBlack16,
            ),
          ),
          Expanded(
            child: Obx(() {
              print(
                  'Completed reminders count: ${controller.completedReminders.length}');
              if (controller.completedReminders.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.completedReminders.length,
                itemBuilder: (context, index) {
                  final reminder = controller.completedReminders[index];
                  return Column(
                    children: [
                      _buildCompletedTile(reminder, context),
                      SizedBox(height: 10),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/ic_reminder.webp', height: 140),
          SizedBox(height: 10),
          Text(
            'No completed tasks yet!',
            style: AppTextStyle.mediumBlack18
                .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Text('Complete some reminders to see them here',
              style: AppTextStyle.regularBlack16),
        ],
      ),
    );
  }

  Widget _buildCompletedTile(ReminderModel reminder, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed: ${DateFormat('EEE, MMM d, h:mm a').format(reminder.completedAt!)}',
                style: AppTextStyle.regularBlack14
                    .copyWith(color: Color(0xffCCCCCC)),
              ),
              SizedBox(height: 5),
              Text(
                reminder.name,
                style: AppTextStyle.mediumBlack16.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 21),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  if (reminder.isRepeating)
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                                reminder.color.replaceFirst('#', '0xff')))
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(66),
                      ),
                      child: Icon(
                        Icons.repeat_rounded,
                        color: Color(int.parse(
                            reminder.color.replaceFirst('#', '0xff'))),
                        size: 12,
                      ),
                    ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                              reminder.color.replaceFirst('#', '0xff')))
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(66),
                    ),
                    child: Text(
                      _getReminderDetails(reminder),
                      style: AppTextStyle.regularBlack12.copyWith(
                        color: Color(int.parse(
                            reminder.color.replaceFirst('#', '0xff'))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_horiz,
                color: Color(0xffAFAFAF),
                size: 30,
              ),
              onSelected: (value) async {
                if (value == "Delete") {
                  bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text("Delete Completed Task",
                          style: AppTextStyle.mediumBlack18),
                      content: Text(
                          "Are you sure you want to delete this completed task?",
                          style: AppTextStyle.regularBlack14),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: Color(0xffF0F0F0),
                              minimumSize: Size(100, 40),
                              elevation: 0),
                          child:
                              Text('No', style: AppTextStyle.mediumPrimary14),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: AppColors.primary,
                              minimumSize: Size(100, 40),
                              elevation: 0),
                          child: Text("Yes",
                              style: AppTextStyle.mediumBlack14
                                  .copyWith(color: AppColors.white)),
                        ),
                      ],
                    ),
                  );
                  if (shouldDelete == true) {
                    reminder.delete();
                    controller.loadCompletedReminders();
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
                PopupMenuItem(
                    value: "Delete",
                    child: Text("Delete", style: AppTextStyle.mediumBlack16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReminderDetails(ReminderModel reminder) {
    if (reminder.reminderType == 'interval') {
      return '${reminder.intervalHours > 0 ? '${reminder.intervalHours} hours ' : ''}${reminder.intervalMinutes > 0 ? '${reminder.intervalMinutes} minutes' : ''}';
    } else if (reminder.reminderType == 'date_time') {
      return '${DateFormat('EEE, MMM d').format(reminder.dateTime!)} at ${DateFormat('h:mm a').format(reminder.dateTime!)}';
    } else if (reminder.reminderType == 'weekday') {
      return '${reminder.weekdays.map((d) => _getWeekdayName(d)).join(", ")} at ${DateFormat('h:mm a').format(reminder.dateTime!)}';
    }
    return '';
  }

  String _getWeekdayName(int dayIndex) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayIndex];
  }
}
