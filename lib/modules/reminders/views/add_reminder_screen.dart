import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../controllers/reminder_controller.dart';

class AddReminderScreen extends StatefulWidget {
  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final ReminderController controller = Get.put(ReminderController());
  final List<Color> colors = [
    Color(0xFF17D650),
    Color(0xFFD61817),
    Color(0xFF17D0D6),
    Color(0xffFFA500),
    Color(0xFFDF4BCB),
    Color(0xFFD6D017),
  ];
  final TextEditingController taskController = TextEditingController();
  final FocusNode taskFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Optional: Add listener for debugging focus issues
    taskFocusNode.addListener(() {
      if (taskFocusNode.hasFocus) {
        print("Task TextField gained focus");
      }
    });
  }

  @override
  void dispose() {
    taskFocusNode.dispose();
    taskController.dispose();
    super.dispose();
  }

  // Helper method to dismiss keyboard and prevent blink
  void _dismissKeyboard(BuildContext context) {
    if (taskFocusNode.hasFocus) {
      FocusScope.of(context)
          .requestFocus(FocusNode()); // Shift focus to a dummy node
      Future.delayed(Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus(); // Ensure keyboard stays dismissed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              controller.saveReminder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Center(
              child: Text(
                "Set Reminder",
                style:
                    AppTextStyle.mediumBlack16.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Adding new reminder',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onTap: () => _dismissKeyboard(context),
        // Dismiss keyboard on tap outside
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: taskController,
                // Use controller
                focusNode: taskFocusNode,
                // Attach FocusNode
                decoration: InputDecoration(
                  hintText: "Give a name to reminder",
                  hintStyle: AppTextStyle.regularBlack16
                      .copyWith(color: Color(0xffAFAFAF)),
                  filled: true,
                  fillColor: AppColors.textFieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                minLines: 1,
                maxLines: 3,
                style: AppTextStyle.regularBlack16,
                onChanged: (value) => controller.reminderName.value = value,
              ),
              SizedBox(height: 10),
              _buildSwitchTile('Interval', controller.isInterval, () {
                _dismissKeyboard(context); // Dismiss before interaction
                controller.toggleInterval();
                if (controller.isInterval.value) {
                  _showIntervalBottomSheet(context);
                }
              }),
              SizedBox(height: 10),
              _buildSwitchTile('Date & Time', controller.isDateTime, () {
                _dismissKeyboard(context); // Dismiss before interaction
                controller.toggleDateTime();
                if (controller.isDateTime.value) {
                  _showDateTimeBottomSheet(context);
                }
              }),
              SizedBox(height: 10),
              _buildSwitchTile('Weekday', controller.isWeekday, () {
                _dismissKeyboard(context); // Dismiss before interaction
                controller.toggleWeek();
                if (controller.isWeekday.value) {
                  _showWeekdayBottomSheet(context);
                }
              }),
              SizedBox(height: 20),
              Text(
                'Choose color',
                style: AppTextStyle.mediumBlack16,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    colors.map((color) => _buildColorButton(color)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, RxBool value, VoidCallback onChanged) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.textFieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyle.regularBlack16,
              ),
              CupertinoSwitch(
                value: value.value,
                onChanged: (_) => onChanged(),
                activeColor: Colors.green,
              ),
            ],
          ),
        ));
  }

  Widget _buildColorButton(Color color) {
    return Obx(() {
      bool isSelected =
          controller.selectedColor.value == '#${color.value.toRadixString(16)}';
      return GestureDetector(
        onTap: () => controller.selectedColor.value =
            '#${color.value.toRadixString(16)}',
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: color,
                      size: 12,
                    ),
                  ),
                )
              : null,
        ),
      );
    });
  }

  void _showIntervalBottomSheet(BuildContext context) {
    _dismissKeyboard(context); // Dismiss before showing bottom sheet
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Interval',
              style: AppTextStyle.mediumBlack16
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => SizedBox(
                      width: 80,
                      height: 120,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: controller.selectedMinutes.value - 1,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          controller.selectedMinutes.value = index + 1;
                        },
                        children: List.generate(
                          60,
                          (index) => Center(
                            child: Text(
                              '${index + 1}',
                              style: AppTextStyle.mediumBlack16.copyWith(
                                color: index + 1 ==
                                        controller.selectedMinutes.value
                                    ? AppColors.lightRed
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                SizedBox(width: 10),
                Obx(() => SizedBox(
                      width: 100,
                      height: 120,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem:
                              controller.isMinutesSelected.value ? 0 : 1,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          bool isMinutes = index == 0;
                          controller.isMinutesSelected.value = isMinutes;
                          if (isMinutes) {
                            controller.selectedMinutes.value *= 60;
                          } else {
                            controller.selectedMinutes.value =
                                (controller.selectedMinutes.value / 60).ceil();
                          }
                        },
                        children: [
                          Center(
                            child: Text(
                              'Minutes',
                              style: AppTextStyle.mediumBlack16.copyWith(
                                color: controller.isMinutesSelected.value
                                    ? AppColors.lightRed
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Hours',
                              style: AppTextStyle.mediumBlack16.copyWith(
                                color: !controller.isMinutesSelected.value
                                    ? AppColors.lightRed
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Repeating', style: AppTextStyle.regularBlack16),
                  Obx(() => CupertinoSwitch(
                        value: controller.isRepeating.value,
                        onChanged: (val) => controller.isRepeating.value = val,
                        activeColor: Colors.green,
                      )),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Save',
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E293B),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateTimeBottomSheet(BuildContext context) {
    _dismissKeyboard(context); // Dismiss before showing bottom sheet
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: AppTextStyle.mediumBlack16
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    _dismissKeyboard(context); // Dismiss before picker
                    await controller.pickDate(context);
                    await Future.delayed(Duration(milliseconds: 50));
                    _dismissKeyboard(context); // Ensure no refocus
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 104, 103, 0.11),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Obx(() => Text(
                          controller.selectedDateStr.value,
                          style: AppTextStyle.mediumBlack16
                              .copyWith(color: AppColors.lightRed),
                        )),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    _dismissKeyboard(context); // Dismiss before picker
                    await controller.pickTime(context);
                    await Future.delayed(Duration(milliseconds: 50));
                    _dismissKeyboard(context); // Ensure no refocus
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 104, 103, 0.11),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() => Text(
                          controller.selectedTimeStr.value,
                          style: AppTextStyle.mediumBlack16
                              .copyWith(color: AppColors.lightRed),
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repeating',
                    style: AppTextStyle.regularBlack16,
                  ),
                  Obx(() => CupertinoSwitch(
                        value: controller.isRepeating.value,
                        onChanged: (val) => controller.isRepeating.value = val,
                        activeColor: Colors.green,
                      )),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // controller.saveDateTimeSettings();
                  Get.back();
                },
                child: Text('Save',
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E293B),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeekdayBottomSheet(BuildContext context) {
    _dismissKeyboard(context); // Dismiss before showing bottom sheet
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekdays',
              style: AppTextStyle.mediumBlack16
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: List.generate(7, (index) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Obx(() => GestureDetector(
                      onTap: () => controller.toggleWeekday(index),
                      child: Container(
                        width: Get.width * 0.098,
                        height: Get.height * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: controller.selectedWeekdays[index]
                              ? AppColors.lightRed
                              : Color.fromRGBO(255, 104, 103, 0.11),
                        ),
                        child: Center(
                          child: Text(
                            days[index],
                            style: AppTextStyle.mediumBlack16.copyWith(
                              color: controller.selectedWeekdays[index]
                                  ? Colors.white
                                  : AppColors.lightRed,
                            ),
                          ),
                        ),
                      ),
                    ));
              }),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('At', style: AppTextStyle.regularBlack16),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    _dismissKeyboard(context); // Dismiss before picker
                    await controller.pickTime(context);
                    await Future.delayed(Duration(milliseconds: 50));
                    _dismissKeyboard(context); // Ensure no refocus
                    if (controller.selectedDateTime.value == null) {
                      controller.selectedDateTime.value = DateTime.now();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 104, 103, 0.11),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() => Text(
                          controller.selectedTimeStr.value,
                          style: AppTextStyle.mediumBlack16
                              .copyWith(color: AppColors.lightRed),
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repeating',
                    style: AppTextStyle.regularBlack16,
                  ),
                  Obx(() => CupertinoSwitch(
                        value: controller.isRepeating.value,
                        onChanged: (val) => controller.isRepeating.value = val,
                        activeColor: Colors.green,
                      )),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Save',
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E293B),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
