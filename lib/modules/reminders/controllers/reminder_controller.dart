import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_text_style.dart'; // Assuming this exists
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../utils/app_colors.dart';
import '../models/reminder_model.dart';

class ReminderController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late Box<ReminderModel> reminderBox;
  late Box<ReminderModel> completedBox;
  final triggeredNotifications = <String, bool>{}.obs; // Tracks if notification was triggered
  var reminders = <ReminderModel>[].obs;

  void loadReminders() {
    reminders.value = reminderBox.values.toList();
  }

  var completedReminders = <ReminderModel>[].obs;
  RxInt intervalHours = 5.obs;
  RxBool isRepeating = false.obs;
  RxString selectedDate = DateFormat('EEE, MMM d').format(DateTime.now()).obs;
  RxString selectedTime = DateFormat('hh:mm a').format(DateTime.now()).obs;

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
  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
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
    selectedDateTime.value = null;
    selectedWeekdays.value = List.generate(7, (index) => false);
    intervalMinutes.value = 0;
  }

  void deleteReminder(String id) {
    final reminder = reminderBox.values.firstWhere((element) => element.id == id);
    reminder.delete();
    loadReminders();
    countdowns.remove(id);
    nextTriggerTimes.remove(id);
    triggeredNotifications.remove(id);
    Get.snackbar('Success', 'Reminder deleted successfully');
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime selected = selectedDateTime.value ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Optional: Customize the date picker theme
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white,
          ),

          child: child!,
        );
      },
    );

    if (picked != null && picked != selected) {
      selectedDateTime.value = picked;
      selectedDate.value = DateFormat('EEE, MMM d').format(picked);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    DateTime selected = selectedDateTime.value ?? DateTime.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selected),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Customize the time picker theme
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newTime = DateTime(
        selected.year,
        selected.month,
        selected.day,
        picked.hour,
        picked.minute,
      );
      selectedDateTime.value = newTime;
      selectedTime.value = DateFormat('hh:mm a').format(newTime);
    }
  }

  void saveReminder() {
    if (reminderName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a reminder name');
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
      dateTime = selectedDateTime.value;
    } else if (isWeekday.value) {
      reminderType = 'weekday';
      weekdays = selectedWeekdays.asMap().entries.where((entry) => entry.value).map((entry) => entry.key).toList();
      dateTime = selectedDateTime.value;
    } else {
      Get.snackbar('Error', 'Please select a reminder type');
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
      Get.snackbar('Error', 'Invalid reminder configuration');
      return;
    }

    try {
      reminderBox.add(reminder);
      loadReminders();
      scheduleNotification(reminder);
      Get.snackbar('Success', 'Reminder saved successfully');
      resetForm();
      Get.back();
    } catch (e) {
      print('Error saving reminder: $e');
      Get.snackbar('Error', 'Failed to save reminder');
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
      print("Notification for ${reminder.name} not scheduled: triggerTime is $triggerTime, now is $now");
      return;
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(triggerTime, tz.local);
    print("Scheduling notification for ${reminder.name} at $scheduledTime");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.name,
      'Reminder time is up!',
      scheduledTime,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      if (granted == true) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }
    }

    bool? initialized = await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
      int totalMinutes = (reminder.intervalHours * 60) + reminder.intervalMinutes;
      DateTime initialTriggerTime = reminder.createdAt!.add(Duration(minutes: totalMinutes));

      if (!nextTriggerTimes.containsKey(reminder.id)) {
        // Set initial trigger time when reminder is first added
        nextTriggerTimes[reminder.id] = initialTriggerTime;
      } else if (reminder.isRepeating) {
        // For repeating reminders, update to next interval
        DateTime currentTriggerTime = nextTriggerTimes[reminder.id]!;
        while (currentTriggerTime.isBefore(now)) {
          currentTriggerTime = currentTriggerTime.add(Duration(minutes: totalMinutes));
        }
        nextTriggerTimes[reminder.id] = currentTriggerTime;
      }
      // Non-repeating: Do nothing if time is up, keep initialTriggerTime
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

  void completeReminder(String id) {
    try {
      final reminder = reminderBox.values.firstWhere((element) => element.id == id);
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
      Get.snackbar('Success', 'Reminder marked as completed');
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