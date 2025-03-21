import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../../utils/widgets/custom_flash_bar.dart';
import '../controllers/notes_controller.dart';
import '../models/note_model.dart';

class NoteUpdateScreen extends StatefulWidget {
  final Note note;
  final int index;

  NoteUpdateScreen({super.key, required this.note, required this.index});

  @override
  _NoteUpdateScreenState createState() => _NoteUpdateScreenState();
}

class _NoteUpdateScreenState extends State<NoteUpdateScreen> {
  final NotesController noteController = Get.find<NotesController>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    descriptionController = TextEditingController(text: widget.note.description);

    // Optional: Debug focus
    titleFocusNode.addListener(() {
      if (titleFocusNode.hasFocus) {
        print("Title TextField gained focus");
      }
    });
    descriptionFocusNode.addListener(() {
      if (descriptionFocusNode.hasFocus) {
        print("Description TextField gained focus");
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  // Helper method to dismiss keyboard and prevent blink
  void _dismissKeyboard(BuildContext context) {
    if (titleFocusNode.hasFocus || descriptionFocusNode.hasFocus) {
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
          "Edit note",
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
                    "Edited: ${DateFormat('MM-dd-yyyy h:mm a').format(widget.note.dateTime)}",
                    style: AppTextStyle.regularBlack12
                        .copyWith(color: Color(0xffC5C5C5)),
                  ),
                  Spacer(),
                  _buildCategoryDropdown(context, widget.note),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: titleController,
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
                maxLines: 2,
                style: AppTextStyle.boldBlack20,
              ),
              Container(
                height: Get.height * 0.003,
                color: Color(0xffECECEC),
              ),
              Expanded(
                child: TextField(
                  controller: descriptionController,
                  focusNode: descriptionFocusNode, // Attach FocusNode
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
                  if (titleController.text.isEmpty) {
                    CustomFlashBar.show(
                      context: context,
                      message: "Enter a title",
                      isAdmin: true, // optional
                      isShaking: false, // optional
                      primaryColor: AppColors.primary, // optional
                      secondaryColor: Colors.white, // optional
                    );

                  } else if (descriptionController.text.isEmpty) {
                    CustomFlashBar.show(
                      context: context,
                      message: "Enter note description",
                      isAdmin: true, // optional
                      isShaking: false, // optional
                      primaryColor: AppColors.primary, // optional
                      secondaryColor: Colors.white, // optional
                    );
                  } else {
                    noteController.updateNote(
                        widget.index,
                        titleController.text,
                        descriptionController.text,
                        noteController.selectedUpdateCategory.value == ""
                            ? widget.note.category
                            : noteController.selectedUpdateCategory.value);
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
                    "Update Note",
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
  Widget _buildCategoryDropdown(BuildContext context, Note note) {
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
              noteController.selectedUpdateCategory.value == ""
                  ? note.category
                  : noteController.selectedUpdateCategory.value,
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
            noteController.selectedUpdateCategory(category.name);
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