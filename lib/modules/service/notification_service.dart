import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../reminders/models/reminder_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> scheduleNotification(ReminderModel reminder) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id', // Channel ID
    'your_channel_name', // Channel Name
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  if (reminder.reminderType == 'interval') {
    // Schedule a repeating notification based on the interval
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0, // Notification ID
      reminder.name, // Title
      'Reminder: ${reminder.name}', // Body
      RepeatInterval.everyMinute, // Repeat interval
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required for Android// Notification details
      payload: 'interval', // Payload
    );
  } else if (reminder.reminderType == 'date_time') {
    // Schedule a one-time notification for the specific date and time
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      reminder.name, // Title
      'Reminder: ${reminder.name}', // Body
      tz.TZDateTime.from(reminder.dateTime!, tz.local), // Scheduled time
      platformChannelSpecifics, // Notification details
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required for Android
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'date_time', // Payload
    );
  } else if (reminder.reminderType == 'weekday') {
    // Schedule notifications for each selected weekday
    for (int day in reminder.weekdays) {
      // Calculate the next occurrence of the selected weekday
      DateTime nextWeekday = _getNextWeekday(day);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        day, // Notification ID (use weekday index as ID)
        reminder.name, // Title
        'Reminder: ${reminder.name}', // Body
        tz.TZDateTime.from(nextWeekday, tz.local), // Scheduled time
        platformChannelSpecifics, // Notification details
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required for Android
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'weekday', // Payload
      );
    }
  }
}

DateTime _getNextWeekday(int day) {
  DateTime now = DateTime.now();
  int currentDay = now.weekday;
  int daysUntilNext = (day - currentDay + 7) % 7;
  return now.add(Duration(days: daysUntilNext));
}