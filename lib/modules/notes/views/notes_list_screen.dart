import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../todo_list/widgets/todo_list_filter.dart';
import '../controllers/notes_controller.dart';
import 'categories_screen.dart';
import 'note_add_screen.dart';
import 'note_update_screen.dart';

class NotesListScreen extends StatefulWidget {
  NotesListScreen({super.key});

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _key = GlobalKey<ExpandableFabState>();
  final NotesController noteC = Get.put(NotesController());
  bool _isMenuOpen = false; // To track if the menu is open or closed

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
          child: const Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
        ),
        title: Text(
          'Notepad',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your ultimate tool for capturing thoughts and staying organized.',
                  style: AppTextStyle.mediumBlack16,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() => Row(
                        children: [
                          TodoListFilter(
                            label: "All",
                            isSelected: noteC.selectedFilter.value == "All",
                            onTap: () => noteC.setFilter("All"),
                          ),
                          const SizedBox(width: 8.0),
                          ...noteC.categories.map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TodoListFilter(
                                  label: category.name,
                                  isSelected: noteC.selectedFilter.value ==
                                      category.name,
                                  onTap: () =>
                                      noteC.setFilter(category.name),
                                ),
                              )),
                        ],
                      )),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final groupedTasks = noteC.getTasksGroupedByDate();

              return groupedTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/ic_notepad.webp',
                            height: 140,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No notes found!',
                            style: AppTextStyle.mediumBlack18.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Click “+” to create your note.',
                            style: AppTextStyle.regularBlack14,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: groupedTasks.entries.expand((entry) {
                        final tasksForDate = entry.value;

                        return tasksForDate.map((task) {
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 16,bottom: 14,top: 14),
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: Get.width * 0.6,
                                          child: Text(
                                            task.title,
                                            style: AppTextStyle
                                                .mediumBlack16
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          width: Get.width * 0.6,
                                          child: Text(
                                            task.description,
                                            style:
                                                AppTextStyle.regularBlack14,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          DateFormat('MM-dd-yyyy hh:mm a')
                                              .format(task.dateTime),
                                          style: AppTextStyle.regularBlack12
                                              .copyWith(
                                                  color: const Color(
                                                      0xffAEAEAE)),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        popupMenuTheme: PopupMenuThemeData(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.more_vert, color: Color(0xffAFAFAF)),
                                        onSelected: (value) async {
                                          if (value == "Edit") {
                                            Get.to(() => NoteUpdateScreen(
                                              note: task,
                                              index: noteC.notes.indexOf(task),
                                            ));
                                          } else if (value == "Delete") {
                                            bool? shouldDelete = await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: AppColors.white,
                                                  title: Text("Delete Todo", style: AppTextStyle.mediumBlack16),
                                                  content: Text(
                                                    "Are you sure you want to delete this task?",
                                                    style: AppTextStyle.regularBlack14,
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        backgroundColor: const Color(0xffF0F0F0),
                                                      ),
                                                      child: Text('No', style: AppTextStyle.mediumPrimary14),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(true);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        backgroundColor: AppColors.primary,
                                                      ),
                                                      child: Text(
                                                        "Yes",
                                                        style: AppTextStyle.mediumBlack14.copyWith(
                                                          color: AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (shouldDelete == true) {
                                              noteC.deleteTask(task);
                                            }
                                          } else if (value == "Share") {
                                            String shareText =
                                                "Task: ${task.title}\nDescription: ${task.description}\nDate: ${DateFormat('MM-dd-yyyy hh:mm a').format(task.dateTime)}";
                                            Share.share(shareText);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: "Edit",
                                            child: Text("Edit", style: AppTextStyle.regularBlack16),
                                          ),
                                          PopupMenuItem(
                                            value: "Delete",
                                            child: Text("Delete", style: AppTextStyle.mediumBlack16),
                                          ),
                                          PopupMenuItem(
                                            value: "Share",
                                            child: Text("Share", style: AppTextStyle.mediumBlack16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList();
                      }).toList(),
                    );
            }),
          )
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 65,
        // overlayStyle: ExpandableFabOverlayStyle(
        //   color: Colors.white.withOpacity(0.9),
        // ),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.lightRed,
          shape: const CircleBorder(),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.regular,
          foregroundColor:Colors.white,
          backgroundColor: AppColors.lightRed,
          shape: const CircleBorder(),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  // Shadow color with some transparency
                  spreadRadius: 2,
                  // How much the shadow spreads
                  blurRadius: 5,
                  // Softness of the shadow
                  offset: Offset(
                      0, 3), // Vertical offset to make it appear raised
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Get.to(() => CategoriesScreen());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit,
                        size: 20, color: Color(0xffA19C9C)),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Category',
                      style: AppTextStyle.regularBlack14.copyWith(
                        color: Color(0xffA19C9C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  // Subtle grey shadow
                  spreadRadius: 2,
                  // Shadow spread
                  blurRadius: 5,
                  // Shadow softness
                  offset:
                  Offset(0, 3), // Vertical offset for raised effect
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Get.to(() => NoteAddScreen());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 20, color: Color(0xffA19C9C)),
                    const SizedBox(width: 8),
                    Text(
                      'Add new note',
                      style: AppTextStyle.regularBlack14.copyWith(
                        color: Color(0xffA19C9C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
