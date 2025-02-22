import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../models/reminder_model.dart';

class ReminderController extends GetxController {

  final Box<ReminderModel> reminderBox = Hive.box('reminders');


  RxBool isRepeating = false.obs;
  RxString selectedDate = 'Mon, Feb 10'.obs;
  RxString selectedTime = '11:48 PM'.obs;

  var selectedMinutes = 1.obs;
  var isMinutesSelected = true.obs; // Toggle between Minutes & Hours


  void saveIntervalSettings() {
    int intervalValue = selectedMinutes.value;
    String unit = isMinutesSelected.value ? "minutes" : "hours";

    print("Reminder set for $intervalValue $unit");
  }

  void saveDateTimeSettings() {
    // Save date & time settings logic
  }

  void saveWeekdaySettings() {
    // Save weekday settings logic
  }

  void toggleWeekday(int index) {
    selectedWeekdays[index] = !selectedWeekdays[index];
  }
  RxBool isInterval = false.obs;
  RxBool isDateTime = false.obs;
  RxBool isWeekday = false.obs;
  RxString selectedColor = '#2ECC71'.obs;
  RxString reminderName = ''.obs;
  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  RxList<bool> selectedWeekdays = List.generate(7, (index) => false).obs;
  RxInt intervalMinutes = 0.obs;

  void toggleInterval() => isInterval.value = !isInterval.value;
  void toggleDateTime() => isDateTime.value = !isDateTime.value;
  void toggleWeek() => isWeekday.value = !isWeekday.value;

  void saveReminder() {
    if (reminderName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a reminder name');
      return;
    }

    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: reminderName.value,
      isInterval: isInterval.value,
      dateTime: selectedDateTime.value,
      weekdays: selectedWeekdays,
      color: selectedColor.value,
      intervalMinutes: intervalMinutes.value,
    );

    reminderBox.add(reminder);
    resetForm();
    Get.back();
    Get.snackbar('Success', 'Reminder saved successfully');
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

}