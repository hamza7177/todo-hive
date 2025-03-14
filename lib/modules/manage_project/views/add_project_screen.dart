import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/modules/manage_project/controllers/manage_project_controller.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

class AddProjectScreen extends StatefulWidget {
  AddProjectScreen({super.key});

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final ManageProjectController projectC = Get.find<ManageProjectController>();
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Optional: Add listener for debugging focus issues
    titleFocusNode.addListener(() {
      if (titleFocusNode.hasFocus) {
        print("Title TextField gained focus");
      }
    });
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    titleController.dispose();
    super.dispose();
  }

  // Helper method to dismiss keyboard and prevent blink
  void _dismissKeyboard(BuildContext context) {
    if (titleFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(FocusNode()); // Shift focus away
      Future.delayed(Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus(); // Ensure keyboard stays dismissed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          style: AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: GestureDetector(
        onTap: () => _dismissKeyboard(context), // Dismiss keyboard on tap outside
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          children: [
            Text(
              'Project Title',
              style: AppTextStyle.mediumBlack16,
            ),
            SizedBox(height: 10),
            TextField(
              controller: titleController,
              focusNode: titleFocusNode, // Attach FocusNode
              decoration: InputDecoration(
                hintText: "Name your project...",
                hintStyle: AppTextStyle.regularBlack16.copyWith(color: Color(0xffAFAFAF)),
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
            ),
            SizedBox(height: 10),
            Text(
              'Project Due Date',
              style: AppTextStyle.mediumBlack16,
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                _dismissKeyboard(context); // Dismiss keyboard before picker
                await projectC.pickDate(context);
                // Small delay to prevent focus flicker
                await Future.delayed(Duration(milliseconds: 50));
                _dismissKeyboard(context); // Ensure no refocus after picker
              },
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
                    SizedBox(width: 5),
                    Text(
                      projectC.selectedDate.value,
                      style: AppTextStyle.mediumBlack16,
                    ),
                  ],
                )),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && projectC.selectedDateTime.value != null) {
                  projectC.addProject(
                    titleController.text,
                    projectC.selectedDateTime.value!,
                  );
                  titleController.clear(); // Clear the title field
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Please enter a title and select a due date');
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
                child: Text(
                  "Save the project",
                  style: AppTextStyle.mediumBlack16.copyWith(color: AppColors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}