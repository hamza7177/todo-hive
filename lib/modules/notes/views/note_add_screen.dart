import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../controllers/notes_controller.dart';

class NoteAddScreen extends StatefulWidget {
  NoteAddScreen({super.key});

  @override
  _NoteAddScreenState createState() => _NoteAddScreenState();
}

class _NoteAddScreenState extends State<NoteAddScreen> {
  final NotesController noteController = Get.find<NotesController>();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Optional: Debug focus
    titleFocusNode.addListener(() {
      if (titleFocusNode.hasFocus) {
        print("Title TextField gained focus");
      }
    });
    noteFocusNode.addListener(() {
      if (noteFocusNode.hasFocus) {
        print("Note TextField gained focus");
      }
    });
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    noteFocusNode.dispose();
    super.dispose();
  }

  // Helper method to dismiss keyboard and prevent blink
  void _dismissKeyboard(BuildContext context) {
    if (titleFocusNode.hasFocus || noteFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(FocusNode()); // Shift focus to a dummy node
      Future.delayed(Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus(); // Ensure keyboard stays dismissed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          style: AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: GestureDetector(
        onTap: () => _dismissKeyboard(context), // Dismiss keyboard on tap outside
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Edited: ${DateFormat('MM-dd-yyyy h:mm a').format(DateTime.now().toLocal())}",
                    style: AppTextStyle.regularBlack12
                        .copyWith(color: Color(0xffC5C5C5)),
                  ),
                  Spacer(),
                  _buildCategoryDropdown(context),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: noteController.titleController,
                focusNode: titleFocusNode, // Attach FocusNode
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
                  focusNode: noteFocusNode, // Attach FocusNode
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
                  if (noteController.titleController.text.isEmpty) {
                    Get.snackbar("Error", "Please enter title");
                  } else if (noteController.selectedCategory.value.isEmpty) {
                    Get.snackbar("Error", "Please select category");
                  } else if (noteController.noteController.text.isEmpty) {
                    Get.snackbar("Error", "Please enter note");
                  } else {
                    noteController.addNote(
                        noteController.titleController.text,
                        noteController.noteController.text,
                        noteController.selectedCategory.value);
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
                  child: Text(
                    "Save Note",
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom dropdown button with dotted border
  Widget _buildCategoryDropdown(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _dismissKeyboard(context); // Dismiss before showing dialog
        showCategoryDialog(context);
      },
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
            SizedBox(width: 5),
            Icon(
              FontAwesomeIcons.chevronDown,
              color: Color(0xffAFAFAF),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  /// Custom dropdown positioned at the upper right
  void showCategoryDialog(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double menuWidth = 180.0;
    final double menuHeight = noteController.categories.length * 48.0;

    final double left = screenWidth - menuWidth - 5;
    final double top = offset.dy + 75;

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
          child: Text(
            category.name,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          onTap: () {
            noteController.setCategory(category.name);
          },
        );
      }).toList(),
    ).then((_) {
      // Ensure keyboard doesn’t reopen after dialog closes
      Future.delayed(Duration(milliseconds: 50), () {
        _dismissKeyboard(context);
      });
    });
  }
}