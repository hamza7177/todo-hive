import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ManageProjectController extends GetxController{
  var selectedFilter = "All".obs;

  Rx<DateTime?> selectedDateTime = Rx<DateTime?>(null);
  RxString selectedDate = DateFormat('EEE, MMM d').format(DateTime.now()).obs;
  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }


  var selectedPriority = "Low".obs;

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
                  selectedDate.value = DateFormat('EEE, MMM d').format(newDate);
                },
              ),
            ),
            CupertinoButton(
              child: Text('Done'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}