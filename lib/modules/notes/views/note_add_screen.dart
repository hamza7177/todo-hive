import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/notes_controller.dart';

class NoteAddScreen extends StatelessWidget {
  final NotesController noteController = Get.find<NotesController>();

  final List<String> categories = [
    "Personal",
    "Work",
    "Random",
    "Shopping",
  ];

   NoteAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        // Removes the shadow when not scrolled
        scrolledUnderElevation: 0,
        // Prevents shadow on scroll with Material 3
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Adding new note",
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Edited: ${DateFormat('MM-dd-yyyy h:mm a').format(DateTime.now().toLocal())}",
                  style: AppTextStyle.regularBlack14.copyWith(color: Color(0xffC5C5C5)),
                ),
                Spacer(),
                _buildCategoryDropdown(context),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: noteController.titleController,
              decoration: InputDecoration(
                hintText: "Title",
                hintStyle: AppTextStyle.mediumBlack16.copyWith(
                    color: Color(0xffC5C5C5),
                    fontSize: 25,
                    fontWeight: FontWeight.w600),
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 3,
              style: AppTextStyle.boldBlack20,
            ),
            Container(
              height: Get.height * 0.003,
              color: Color(0xffECECEC),
            ),
            Expanded(
              child: TextField(
                controller: noteController.noteController,
                maxLines: null,
                onChanged: (_) => noteController.update(),
                decoration: InputDecoration(
                  hintText: "Write something here...",
                  hintStyle: AppTextStyle.regularBlack16
                      .copyWith(color: Color(0xffC5C5C5)),
                  border: InputBorder.none,
                ),
                style: AppTextStyle.regularBlack16,
              ),
            ),
            Obx(() => Center(
                  child: Text(
                    "You can write ${noteController.maxWords.value} words",
                    style: AppTextStyle.regularBlack16
                        .copyWith(color: Color(0xffC5C5C5)),
                  ),
                )),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (noteController.titleController.text.isNotEmpty && noteController.noteController.text.isNotEmpty && noteController.selectedCategory.value.isNotEmpty) {
                  noteController.addNote(
                      noteController.titleController.text,noteController.noteController.text, noteController.selectedCategory.value);
                  Get.back();
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
                child: Text("Save Note",
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom dropdown button with dotted border
  Widget _buildCategoryDropdown(BuildContext context) {
    return GestureDetector(
      onTap: () => showCategoryDialog(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() => Text(
                  noteController.selectedCategory.value == ""
                      ? 'Add Category'
                      : noteController.selectedCategory.value,
                  style: AppTextStyle.regularBlack14,
                )),
            SizedBox(width: 5,),
            Icon(FontAwesomeIcons.chevronDown, color: Color(0xffAFAFAF),size: 15,),
          ],
        ),
      ),
    );
  }

  /// Custom dropdown positioned at the upper right
  void showCategoryDialog(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Get screen size
    final double screenWidth = MediaQuery.of(context).size.width;
    final double menuWidth = 180.0;
    final double menuHeight = categories.length * 48.0;

    // Positioning the menu at the top-right of the button
    final double left = screenWidth - menuWidth - 5; // Adjusting position
    final double top = offset.dy + 75; // Moved down by 60 instead of 50

    showMenu(
      color: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      position: RelativeRect.fromLTRB(
        left,
        top,
        left + menuWidth,
        top + menuHeight,
      ),
      items: noteController.categories.map((category) {
        return PopupMenuItem(
          child: Text(category.name,
              style: TextStyle(fontSize: 16, color: Colors.black)),
          onTap: () {
            noteController.setCategory(category.name);
          },
        );
      }).toList(),
    );
  }
}
