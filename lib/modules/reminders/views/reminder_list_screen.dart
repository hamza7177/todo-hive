import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/modules/reminders/views/completed_task_screen.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../../utils/app_colors.dart';
import '../controllers/reminder_controller.dart';
import '../models/reminder_model.dart';
import 'add_reminder_screen.dart';

class ReminderListScreen extends StatelessWidget {
  ReminderListScreen({super.key});

  final ReminderController controller = Get.put(ReminderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        // Removes the shadow when not scrolled
        scrolledUnderElevation: 0,
        // Prevents shadow on scroll with Material 3
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
        ),
        title: Text(
          'Reminder',
          style:
              AppTextStyle.mediumBlack18.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => CompletedTasksScreen());
              },
              icon: Icon(Icons.check_circle, color: AppColors.black)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add the text here
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Your go-to solution for setting reminders and staying effortlessly organized.',
              style: AppTextStyle.regularBlack16,
            ),
          ),
          // Add the Obx and ListView.builder here
          Expanded(
            child: Obx(() {
              if (controller.reminders.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.reminders.length,
                itemBuilder: (context, index) {
                  final reminder = controller.reminders[index];
                  return Column(
                    children: [
                      _buildReminderTile(reminder, index, context),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70, // Adjust size as needed
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => AddReminderScreen());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          // Pressed elevation
          splashColor: Colors.transparent,
          // Removes ripple effect
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Adjust for rounded shape
            child: Image.asset('assets/images/ic_to_do.webp'),
          ),
        ),
      ),
    );
  }

  // Empty State UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/ic_reminder.webp',
            height: 140,
          ),
          SizedBox(height: 10),
          Text(
            'No reminders found!',
            style: AppTextStyle.mediumBlack18
                .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Text('Click “+” to create a new reminder',
              style: AppTextStyle.regularBlack16),
        ],
      ),
    );
  }

  // Reminder Tile UI
  Widget _buildReminderTile(
      ReminderModel reminder, int index, BuildContext context) {
    // Calculate the countdown timer (example logic)
    Duration timeRemaining =
        controller.countdowns[reminder.id] ?? Duration.zero;
    return reminder.reminderType == "interval"
        ? Container(
            padding: EdgeInsets.only(left: 16, bottom: 10, top: 10),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Countdown Timer
                    Obx(() {
                      Duration? timeRemaining =
                          controller.countdowns[reminder.id];
                      if (timeRemaining == null) {
                        return Text(
                          "Calculating...",
                          style: AppTextStyle.regularBlack14
                              .copyWith(color: Color(0xffCCCCCC)),
                        );
                      }

                      String timeString;
                      if (timeRemaining.inSeconds <= 0) {
                        timeString = "Time is up!";
                      } else {
                        int hours = timeRemaining.inHours;
                        int minutes = timeRemaining.inMinutes.remainder(60);
                        int seconds = timeRemaining.inSeconds.remainder(60);
                        timeString = '${hours}h ${minutes}m ${seconds}s';
                      }
                      return Text(
                        timeString,
                        style: AppTextStyle.regularBlack14.copyWith(
                          color: timeRemaining.inSeconds <= 0
                              ? Colors.red
                              : Color(0xffCCCCCC),
                        ),
                      );
                    }),
                    SizedBox(height: 5),
                    // Reminder Title
                    SizedBox(
                      width: Get.width * 0.7,
                      child: Text(
                        reminder.name,
                        style: AppTextStyle.mediumBlack16.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 21),
                      ),
                    ),
                    SizedBox(height: 5),
                    // Reminder Details (Days and Time)
                    Row(
                      children: [
                        reminder.isRepeating == true
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                    color: Color(int.parse(reminder.color
                                            .replaceFirst('#', '0xff')))
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(66)),
                                child: Icon(
                                  Icons.repeat_rounded,
                                  color: Color(int.parse(reminder.color
                                      .replaceFirst('#', '0xff'))),
                                  size: 12,
                                ),
                              )
                            : SizedBox.shrink(),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                    reminder.color.replaceFirst('#', '0xff')))
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(66),
                          ),
                          child: Text(
                            '${reminder.intervalHours > 0 ? '${reminder.intervalHours}hours ' : ''}'
                            '${reminder.intervalMinutes > 0 ? '${reminder.intervalMinutes} minutes' : ''}',
                            style: AppTextStyle.regularBlack12.copyWith(
                              color: Color(int.parse(
                                reminder.color.replaceFirst('#', '0xff'),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: Colors.white,
                      // Set background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Apply border radius
                      ),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_horiz, color: Color(0xffAFAFAF),size: 30,),
                    onSelected: (value) async {
                      if (value == "Complete") {
                        controller.completeReminder(reminder.id);
                      } else if (value == "Delete") {
                        bool? shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return Container(
                              child: AlertDialog(
                                backgroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text(
                                  "Delete Reminder",
                                  style: AppTextStyle.mediumBlack18,
                                ),
                                content: Text(
                                  "Are you sure you want to delete this reminder?",
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
                                        minimumSize:
                                        Size(100, 40),
                                        elevation:
                                        0
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
                                        minimumSize:
                                        Size(100, 40),
                                        elevation:
                                        0
                                    ),
                                    child: Text(
                                      "Yes",
                                      style:
                                          AppTextStyle.mediumBlack14.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          controller.deleteReminder(reminder.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "Complete",
                        child: Text(
                          "Complete",
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
          )
        : reminder.reminderType == "date_time"
            ? Container(
                padding: EdgeInsets.only(left: 16, bottom: 10, top: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Countdown Timer
                        Obx(() {
                          Duration? timeRemaining =
                              controller.countdowns[reminder.id];
                          if (timeRemaining == null) {
                            return Text(
                              "Calculating...",
                              style: AppTextStyle.regularBlack14
                                  .copyWith(color: Color(0xffCCCCCC)),
                            );
                          }

                          String timeString;
                          if (timeRemaining.inSeconds <= 0) {
                            timeString = "Time is up!";
                          } else {
                            int hours = timeRemaining.inHours;
                            int minutes = timeRemaining.inMinutes.remainder(60);
                            int seconds = timeRemaining.inSeconds.remainder(60);
                            timeString = '${hours}h ${minutes}m ${seconds}s';
                          }
                          return Text(
                            timeString,
                            style: AppTextStyle.regularBlack14.copyWith(
                              color: timeRemaining.inSeconds <= 0
                                  ? Colors.red
                                  : Color(0xffCCCCCC),
                            ),
                          );
                        }),
                        SizedBox(height: 5),
                        // Reminder Title
                        SizedBox(
                          width: Get.width * 0.7,
                          child: Text(
                            reminder.name,
                            style: AppTextStyle.mediumBlack16.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 21),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Reminder Details (Days and Time)
                        Row(
                          children: [
                            reminder.isRepeating == true
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    decoration: BoxDecoration(
                                        color: Color(int.parse(reminder.color
                                                .replaceFirst('#', '0xff')))
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(66)),
                                    child: Icon(
                                      Icons.repeat_rounded,
                                      color: Color(int.parse(reminder.color
                                          .replaceFirst('#', '0xff'))),
                                      size: 12,
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color(int.parse(reminder.color
                                        .replaceFirst('#', '0xff')))
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(66),
                              ),
                              child: Text(
                                DateFormat('EEE, MMM d')
                                    .format(reminder.dateTime!),
                                style: AppTextStyle.regularBlack12.copyWith(
                                  color: Color(int.parse(reminder.color
                                      .replaceFirst('#', '0xff'))),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color(int.parse(reminder.color
                                        .replaceFirst('#', '0xff')))
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(66),
                              ),
                              child: Text(
                                DateFormat('h:mm a').format(reminder.dateTime!),
                                style: AppTextStyle.regularBlack12.copyWith(
                                  color: Color(int.parse(reminder.color
                                      .replaceFirst('#', '0xff'))),
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
                          // Set background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Apply border radius
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_horiz, color: Color(0xffAFAFAF),size: 30,),
                        onSelected: (value) async {
                          if (value == "Complete") {
                            controller.completeReminder(reminder.id);
                          } else if (value == "Delete") {
                            bool? shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return Container(
                                  child: AlertDialog(
                                    backgroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    title: Text(
                                      "Delete Reminder",
                                      style: AppTextStyle.mediumBlack18,
                                    ),
                                    content: Text(
                                      "Are you sure you want to delete this reminder?",
                                      style: AppTextStyle.regularBlack14,
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
                                          backgroundColor: Color(0xffF0F0F0),
                                            minimumSize:
                                            Size(100, 40),
                                            elevation:
                                            0
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: AppColors.primary,
                                            minimumSize:
                                            Size(100, 40),
                                            elevation:
                                            0
                                        ),
                                        child: Text(
                                          "Yes",
                                          style: AppTextStyle.mediumBlack14
                                              .copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (shouldDelete == true) {
                              controller.deleteReminder(reminder.id);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "Complete",
                            child: Text(
                              "Complete",
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
              )
            : reminder.reminderType == "weekday"
                ? Container(
                    padding: EdgeInsets.only(left: 16, bottom: 10, top: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Countdown Timer
                            Obx(() {
                              Duration? timeRemaining =
                                  controller.countdowns[reminder.id];
                              if (timeRemaining == null) {
                                return Text(
                                  "Calculating...",
                                  style: AppTextStyle.regularBlack14
                                      .copyWith(color: Color(0xffCCCCCC)),
                                );
                              }

                              String timeString;
                              if (timeRemaining.inSeconds <= 0) {
                                timeString = "Time is up!";
                              } else {
                                int hours = timeRemaining.inHours;
                                int minutes =
                                    timeRemaining.inMinutes.remainder(60);
                                int seconds =
                                    timeRemaining.inSeconds.remainder(60);
                                timeString =
                                    '${hours}h ${minutes}m ${seconds}s';
                              }
                              return Text(
                                timeString,
                                style: AppTextStyle.regularBlack14.copyWith(
                                  color: timeRemaining.inSeconds <= 0
                                      ? Colors.red
                                      : Color(0xffCCCCCC),
                                ),
                              );
                            }),
                            SizedBox(height: 5),
                            // Reminder Title
                            SizedBox(
                              width: Get.width * 0.7,
                              child: Text(
                                reminder.name,
                                style: AppTextStyle.mediumBlack16.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 21),
                              ),
                            ),
                            SizedBox(height: 5),
                            // Reminder Details (Days and Time)
                            Row(
                              children: [
                                reminder.isRepeating == true
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 12),
                                        decoration: BoxDecoration(
                                            color: Color(int.parse(reminder
                                                    .color
                                                    .replaceFirst('#', '0xff')))
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(66)),
                                        child: Icon(
                                          Icons.repeat_rounded,
                                          color: Color(int.parse(reminder.color
                                              .replaceFirst('#', '0xff'))),
                                          size: 12,
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(reminder.color
                                            .replaceFirst('#', '0xff')))
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(66),
                                  ),
                                  child: Text(
                                    '${reminder.weekdays.map((d) => _getWeekdayName(d)).join(", ")}',
                                    style: AppTextStyle.regularBlack12.copyWith(
                                      color: Color(int.parse(reminder.color
                                          .replaceFirst('#', '0xff'))),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(reminder.color
                                            .replaceFirst('#', '0xff')))
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(66),
                                  ),
                                  child: Text(
                                    DateFormat('h:mm a')
                                        .format(reminder.dateTime!),
                                    style: AppTextStyle.regularBlack12.copyWith(
                                      color: Color(int.parse(reminder.color
                                          .replaceFirst('#', '0xff'))),
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
                              // Set background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Apply border radius
                              ),
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_horiz,
                                color: Color(0xffAFAFAF),size: 30,),
                            onSelected: (value) async {
                              if (value == "Complete") {
                                controller.completeReminder(reminder.id);
                              } else if (value == "Delete") {
                                bool? shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      child: AlertDialog(
                                        backgroundColor: AppColors.white,
                                        title: Text(
                                          "Delete Reminder",
                                          style: AppTextStyle.mediumBlack18,
                                        ),
                                        content: Text(
                                          "Are you sure you want to delete this reminder?",
                                          style: AppTextStyle.regularBlack14,
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
                                                  Color(0xffF0F0F0),
                                                minimumSize:
                                                Size(100, 40),
                                                elevation:
                                                0
                                            ),
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
                                                minimumSize:
                                                Size(100, 40),
                                                elevation:
                                                0
                                            ),
                                            child: Text(
                                              "Yes",
                                              style: AppTextStyle.mediumBlack14
                                                  .copyWith(
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                if (shouldDelete == true) {
                                  controller.deleteReminder(reminder.id);
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: "Complete",
                                child: Text(
                                  "Complete",
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
                  )
                : SizedBox.shrink();
  }

  // Get Subtitle Based on Reminder Type
  String _getReminderSubtitle(ReminderModel reminder) {
    if (reminder.reminderType == 'interval') {
      return 'Repeats every ${reminder.intervalMinutes} minutes';
    } else if (reminder.reminderType == 'date_time') {
      // Store date and time separately
      String formattedDate =
          DateFormat('EEE, MMM d').format(reminder.dateTime!);
      String formattedTime = DateFormat('h:mm a').format(reminder.dateTime!);

      // You can use formattedDate and formattedTime separately in your UI
      return 'Scheduled on $formattedDate at $formattedTime';
    } else if (reminder.reminderType == 'weekday') {
      return 'Repeats on ${reminder.weekdays.map((d) => _getWeekdayName(d)).join(", ")} at ${DateFormat('h:mm a').format(reminder.dateTime!)}';
    }
    return '';
  }

  // Convert Weekday Number to Name
  String _getWeekdayName(int dayIndex) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayIndex];
  }

  Duration _calculateTimeRemaining(ReminderModel reminder) {
    if (reminder.reminderType == 'date_time' && reminder.dateTime != null) {
      return reminder.dateTime!.difference(DateTime.now());
    } else if (reminder.reminderType == 'interval') {
      int totalMinutes =
          (reminder.intervalHours * 60) + reminder.intervalMinutes;
      DateTime nextReminderTime =
          DateTime.now().add(Duration(minutes: totalMinutes));
      return nextReminderTime.difference(DateTime.now());
    } else if (reminder.reminderType == 'weekday') {
      DateTime nextWeekday = _getNextWeekday(reminder.weekdays.first);
      return nextWeekday.difference(DateTime.now());
    }
    return Duration.zero;
  }

  DateTime _getNextWeekday(int day) {
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    int daysUntilNext = (day - currentDay + 7) % 7;
    return now.add(Duration(days: daysUntilNext));
  }
}
