import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_text_style.dart';
import '../models/reminder_model.dart';

class ReminderController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Box<ReminderModel> reminderBox = Hive.box('reminders');
  final Box<ReminderModel> completedBox = Hive.box('completed_reminders');
  final triggeredNotifications = <String, bool>{}.obs;
  var reminders = <ReminderModel>[].obs; // RxList to hold reminders
  void loadReminders() {
    reminders.value = reminderBox.values.toList(); // Convert Hive data to RxList
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
  var isMinutesSelected = true.obs; // Toggle between Minutes & Hours

  RxBool isInterval = false.obs;
  RxBool isDateTime = false.obs;
  RxBool isWeekday = false.obs;
  RxString selectedColor = '#2ECC71'.obs;
  RxString reminderName = ''.obs;
  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  RxList<bool> selectedWeekdays = List.generate(7, (index) => false).obs;
  RxInt intervalMinutes = 0.obs;
  final countdowns = <String, Duration>{}.obs; // Store countdown timers for each reminder
  final nextTriggerTimes = <String, DateTime>{}.obs; // Store next execution times
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
    Get.snackbar('Success', 'Reminder deleted successfully');
    countdowns.remove(id);
    nextTriggerTimes.remove(id);
    triggeredNotifications.remove(id); // Clean up trigger flag
    Get.snackbar('Success', 'Reminder deleted successfully');
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime selected = selectedDateTime.value ?? DateTime.now();

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 190,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selected,
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (DateTime newDate) {
                  selectedDateTime.value = newDate;
                  selectedDate.value = '${newDate.day}/${newDate.month}/${newDate.year}';
                },
              ),
            ),
            CupertinoButton(
              child: Text('Done', style: AppTextStyle.mediumBlack16),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickTime(BuildContext context) async {
    DateTime selected = selectedDateTime.value ?? DateTime.now();

    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 190,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selected,
                onDateTimeChanged: (DateTime newTime) {
                  selectedDateTime.value = newTime;
                  selectedTime.value =
                  '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                },
              ),
            ),
            CupertinoButton(
              child: Text('Done', style: AppTextStyle.mediumPrimary14),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void saveReminder() {
    print('Starting saveReminder');
    if (reminderName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a reminder name');
      print('Empty reminder name, exiting');
      return;
    }

    String reminderType;
    DateTime? dateTime;
    List<int> weekdays = [];
    int intervalMinutes = 0;
    int intervalHours = 0;

    print('Determining reminder type');
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
      weekdays = selectedWeekdays
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      dateTime = selectedDateTime.value;
    } else {
      Get.snackbar('Error', 'Please select a reminder type');
      print('No reminder type selected, exiting');
      return;
    }

    print('Creating ReminderModel');
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
    );

    if (!reminder.isValid()) {
      Get.snackbar('Error', 'Invalid reminder configuration');
      print('Invalid reminder configuration, exiting');
      return;
    }

    try {
      print('Adding reminder to box');
      reminderBox.add(reminder);
      print('Loading reminders');
      loadReminders();
      print('Showing success snackbar');
      Get.snackbar('Success', 'Reminder saved successfully');
      print('Resetting form');
      resetForm();
      print('Attempting to navigate back');
      Get.back();
      print('Navigation back executed');
    } catch (e) {
      print('Error saving reminder: $e');
      Get.snackbar('Error', 'Failed to save reminder');
    }
  }




  // Method to toggle a weekday
  void toggleWeekday(int index) {
    selectedWeekdays[index] = !selectedWeekdays[index];
  }

  void triggerNotification(ReminderModel reminder) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      reminder.id.hashCode,
      reminder.name,
      'Reminder time is up!',
      details,
    );
  }




  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }
  void _initializeNextTriggerTimes() {
    for (var reminder in reminders) {
      if (reminder.reminderType == 'interval') {
        int totalMinutes = (reminder.intervalHours * 60) + reminder.intervalMinutes;
        nextTriggerTimes[reminder.id] = DateTime.now().add(Duration(minutes: totalMinutes));
      } else if (reminder.reminderType == 'weekday') {
        nextTriggerTimes[reminder.id] = _getNextWeekday(reminder.weekdays.first);
      } else {
        nextTriggerTimes[reminder.id] = reminder.dateTime!;
      }
    }
  }





  void resetReminder(ReminderModel reminder) {
    if (reminder.reminderType == 'interval') {
      int totalMinutes = (reminder.intervalHours * 60) + reminder.intervalMinutes;
      nextTriggerTimes[reminder.id] = DateTime.now().add(Duration(minutes: totalMinutes));
    } else if (reminder.reminderType == 'weekday') {
      nextTriggerTimes[reminder.id] = _getNextWeekday(reminder.weekdays.first);
    } else if (reminder.reminderType == 'date_time') {
      nextTriggerTimes[reminder.id] = reminder.dateTime!;
    }
    reminders.refresh(); // Refresh the reminders list to update the UI
  }


  DateTime _getNextWeekday(int day) {
    DateTime now = DateTime.now();
    int currentDay = now.weekday;
    int daysUntilNext = (day - currentDay + 7) % 7;
    return now.add(Duration(days: daysUntilNext));
  }



  void _startCountdownTimers() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      for (var reminder in reminders) {
        if (!nextTriggerTimes.containsKey(reminder.id)) {
          _updateNextTriggerTime(reminder);
          triggeredNotifications[reminder.id] = false; // Reset trigger flag
        }

        if (nextTriggerTimes[reminder.id] != null) {
          Duration remaining = nextTriggerTimes[reminder.id]!.difference(now);
          countdowns[reminder.id] = remaining;

          // Check if timer has reached or passed zero and notification hasn't been triggered yet
          if (remaining.inSeconds <= 0 && !(triggeredNotifications[reminder.id] ?? false)) {
            triggerNotification(reminder);
            triggeredNotifications[reminder.id] = true; // Mark as triggered

            // For repeating reminders, reset the timer
            if (reminder.isRepeating) {
              _updateNextTriggerTime(reminder);
              triggeredNotifications[reminder.id] = false; // Reset for next cycle
            }
          }
        }
      }
      countdowns.refresh(); // Update UI
    });
  }

  void _updateNextTriggerTime(ReminderModel reminder) {
    DateTime now = DateTime.now();
    if (reminder.reminderType == 'interval') {
      int totalMinutes = (reminder.intervalHours * 60) + reminder.intervalMinutes;
      DateTime nextTime = nextTriggerTimes[reminder.id] ?? now;
      // Ensure next time is in the future
      while (nextTime.isBefore(now) || nextTime.isAtSameMomentAs(now)) {
        nextTime = nextTime.add(Duration(minutes: totalMinutes));
      }
      nextTriggerTimes[reminder.id] = nextTime;
    }
    else if (reminder.reminderType == 'weekday') {
      nextTriggerTimes[reminder.id] = _getNextWeekdayTime(reminder);
    }
    else if (reminder.reminderType == 'date_time') {
      if (reminder.dateTime!.isAfter(now)) {
        nextTriggerTimes[reminder.id] = reminder.dateTime!;
      } else if (reminder.isRepeating) {
        DateTime nextTime = nextTriggerTimes[reminder.id] ?? reminder.dateTime!;
        while (nextTime.isBefore(now) || nextTime.isAtSameMomentAs(now)) {
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

    for (int i = 0; i < 7; i++) {
      int checkDay = (now.weekday + i - 1) % 7;
      if (reminder.weekdays.contains(checkDay)) {
        DateTime candidate = DateTime(
          now.year,
          now.month,
          now.day,
          reminder.dateTime!.hour,
          reminder.dateTime!.minute,
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
      // Create a new instance for the completed box
      final completedReminder = ReminderModel(
        id: reminder.id,
        name: reminder.name,
        reminderType: reminder.reminderType,
        dateTime: reminder.dateTime,
        weekdays: List.from(reminder.weekdays), // Create a new list to avoid reference issues
        intervalMinutes: reminder.intervalMinutes,
        intervalHours: reminder.intervalHours,
        isRepeating: reminder.isRepeating,
        color: reminder.color,
        completedAt: DateTime.now(), // Set completion time
      );

      completedBox.add(completedReminder); // Add the new instance to completed box
      reminder.delete(); // Remove from active reminders
      loadReminders();
      loadCompletedReminders();
      completedReminders.refresh(); // Force UI update
      countdowns.remove(id);
      nextTriggerTimes.remove(id);
      triggeredNotifications.remove(id);
      print('Completed reminder added to box: ${completedReminder.name}, Completed at: ${completedReminder.completedAt}');
      print('Completed box size: ${completedBox.length}');
      Get.snackbar('Success', 'Reminder marked as completed');
    } catch (e) {
      print('Error completing reminder: $e');
      Get.snackbar('Error', 'Failed to complete reminder');
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadReminders();
    loadCompletedReminders();
    initNotifications().then((_) {
      _initializeNextTriggerTimes();
      _startCountdownTimers();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}