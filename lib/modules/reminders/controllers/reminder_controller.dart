import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/custom_flash_bar.dart';
import '../models/reminder_model.dart';

class ReminderController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late Box<ReminderModel> reminderBox;
  late Box<ReminderModel> completedBox;
  final triggeredNotifications =
      <String, bool>{}.obs; // Tracks if notification was triggered
  var reminders = <ReminderModel>[].obs;

  void loadReminders() {
    reminders.value = reminderBox.values.toList();
  }

  var completedReminders = <ReminderModel>[].obs;
  RxInt intervalHours = 5.obs;
  RxBool isRepeating = false.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  Rx<DateTime?> selectedTime = Rx<DateTime?>(DateTime.now());

  // Remove the old selectedDateTime
  // Rx<DateTime?> selectedDateTime = Rx<DateTime?>(DateTime.now());

  // Update the displayed strings to use the separate variables
  RxString selectedDateStr = DateFormat('EEE, MMM d').format(DateTime.now()).obs;
  RxString selectedTimeStr = DateFormat('hh:mm a').format(DateTime.now()).obs;

  void loadCompletedReminders() {
    completedReminders.value = completedBox.values.toList();
  }

  var selectedMinutes = 1.obs;
  var isMinutesSelected = true.obs;
  RxBool isInterval = false.obs;
  RxBool isDateTime = false.obs;
  RxBool isWeekday = false.obs;
  RxString selectedColor = '#2ECC71'.obs;
  RxString reminderName = ''.obs;
  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(DateTime.now());

  RxList<bool> selectedWeekdays = List.generate(7, (index) => false).obs;
  RxInt intervalMinutes = 0.obs;
  final countdowns = <String, Duration>{}.obs;
  final nextTriggerTimes = <String, DateTime>{}.obs;
  Timer? _timer;

  void toggleInterval() {
    isInterval.value = !isInterval.value;
    if (isInterval.value) {
      isDateTime.value = false;
      isWeekday.value = false;
    }
  }

  void toggleDateTime() {
    isDateTime.value = !isDateTime.value;
    if (isDateTime.value) {
      isInterval.value = false;
      isWeekday.value = false;
    }
  }

  void toggleWeek() {
    isWeekday.value = !isWeekday.value;
    if (isWeekday.value) {
      isInterval.value = false;
      isDateTime.value = false;
    }
  }

  void resetForm() {
    reminderName.value = '';
    isInterval.value = false;
    isDateTime.value = false;
    isWeekday.value = false;
    selectedDate.value = DateTime.now();
    selectedTime.value = DateTime.now();
    selectedWeekdays.value = List.generate(7, (index) => false);
    intervalMinutes.value = 0;
    selectedDateStr.value = DateFormat('EEE, MMM d').format(DateTime.now());
    selectedTimeStr.value = DateFormat('hh:mm a').format(DateTime.now());
  }

  void deleteReminder(String id,BuildContext context) {
    final reminder =
        reminderBox.values.firstWhere((element) => element.id == id);
    reminder.delete();
    loadReminders();
    countdowns.remove(id);
    nextTriggerTimes.remove(id);
    triggeredNotifications.remove(id);
    CustomFlashBar.show(
      context: context,
      message: "Reminder deleted successfully",
      isAdmin: true, // optional
      isShaking: false, // optional
      primaryColor: AppColors.primary, // optional
      secondaryColor: Colors.white, // optional
    );
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

  void saveReminder(BuildContext context) {
    if (reminderName.value.isEmpty) {
      CustomFlashBar.show(
        context: context,
        message: "enter a reminder name",
        isAdmin: true, // optional
        isShaking: false, // optional
        primaryColor: AppColors.primary, // optional
        secondaryColor: Colors.white, // optional
      );
      return;
    }

    String reminderType;
    DateTime? dateTime;
    List<int> weekdays = [];
    int intervalMinutes = 0;
    int intervalHours = 0;

    if (isInterval.value) {
      reminderType = 'interval';
      if (isMinutesSelected.value) {
        intervalMinutes = selectedMinutes.value;
      } else {
        intervalHours = selectedMinutes.value;
      }
    } else if (isDateTime.value) {
      reminderType = 'date_time';
      // Combine date and time when saving
      dateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );
    } else if (isWeekday.value) {
      reminderType = 'weekday';
      weekdays = selectedWeekdays
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      // Combine date and time for weekday reminder
      dateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );
    } else {
      CustomFlashBar.show(
        context: context,
        message: "Select a reminder type",
        isAdmin: true, // optional
        isShaking: false, // optional
        primaryColor: AppColors.primary, // optional
        secondaryColor: Colors.white, // optional
      );
      return;
    }

    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: reminderName.value,
      reminderType: reminderType,
      dateTime: dateTime,
      weekdays: weekdays,
      intervalMinutes: intervalMinutes,
      intervalHours: intervalHours,
      isRepeating: isRepeating.value,
      color: selectedColor.value,
      createdAt: DateTime.now(),
    );

    if (!reminder.isValid()) {
      // Get.snackbar('Error', 'Invalid reminder configuration');
      return;
    }

    try {
      reminderBox.add(reminder);
      loadReminders();
      scheduleNotification(reminder);
      CustomFlashBar.show(
        context: context,
        message: "Reminder saved successfully",
        isAdmin: true, // optional
        isShaking: false, // optional
        primaryColor: AppColors.primary, // optional
        secondaryColor: Colors.white, // optional
      );

      resetForm();
      Get.back();
    } catch (e) {
      print('Error saving reminder: $e');

    }
  }

  void toggleWeekday(int index) {
    selectedWeekdays[index] = !selectedWeekdays[index];
  }

  Future<void> triggerNotification(ReminderModel reminder) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails details = NotificationDetails(android: androidDetails);

    print("Triggering notification for ${reminder.name}");
    await flutterLocalNotificationsPlugin.show(
      reminder.id.hashCode,
      reminder.name,
      'Reminder time is up!',
      details,
    );
  }

  Future<void> scheduleNotification(ReminderModel reminder) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails details = NotificationDetails(android: androidDetails);

    DateTime now = DateTime.now();
    updateNextTriggerTime(reminder);
    DateTime? triggerTime = nextTriggerTimes[reminder.id];

    if (triggerTime == null || triggerTime.isBefore(now)) {
      print(
          "Notification for ${reminder.name} not scheduled: triggerTime is $triggerTime, now is $now");
      return;
    }

    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(triggerTime, tz.local);
    print("Scheduling notification for ${reminder.name} at $scheduledTime");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.name,
      'Reminder time is up!',
      scheduledTime,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? granted =
          await androidPlugin.requestNotificationsPermission();
      if (granted == true) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }
    }

    bool? initialized = await flutterLocalNotificationsPlugin
        .initialize(initializationSettings);
    if (initialized == true) {
      print("Notifications initialized successfully");
    } else {
      print("Failed to initialize notifications");
    }
    tz.initializeTimeZones();
  }

  void _initializeNextTriggerTimes() {
    for (var reminder in reminders) {
      updateNextTriggerTime(reminder);
    }
  }

  void resetReminder(ReminderModel reminder) {
    updateNextTriggerTime(reminder);
    triggeredNotifications[reminder.id] = false; // Reset notification trigger
    reminders.refresh();
  }

  DateTime _getNextWeekday(int day) {
    DateTime now = DateTime.now();
    int currentDay = now.weekday % 7; // 1-7, adjust to 0-6
    int daysUntilNext = (day - currentDay + 7) % 7;
    if (daysUntilNext == 0) daysUntilNext = 7; // Ensure it moves forward
    return now.add(Duration(days: daysUntilNext));
  }

  void _startCountdownTimers() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      for (var reminder in reminders) {
        if (!nextTriggerTimes.containsKey(reminder.id)) {
          updateNextTriggerTime(reminder);
        }
        Duration remaining = nextTriggerTimes[reminder.id]!.difference(now);
        countdowns[reminder.id] = remaining;

        if (remaining.inSeconds <= 0) {
          if (triggeredNotifications[reminder.id] != true) {
            triggerNotification(reminder);
            triggeredNotifications[reminder.id] = true;
          }

          if (reminder.isRepeating) {
            updateNextTriggerTime(reminder);
            triggeredNotifications[reminder.id] = false;
            scheduleNotification(reminder);
          }
          // Non-repeating reminders: no further updates, stays at "Time is up!"
        }
      }
      countdowns.refresh();
    });
  }

  void updateNextTriggerTime(ReminderModel reminder) {
    DateTime now = DateTime.now();
    if (reminder.reminderType == 'interval') {
      int totalMinutes =
          (reminder.intervalHours * 60) + reminder.intervalMinutes;
      DateTime initialTriggerTime =
      reminder.createdAt!.add(Duration(minutes: totalMinutes));

      if (!nextTriggerTimes.containsKey(reminder.id)) {
        nextTriggerTimes[reminder.id] = initialTriggerTime;
      } else if (reminder.isRepeating) {
        DateTime currentTriggerTime = nextTriggerTimes[reminder.id]!;
        while (currentTriggerTime.isBefore(now)) {
          currentTriggerTime =
              currentTriggerTime.add(Duration(minutes: totalMinutes));
        }
        nextTriggerTimes[reminder.id] = currentTriggerTime;
      }
    } else if (reminder.reminderType == 'weekday') {
      nextTriggerTimes[reminder.id] = _getNextWeekdayTime(reminder);
    } else if (reminder.reminderType == 'date_time') {
      if (reminder.dateTime!.isAfter(now)) {
        nextTriggerTimes[reminder.id] = reminder.dateTime!;
      } else if (reminder.isRepeating) {
        DateTime nextTime = reminder.dateTime!;
        while (nextTime.isBefore(now)) {
          nextTime = nextTime.add(Duration(days: 1));
        }
        nextTriggerTimes[reminder.id] = nextTime;
      } else {
        nextTriggerTimes[reminder.id] = reminder.dateTime!;
      }
    }
  }

  DateTime _getNextWeekdayTime(ReminderModel reminder) {
    DateTime now = DateTime.now();
    DateTime nextTime = now;
    int targetHour = reminder.dateTime!.hour;
    int targetMinute = reminder.dateTime!.minute;

    for (int i = 0; i < 7; i++) {
      int checkDay = (now.weekday + i - 1) % 7;
      if (reminder.weekdays.contains(checkDay)) {
        DateTime candidate = DateTime(
          now.year,
          now.month,
          now.day,
          targetHour,
          targetMinute,
        ).add(Duration(days: i));
        if (candidate.isAfter(now)) {
          nextTime = candidate;
          break;
        }
      }
    }
    return nextTime;
  }

  void completeReminder(String id,BuildContext context) {
    try {
      final reminder =
          reminderBox.values.firstWhere((element) => element.id == id);
      final completedReminder = ReminderModel(
        id: reminder.id,
        name: reminder.name,
        reminderType: reminder.reminderType,
        dateTime: reminder.dateTime,
        weekdays: List.from(reminder.weekdays),
        intervalMinutes: reminder.intervalMinutes,
        intervalHours: reminder.intervalHours,
        isRepeating: reminder.isRepeating,
        color: reminder.color,
        completedAt: DateTime.now(),
        createdAt: reminder.createdAt,
      );

      completedBox.add(completedReminder);
      reminder.delete();
      loadReminders();
      loadCompletedReminders();
      countdowns.remove(id);
      nextTriggerTimes.remove(id);
      triggeredNotifications.remove(id);
      CustomFlashBar.show(
        context: context,
        message: "Reminder marked as completed",
        isAdmin: true, // optional
        isShaking: false, // optional
        primaryColor: AppColors.primary, // optional
        secondaryColor: Colors.white, // optional
      );

    } catch (e) {
      print('Error completing reminder: $e');
      Get.snackbar('Error', 'Failed to complete reminder');
    }
  }

  void scheduleBackgroundTask() {
    Workmanager().registerPeriodicTask(
      "reminderTask",
      "checkReminders",
      frequency: Duration(minutes: 1),
      initialDelay: Duration(seconds: 10),
    );
  }

  @override
  void onInit() async {
    super.onInit();
    reminderBox = Hive.box('reminders');
    completedBox = Hive.box('completed_reminders');
    loadReminders();
    loadCompletedReminders();
    await initNotifications();
    _initializeNextTriggerTimes();
    _startCountdownTimers();
    scheduleBackgroundTask();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
