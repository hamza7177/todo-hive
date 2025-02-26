import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/modules/manage_project/controllers/manage_project_controller.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../schedule_planner/widgets/priority_filter.dart';
import 'add_task_screen.dart';

class AddProjectScreen extends StatelessWidget {
  AddProjectScreen({super.key});

  final ManageProjectController projectC = Get.find<ManageProjectController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

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
          'Add Project',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        children: [
          Text(
            'Project Title',
            style: AppTextStyle.mediumBlack16,
          ),
          SizedBox(height: 10),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Name your project...",
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
          SizedBox(height: 10),
          Text(
            'Project Due Date',
            style: AppTextStyle.mediumBlack16,
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => projectC.pickDate(context),
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
                        projectC.selectedDate.value,
                        style: AppTextStyle.mediumBlack16
                            .copyWith(color: Color(0xffAFAFAF)),
                      ),
                    ],
                  )),
            ),
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Description',
                style: AppTextStyle.mediumBlack16,
              ),
              SizedBox(width: 5,),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '(Optional)',
                  style: AppTextStyle.mediumBlack14
                      .copyWith(color: Color(0xff8A8A8A)),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: "Write something here...",
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
            'Priority Level',
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
                        isSelected: projectC.selectedPriority.value == "Low",
                        onTap: () => projectC.selectedPriority("Low"),
                      )),
                  const SizedBox(width: 8.0),
                  Obx(() => PriorityFilter(
                        label: "Medium",
                        isSelected: projectC.selectedPriority.value == "Medium",
                        onTap: () => projectC.selectedPriority("Medium"),
                      )),
                  const SizedBox(width: 8.0),
                  Obx(() => PriorityFilter(
                        label: "High",
                        isSelected: projectC.selectedPriority.value == "High",
                        onTap: () => projectC.selectedPriority("High"),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // if (titleController.text.isNotEmpty) {
              //   controller.addSchedule(
              //     title: titleController.text,
              //     description: descriptionController.text,
              //   );
              //   Get.back();
              // } else {
              //   Get.snackbar('Error', 'Please enter a title');
              // }
              Get.to(()=> AddTaskScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Center(
              child: Text("Save the project",
                  style: AppTextStyle.mediumBlack16
                      .copyWith(color: AppColors.white)),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
