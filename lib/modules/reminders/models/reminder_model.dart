import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 2)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String reminderType; // 'interval', 'date_time', or 'weekday'

  @HiveField(3)
  DateTime? dateTime; // For date & time reminders

  @HiveField(4)
  List<int> weekdays; // Store selected weekdays as [0-6] (Monday = 0)

  @HiveField(5)
  int intervalMinutes; // Minutes for interval-based reminders

  @HiveField(6)
  int intervalHours; // Hours for interval-based reminders

  @HiveField(7)
  bool isRepeating; // Whether the reminder repeats

  @HiveField(8)
  String color; // Reminder color

  @HiveField(9)
  DateTime? completedAt; // Timestamp when the reminder was completed

  ReminderModel({
    required this.id,
    required this.name,
    required this.reminderType,
    this.dateTime,
    this.weekdays = const [],
    this.intervalMinutes = 0,
    this.intervalHours = 0,
    this.isRepeating = false,
    required this.color,
    this.completedAt,
  });

  // Ensure only one type of reminder is active
  bool isValid() {
    if (reminderType == 'interval') {
      return (intervalMinutes > 0 || intervalHours > 0) && dateTime == null && weekdays.isEmpty;
    } else if (reminderType == 'date_time') {
      return dateTime != null && intervalMinutes == 0 && intervalHours == 0 && weekdays.isEmpty;
    } else if (reminderType == 'weekday') {
      return weekdays.isNotEmpty && intervalMinutes == 0 && intervalHours == 0 && dateTime != null;
    }
    return false;
  }
}