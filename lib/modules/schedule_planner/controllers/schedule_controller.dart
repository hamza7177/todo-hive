import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/custom_flash_bar.dart';
import '../models/schedule_model.dart';

class ScheduleController extends GetxController {
  RxString selectedColor = '#2ECC71'.obs;
  RxBool isReminder = false.obs;
  var selectedCategory = "".obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  Rx<DateTime?> selectedTime = Rx<DateTime?>(DateTime.now());
  RxString selectedDateStr = DateFormat('EEE, MMM d').format(DateTime.now()).obs;
  RxString selectedTimeStr = DateFormat('hh:mm a').format(DateTime.now()).obs;
  var selectedFilter = "All".obs;

  var selectedPriority = "Low".obs;
  RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;
  RxList<ScheduleModel> completedSchedules = <ScheduleModel>[].obs;
  late Box<ScheduleModel> scheduleBox;
  late Box<ScheduleModel> completedScheduleBox;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _cleanupTimer; // Timer for periodic cleanup

  @override
  void onInit() async {
    super.onInit();
    scheduleBox = await Hive.openBox<ScheduleModel>('schedules');
    completedScheduleBox = Hive.box<ScheduleModel>('completedSchedules');
    loadSchedules();
    loadCompletedSchedules();
    await initializeNotifications(Get.context!);
    startCleanupTimer(); // Start the timer for cleanup
  }

  @override
  void onClose() {
    _cleanupTimer?.cancel(); // Cancel the timer when the controller is disposed
    super.onClose();
  }

  void startCleanupTimer() {
    // Check every hour for completed schedules to delete
    _cleanupTimer = Timer.periodic(Duration(hours: 1), (timer) {
      cleanupOldCompletedSchedules();
    });
  }

  void cleanupOldCompletedSchedules() {
    final now = DateTime.now();
    final schedulesToDelete = <int>[]; // Store keys of schedules to delete

    for (var schedule in completedScheduleBox.values) {
      if (schedule.isCompleted && schedule.createdAt != null) {
        final durationSinceCompletion = now.difference(schedule.createdAt);
        if (durationSinceCompletion.inHours >= 24) {
          int? scheduleKey = completedScheduleBox.keys.cast<int?>().firstWhere(
                (key) => completedScheduleBox.get(key) == schedule,
                orElse: () => null,
              );
          if (scheduleKey != null) {
            schedulesToDelete.add(scheduleKey);
          }
        }
      }
    }

    // Delete the schedules
    for (var key in schedulesToDelete) {
      completedScheduleBox.delete(key);
    }

    loadCompletedSchedules(); // Refresh the completed schedules list
  }

  Future<void> initializeNotifications(BuildContext context) async {
    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name;
    print('Current time zone: $timeZoneName');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions for Android
    if (GetPlatform.isAndroid) {
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      bool? grantedNotifications =
          await androidPlugin?.requestNotificationsPermission();
      bool? grantedExactAlarms =
          await androidPlugin?.requestExactAlarmsPermission();

      print('Notification permission granted: $grantedNotifications');
      print('Exact alarm permission granted: $grantedExactAlarms');

      if (grantedNotifications != true || grantedExactAlarms != true) {
        CustomFlashBar.show(
          context: context,
          message: "Please grant notification permission",
          isAdmin: true, // optional
          isShaking: false, // optional
          primaryColor: AppColors.primary, // optional
          secondaryColor: Colors.white, // optional
        );

      }
    }
  }

  void loadSchedules() {
    schedules.value = scheduleBox.values.toList();
  }

  void loadCompletedSchedules() {
    completedSchedules.value = completedScheduleBox.values.toList();
  }

  void completeSchedule(int index) {
    final schedule = scheduleBox.getAt(index);
    if (schedule != null) {
      // Create a new instance for completedBox instead of reusing the same object
      final completedSchedule = ScheduleModel(
        title: schedule.title,
        color: schedule.color,
        description: schedule.description,
        priority: schedule.priority,
        isReminder: schedule.isReminder,
        dateTime: schedule.dateTime,
        category: schedule.category,
        createdAt: DateTime.now(),
        // Use current time as completion time
        id: _generateValidId(),
        // Generate a new valid ID
        isCompleted: true,
      );

      completedScheduleBox
          .add(completedSchedule); // Add new instance to completed box
      scheduleBox.deleteAt(index); // Remove from incomplete box

      if (schedule.isReminder) {
        flutterLocalNotificationsPlugin.cancel(schedule.id);
        print(
            'Notification cancelled for completed schedule ID: ${schedule.id}');
      }
      loadSchedules();
      loadCompletedSchedules();
    }
  }

  void deleteSchedule(int index, {bool fromCompleted = false}) {
    if (fromCompleted) {
      final schedule = completedScheduleBox.getAt(index);
      if (schedule != null && schedule.isReminder) {
        flutterLocalNotificationsPlugin.cancel(schedule.id);
        print(
            'Notification cancelled for deleted completed schedule ID: ${schedule.id}');
      }
      completedScheduleBox.deleteAt(index);
      loadCompletedSchedules();
    } else {
      final schedule = scheduleBox.getAt(index);
      if (schedule != null && schedule.isReminder) {
        flutterLocalNotificationsPlugin.cancel(schedule.id);
        print('Notification cancelled for deleted schedule ID: ${schedule.id}');
      }
      scheduleBox.deleteAt(index);
      loadSchedules();
    }
  }

  int _generateValidId() {
    // Generate a 32-bit compatible ID using a simple counter or truncated timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    return now % 2147483647; // Ensure it fits within 32-bit integer range
  }

  void addSchedule({
    required String title,
    required String description,
  }) {
    // Combine date and time when creating the schedule
    final combinedDateTime = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      selectedTime.value!.hour,
      selectedTime.value!.minute,
    );

    final schedule = ScheduleModel(
      title: title,
      color: selectedColor.value,
      description: description,
      priority: selectedPriority.value,
      isReminder: isReminder.value,
      dateTime: combinedDateTime,
      category: selectedCategory.value,
      createdAt: DateTime.now(),
      id: _generateValidId(),
      isCompleted: false,
    );

    scheduleBox.add(schedule);
    if (schedule.isReminder) {
      scheduleNotification(schedule);
    }
    loadSchedules();
    resetSelections();
  }

  Future<void> scheduleNotification(ScheduleModel schedule) async {
    final now = DateTime.now();
    if (schedule.dateTime.isBefore(now)) {
      print('Cannot schedule notification for past time: ${schedule.dateTime}');
      return;
    }

    final tzDateTime = tz.TZDateTime.from(schedule.dateTime, tz.local);
    print(
        'Scheduling notification for: $tzDateTime (Local time: ${schedule.dateTime})');

    await flutterLocalNotificationsPlugin
        .zonedSchedule(
      schedule.id,
      schedule.title,
      schedule.description,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel',
          'Schedule Notifications',
          channelDescription: 'Notifications for scheduled tasks',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    )
        .then((_) {
      print(
          'Notification scheduled successfully for ID: ${schedule.id} at $tzDateTime');
    }).catchError((error) {
      print('Error scheduling notification: $error');
    });
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setPriority(String priority) {
    selectedPriority.value = priority;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime initialDate = selectedDate.value ?? DateTime.now();

    final DateTime? picked = await showRoundedDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      theme: ThemeData(
        primaryColor: AppColors.primary,
      ),
      height: MediaQuery.of(context).size.height * 0.4,
      styleDatePicker: MaterialRoundedDatePickerStyle(
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
      ),
    );

    if (picked != null && picked != initialDate) {
      selectedDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        selectedTime.value?.hour ?? 0,
        selectedTime.value?.minute ?? 0,
      );
      selectedDateStr.value = DateFormat('EEE, MMM d').format(picked);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    DateTime initialTime = selectedTime.value ?? DateTime.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(200, 300),
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteColor: WidgetStateColor.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : Colors.white,
                ),
                hourMinuteTextColor: WidgetStateColor.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                      ? AppColors.white
                      : AppColors.primary,
                ),
                dialHandColor: AppColors.primary,
                dialBackgroundColor: Colors.white,
                dialTextColor: WidgetStateColor.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black,
                ),
                entryModeIconColor: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: WidgetStateColor.resolveWith(
                        (states) => Colors.white,
                  ),
                  foregroundColor: WidgetStateColor.resolveWith(
                        (states) => AppColors.primary,
                  ),
                  overlayColor: WidgetStateColor.resolveWith(
                        (states) => AppColors.primary,
                  ),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      selectedTime.value = DateTime(
        selectedDate.value?.year ?? DateTime.now().year,
        selectedDate.value?.month ?? DateTime.now().month,
        selectedDate.value?.day ?? DateTime.now().day,
        picked.hour,
        picked.minute,
      );
      selectedTimeStr.value = DateFormat('hh:mm a').format(selectedTime.value!);
    }
  }

  void resetSelections() {
    selectedColor.value = '#2ECC71';
    isReminder.value = false;
    selectedCategory.value = "";
    selectedDate.value = DateTime.now();
    selectedTime.value = DateTime.now();
    selectedDateStr.value = DateFormat('EEE, MMM d').format(DateTime.now());
    selectedTimeStr.value = DateFormat('hh:mm a').format(DateTime.now());
    selectedPriority.value = "Low";
  }
}
