import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/schedule_controller.dart';
import '../widgets/priority_filter.dart';

class AddSchedulerScreen extends StatelessWidget {
  AddSchedulerScreen({super.key});

  final ScheduleController controller = Get.find<ScheduleController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<Color> colors = [
    Color(0xFF17D650),
    Color(0xFFD61817),
    Color(0xFF17D0D6),
    Color(0xffFFA500),
    Color(0xFFDF4BCB),
    Color(0xFFD6D017),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        // Removes the shadow when not scrolled
        scrolledUnderElevation: 0,
        // Prevents shadow on scroll with Material 3
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
        ),
        title: Text(
          'Add Schedule',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        children: [
          Image.asset(
            'assets/icons/ic_sun.png',
            height: 100,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Add task here",
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
          ),
          SizedBox(height: 10),
          Text(
            'Choose color',
            style: AppTextStyle.mediumBlack16,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colors.map((color) => _buildColorButton(color)).toList(),
          ),
          SizedBox(height: 10),
          Text(
            'Description',
            style: AppTextStyle.mediumBlack16,
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: "Submit the final report by 3 PM",
              hintStyle: AppTextStyle.regularBlack16
                  .copyWith(color: Color(0xffAFAFAF)),
              filled: true,
              fillColor: AppColors.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            minLines: 3,
            maxLines: 5,
            style: AppTextStyle.regularBlack16,
          ),
          SizedBox(height: 10),
          Text(
            'Priority level',
            style: AppTextStyle.mediumBlack16,
          ),
          SizedBox(height: 10),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Obx(() => PriorityFilter(
                        label: "Low",
                        isSelected: controller.selectedPriority.value == "Low",
                        onTap: () => controller.selectedPriority("Low"),
                      )),
                  const SizedBox(width: 8.0),
                  Obx(() => PriorityFilter(
                        label: "Medium",
                        isSelected:
                            controller.selectedPriority.value == "Medium",
                        onTap: () => controller.selectedPriority("Medium"),
                      )),
                  const SizedBox(width: 8.0),
                  Obx(() => PriorityFilter(
                        label: "High",
                        isSelected: controller.selectedPriority.value == "High",
                        onTap: () => controller.selectedPriority("High"),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set Reminder',
                  style: AppTextStyle.regularBlack16,
                ),
                Obx(() => CupertinoSwitch(
                      value: controller.isReminder.value,
                      onChanged: (val) => controller.isReminder.value = val,
                      activeColor: Colors.green,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
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
                  height: 51,
                  width: 175,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xffF9F9F9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Obx(() => Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: Color(0xffAFAFAF),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            controller.selectedDate.value,
                            style: AppTextStyle.mediumBlack16
                                .copyWith(color: Color(0xffAFAFAF)),
                          ),
                        ],
                      )),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => controller.pickTime(context),
                child: Container(
                  height: 51,
                  width: 175,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xffF9F9F9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Obx(
                    () => Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: Color(0xffAFAFAF),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(controller.selectedTime.value,
                            style: AppTextStyle.mediumBlack16.copyWith(
                              color: Color(0xffAFAFAF),
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
          DottedBorder(
            color: Color(0xffE9E9E9),
            dashPattern: [8, 4],
            strokeWidth: 2,
            borderType: BorderType.RRect,
            radius: Radius.circular(12),
            child: GestureDetector(
              onTap: () => showCategoryDialog(context),
              child: Container(
                padding:
                EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      controller.selectedCategory.value == ""
                          ? 'Add Category'
                          : controller.selectedCategory.value,
                      style: AppTextStyle.regularBlack16,
                    )),
                    Icon(Icons.add, color: Color(0xffAFAFAF)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                controller.addSchedule(
                  title: titleController.text,
                  description: descriptionController.text,
                );
                Get.back();
              } else {
                Get.snackbar('Error', 'Please enter a title');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Center(
              child: Text("Save the plan",
                  style: AppTextStyle.mediumBlack16
                      .copyWith(color: AppColors.white)),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void showCategoryDialog(BuildContext context) {
    List<String> categories = [
      "Category 1",
      "Category 2",
      "Category 3",
      "Category 4",
      "Category 5"
    ];

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Calculate the position for the menu to appear on the right side and slightly above the bottom
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double menuWidth = 200.0; // Adjust the width of the menu as needed
    final double menuHeight = categories.length *
        48.0; // Approximate height based on the number of items

    final double left =
        screenWidth - menuWidth - 12; // 16 is padding from the right edge
    final double top = screenHeight -
        menuHeight -
        130; // 100 is the distance from the bottom

    showMenu(
      color: AppColors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Apply border radius here
      ),
      position: RelativeRect.fromLTRB(
        left,
        top,
        left + menuWidth,
        top + menuHeight,
      ),
      items: categories.map((category) {
        return PopupMenuItem(
          child: Text(category, style: AppTextStyle.regularBlack16),
          onTap: () {
            controller.setCategory(category);
          },
        );
      }).toList(),
    );
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
}
