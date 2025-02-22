import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../controllers/reminder_controller.dart';

class ReminderScreen extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: "Give a name to reminder",
                hintStyle: AppTextStyle.regularBlack16
                    .copyWith(color: Color(0xffAFAFAF)),
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              minLines: 1,
              maxLines: 3,
              style: AppTextStyle.regularBlack16,
            ),
            SizedBox(height: 20),
            _buildSwitchTile('Interval', controller.isInterval, () {
              controller.toggleInterval();
              if (controller.isInterval.value) {
                _showIntervalBottomSheet(context);
              }
            }),
            SizedBox(height: 10),
            _buildSwitchTile('Date & Time', controller.isDateTime, () {
              controller.toggleDateTime();
              if (controller.isDateTime.value) {
                _showDateTimeBottomSheet(context);
              }
            }),
            SizedBox(height: 10),
            _buildSwitchTile('Weekday', controller.isWeekday, () {
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
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Center(
                  child: Text("Set Reminder",
                      style: AppTextStyle.mediumBlack16
                          .copyWith(color: AppColors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, RxBool value, VoidCallback onChanged) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
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
                color: color, // Tick icon in the selected color
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

            /// Interval Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Improved Minutes Dropdown
                Container(
                  height: 49,
                  width: 69,
                  // Adjusted width
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 104, 103, 0.11),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Obx(() => DropdownButton<int>(
                        value: controller.selectedMinutes.value,
                        underline: SizedBox(),
                        // Removes underline
                        isExpanded: false,
                        isDense: false,
                        // Ensures full width usage
                        dropdownColor: Colors.white,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        // Text in red
                        icon: SizedBox.shrink(),
                        // Removes dropdown icon
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedMinutes.value = value;
                          }
                        },
                        items: List.generate(
                          60,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyle.mediumBlack16.copyWith(
                                    color: AppColors
                                        .lightRed), // Text in red inside dropdown
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
                SizedBox(width: 15),

                /// Improved Minutes / Hours Toggle
                GestureDetector(
                  onTap: () {
                    controller.isMinutesSelected.value =
                        !controller.isMinutesSelected.value;
                  },
                  child: Obx(() => Container(
                        width: 100,
                        // Match width with dropdown
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        // Adjusted padding
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 104, 103, 0.11),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                              controller.isMinutesSelected.value
                                  ? 'Minutes'
                                  : 'Hours',
                              style: AppTextStyle.mediumBlack16
                                  .copyWith(color: AppColors.lightRed)),
                        ),
                      )),
                ),
              ],
            ),
            SizedBox(height: 20),

            /// Repeating Toggle
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

            /// Save Button
             SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.saveDateTimeSettings();
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
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 104, 103, 0.11),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Obx(() => Text(
                          controller.selectedDate.value,
                          style: AppTextStyle.mediumBlack16
                              .copyWith(color: AppColors.lightRed),
                        )),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => controller.pickTime(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 104, 103, 0.11),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() => Text(
                          controller.selectedTime.value,
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
                  controller.saveDateTimeSettings();
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
                        width: 44,
                        height: 49,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: controller.selectedWeekdays[index]
                              ? AppColors.lightRed
                              : Color.fromRGBO(255, 104, 103, 0.11),
                        ),
                        child: Center(
                          child: Text(days[index],
                              style: AppTextStyle.mediumBlack16.copyWith(
                                color: controller.selectedWeekdays[index]
                                    ? Colors.white
                                    : AppColors.lightRed,
                              )),
                        ),
                      ),
                    ));
              }),
            ),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('At',style: AppTextStyle.regularBlack16,),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () => controller.pickTime(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 104, 103, 0.11),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() => Text(
                      controller.selectedTime.value,
                      style: AppTextStyle.mediumBlack16
                          .copyWith(color: AppColors.lightRed),
                    )),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
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
                  controller.saveDateTimeSettings();
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
