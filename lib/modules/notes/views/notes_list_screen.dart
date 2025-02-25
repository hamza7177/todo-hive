import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../todo_list/widgets/todo_list_filter.dart';
import '../controllers/notes_controller.dart';
import 'categories_screen.dart';
import 'note_add_screen.dart';
import 'note_update_screen.dart';

class NotesListScreen extends StatelessWidget {
  NotesListScreen({super.key});

  final NotesController noteC = Get.put(NotesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
        ),
        title: Text(
          'Notepad',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Image.asset(
                //   'assets/images/ic_search.webp',
                //   height: 20,
                // ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => CategoriesScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(102)),
                    backgroundColor: Color(0xffF0F0F0),
                  ),
                  child: Text('Edit', style: AppTextStyle.mediumPrimary14),
                )
              ],
            ),
          )
        ],
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
                          ...noteC.categories
                              .map((category) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: TodoListFilter(
                                      label: category.name,
                                      isSelected: noteC.selectedFilter.value ==
                                          category.name,
                                      onTap: () =>
                                          noteC.setFilter(category.name),
                                    ),
                                  ))
                              .toList(),
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
                            style: AppTextStyle.regularBlack16,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: groupedTasks.entries.expand((entry) {
                        final tasksForDate = entry.value;

                        return tasksForDate.map((task) {
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: AppTextStyle.mediumBlack16,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            task.description,
                                            style: AppTextStyle.mediumBlack16,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            DateFormat('MM-dd-yyyy hh:mm a')
                                                .format(task.dateTime),
                                            style: AppTextStyle.regularBlack12
                                                .copyWith(
                                                    color: Color(0xffAEAEAE)),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 30),
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
                                        icon: Icon(Icons.more_vert,
                                            color: Color(0xffAFAFAF)),
                                        onSelected: (value) async {
                                          if (value == "Update") {
                                            Get.to(() => NoteUpdateScreen(
                                                  note: task,
                                                  index:
                                                      noteC.notes.indexOf(task),
                                                ));
                                          } else if (value == "Delete") {
                                            bool? shouldDelete =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      AppColors.white,
                                                  title: Text(
                                                    "Delete Todo",
                                                    style: AppTextStyle
                                                        .mediumBlack16,
                                                  ),
                                                  content: Text(
                                                    "Are you sure you want to delete this task?",
                                                    style: AppTextStyle
                                                        .regularBlack14,
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        backgroundColor:
                                                            Color(0xffF0F0F0),
                                                      ),
                                                      child: Text(
                                                        'No',
                                                        style: AppTextStyle
                                                            .mediumPrimary14,
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        backgroundColor:
                                                            AppColors.primary,
                                                      ),
                                                      child: Text(
                                                        "Yes",
                                                        style: AppTextStyle
                                                            .mediumBlack14
                                                            .copyWith(
                                                          color:
                                                              AppColors.white,
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
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: "Update",
                                            child: Text(
                                              "Update",
                                              style:
                                                  AppTextStyle.regularBlack16,
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: "Delete",
                                            child: Text(
                                              "Delete",
                                              style: AppTextStyle.mediumBlack16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        }).toList();
                      }).toList(),
                    );
            }),
          )
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70, // Adjust size as needed
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => NoteAddScreen());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Adjust for rounded shape
            child: Image.asset('assets/images/ic_notepad-1.webp'),
          ),
        ),
      ),
    );
  }
}
