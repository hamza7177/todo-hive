import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/utils/app_colors.dart';

import '../../../utils/app_text_style.dart';
import '../controllers/todo_controller.dart';
import '../model/task_model.dart';
import '../widgets/todo_list_filter.dart';
import 'completed_todo_screen.dart';

class TodoListScreen extends StatelessWidget {
  TodoListScreen({super.key});

  final TodoController todoC = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    void showCategoryDialog(BuildContext context) {
      List<String> categories = [
        "No Specific",
        "Office Work",
        "Wishlist",
        "Birthday",
        "Personal"
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
              todoC.setCategory(category);
            },
          );
        }).toList(),
      );
    }

    void showTaskBottomSheet(BuildContext context) {
      final TextEditingController taskController = TextEditingController();
      final TodoController taskC = Get.find<TodoController>();
      showModalBottomSheet(
        backgroundColor: AppColors.white,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    hintText: "Input your new task here...",
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
                SizedBox(height: 12),
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
                                todoC.selectedCategory.value == ""
                                    ? 'Add Category'
                                    : todoC.selectedCategory.value,
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
                    if (taskController.text.isNotEmpty) {
                      taskC.addTask(
                          taskController.text, taskC.selectedCategory.value);
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
                    child: Text("Add Task",
                        style: AppTextStyle.mediumBlack16
                            .copyWith(color: AppColors.white)),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    }

    void showUpdateCategoryDialog(
        BuildContext context, String currentCategory) {
      List<String> categories = [
        "No Specific",
        "Office Work",
        "Wishlist",
        "Birthday",
        "Personal"
      ];

      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      final double menuWidth = 200.0;
      final double menuHeight = categories.length * 48.0;

      final double left = screenWidth - menuWidth - 12;
      final double top = screenHeight - menuHeight - 130;

      showMenu(
        color: AppColors.white,
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
        items: categories.map((category) {
          return PopupMenuItem(
            child: Text(category, style: AppTextStyle.regularBlack16),
            onTap: () {
              // Update category when selected
              todoC.selectedUpdateCategory.value = category;
            },
          );
        }).toList(),
      );
    }

    void showUpdateTaskBottomSheet(BuildContext context, Task task, int index) {
      final TextEditingController taskController =
          TextEditingController(text: task.title);
      final TodoController taskC = Get.find<TodoController>();

      showModalBottomSheet(
        backgroundColor: AppColors.white,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    hintText: "Input your new task here...",
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
                SizedBox(height: 12),
                DottedBorder(
                  color: Color(0xffE9E9E9),
                  dashPattern: [8, 4],
                  strokeWidth: 2,
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  child: GestureDetector(
                    onTap: () =>
                        showUpdateCategoryDialog(context, task.category),
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
                                taskC.selectedUpdateCategory.value == ""
                                    ? task.category
                                    : taskC.selectedUpdateCategory.value,
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
                    if (taskController.text.isNotEmpty) {
                      // Update the task with the selected category
                      taskC.updateTask(
                          index,
                          taskController.text,
                          taskC.selectedUpdateCategory.value.isEmpty
                              ? task.category
                              : taskC.selectedUpdateCategory.value);
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
                    child: Text("Update Task",
                        style: AppTextStyle.mediumBlack16
                            .copyWith(color: AppColors.white)),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    }

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
          'To-Do List',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => CompletedTodoScreen());
              },
              icon: Icon(Icons.check_circle, color: AppColors.black))
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
                  'Your ultimate tool for tracking and completing tasks on time with ease.',
                  style: AppTextStyle.mediumBlack16,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => TodoListFilter(
                            label: "All",
                            isSelected: todoC.selectedFilter.value == "All",
                            onTap: () => todoC.setFilter("All"),
                          )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                            label: "Office Work",
                            isSelected:
                                todoC.selectedFilter.value == "Office Work",
                            onTap: () => todoC.setFilter("Office Work"),
                          )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                            label: "Personal",
                            isSelected:
                                todoC.selectedFilter.value == "Personal",
                            onTap: () => todoC.setFilter("Personal"),
                          )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                            label: "Wishlist",
                            isSelected:
                                todoC.selectedFilter.value == "Wishlist",
                            onTap: () => todoC.setFilter("Wishlist"),
                          )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                            label: "Birthday",
                            isSelected:
                                todoC.selectedFilter.value == "Birthday",
                            onTap: () => todoC.setFilter("Birthday"),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final groupedTasks = todoC.getTasksGroupedByDate();

              return groupedTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ic_emptytodo.webp',
                            height: 140,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No task is currently on list',
                            style: AppTextStyle.mediumBlack18.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Click “+” to create your task',
                            style: AppTextStyle.regularBlack16,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: groupedTasks.entries.map((entry) {
                        final date = entry.key;
                        final tasksForDate = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "${date.day}-${date.month}-${date.year}",
                                style: AppTextStyle.mediumBlack18.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...tasksForDate.asMap().entries.map((taskEntry) {
                              final taskIndex = taskEntry.key; // Get index
                              final task = taskEntry.value; // Get task object

                              return Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    height: 60,
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Color(0xffD9D9D9)),
                                            shape: BoxShape.circle
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        SizedBox(
                                          width: Get.width * 0.6,
                                          child: Text(
                                            task.title,
                                            style: AppTextStyle.regularBlack14,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
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
                                            icon: Icon(Icons.more_vert,
                                                color: Color(0xffAFAFAF)),
                                            onSelected: (value) async {
                                              if (value == "Update") {
                                                showUpdateTaskBottomSheet(
                                                    context, task, taskIndex);
                                              } else if (value == "Delete") {
                                                bool? shouldDelete =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    backgroundColor:
                                                        AppColors.white,
                                                    title: Text("Delete Todo",
                                                        style: AppTextStyle
                                                            .mediumBlack16),
                                                    content: Text(
                                                        "Are you sure you want to delete this task?",
                                                        style: AppTextStyle
                                                            .regularBlack14),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Color(
                                                                    0xffF0F0F0),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8))),
                                                        child: Text('No',
                                                            style: AppTextStyle
                                                                .mediumPrimary14),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .primary,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8))),
                                                        child: Text("Yes",
                                                            style: AppTextStyle
                                                                .mediumBlack14
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .white)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (shouldDelete == true) {
                                                  todoC.deleteTask(task);
                                                }
                                              } else if (value == "Complete") {
                                                todoC.completeTask(task);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                  value: "Complete",
                                                  child: Text("Complete",
                                                      style: AppTextStyle
                                                          .regularBlack16)),
                                              PopupMenuItem(
                                                  value: "Update",
                                                  child: Text("Update",
                                                      style: AppTextStyle
                                                          .regularBlack16)),
                                              PopupMenuItem(
                                                  value: "Delete",
                                                  child: Text("Delete",
                                                      style: AppTextStyle
                                                          .mediumBlack16)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    );
            }),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70, // Adjust size as needed
        height: 70,
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,           // Resting elevation
          highlightElevation: 0,   // Pressed elevation
          splashColor: Colors.transparent, // Removes ripple effect
          onPressed: () => showTaskBottomSheet(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Adjust for rounded shape
            child: Image.asset('assets/images/ic_to_do.webp'),
          ),
        ),
      ),
    );
  }
}
