import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/schedule_controller.dart';

class CompletedSchedulesScreen extends StatelessWidget {
  final ScheduleController scheduleC = Get.find();

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
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'Completed Schedules',
          style: AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        final completedSchedules = scheduleC.completedSchedules;

        return completedSchedules.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/ic_income.webp', height: 140),
              SizedBox(height: 10),
              Text(
                'No completed schedules yet',
                style: AppTextStyle.mediumBlack18
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text(
                'Complete some tasks to see them here!',
                style: AppTextStyle.regularBlack16,
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(14),
          itemCount: completedSchedules.length,
          itemBuilder: (context, index) {
            final schedule = completedSchedules[index];
            final bgColor =
            Color(int.parse(schedule.color.replaceFirst('#', '0xff')));

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15,bottom: 10,top: 10),
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
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.more_vert, color: bgColor),
                              onSelected: (value) async {
                                if (value == "Delete") {
                                  bool? shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: AppColors.white,
                                        title: Text(
                                          "Delete Completed Schedule",
                                          style: AppTextStyle.mediumBlack16,
                                        ),
                                        content: Text(
                                          "Are you sure you want to delete this completed schedule?",
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
                                              backgroundColor: Color(0xffF0F0F0),
                                            ),
                                            child: Text(
                                              'No',
                                              style: AppTextStyle.mediumPrimary14,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
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
                                    scheduleC.deleteSchedule(index, fromCompleted: true);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
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
                      Text(
                        schedule.description,
                        style: AppTextStyle.regularBlack14,
                      ),
                      Row(
                        children: [

                          SizedBox(width: 5),
                          schedule.isReminder
                              ? Text(
                            'Completed on: ${DateFormat('EEE, MMM d, hh:mm a').format(schedule.dateTime)}',
                            style: AppTextStyle.regularBlack10
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
    );
  }
}