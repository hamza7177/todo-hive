import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/modules/grocery_list/controllers/grocery_list_controller.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../todo_list/widgets/todo_list_filter.dart';
import 'grocery_list_details_screen.dart';

class GroceryListScreen extends StatelessWidget {
  GroceryListScreen({super.key});

  final GroceryListController groceryC = Get.put(GroceryListController());

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
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'Grocery List',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (groceryC.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Never forget an item again—your perfect grocery list companion.',
                    style: AppTextStyle.mediumBlack16,
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        TodoListFilter(
                          label: "All",
                          isSelected: groceryC.selectedFilter.value == "All",
                          onTap: () => groceryC.setFilter("All"),
                        ),
                        const SizedBox(width: 8.0),
                        TodoListFilter(
                          label: "Starred",
                          isSelected:
                              groceryC.selectedFilter.value == "Starred",
                          onTap: () => groceryC.setFilter("Starred"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: groceryC.getFilteredLists().isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/ic_grocery_list.webp',
                              height: 140),
                          const SizedBox(height: 10),
                          Text(
                            'Your grocery list is empty.',
                            style: AppTextStyle.mediumBlack18
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Text('Start adding items now!',
                              style: AppTextStyle.regularBlack16),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      itemCount: groceryC.getFilteredLists().length,
                      itemBuilder: (context, index) {
                        final list = groceryC.getFilteredLists()[index];
                        final progress = groceryC.getListProgress(list.id);
                        final total = progress['total']!.toInt();
                        final completed = progress['completed']!.toInt();
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                groceryC.setCurrentList(list.id, list.name);
                                Get.to(() => GroceryListDetailScreen(
                                    listId: list.id, listName: list.name));
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 16, top: 10, bottom: 10),
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              list.name,
                                              style: AppTextStyle.mediumBlack16
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              '$completed out of $total',
                                              style: AppTextStyle.regularBlack14
                                                  .copyWith(
                                                      color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              popupMenuTheme:
                                                  PopupMenuThemeData(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            child: PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: Color(0xffAFAFAF),
                                                size: 24,
                                              ),
                                              onSelected: (value) async {
                                                if (value == "Starred") {
                                                  groceryC
                                                      .toggleStarred(list.id);
                                                } else if (value == "Delete") {
                                                  bool? shouldDelete =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      backgroundColor:
                                                          AppColors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      title: Text("Delete List",
                                                          style: AppTextStyle
                                                              .mediumBlack18),
                                                      content: Text(
                                                        "Are you sure you want to delete this list and all its items?",
                                                        style: AppTextStyle
                                                            .regularBlack14,
                                                      ),
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
                                                                              8)),
                                                              minimumSize:
                                                                  Size(100, 40),
                                                              elevation: 0),
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
                                                                              8)),
                                                              minimumSize:
                                                                  Size(100, 40),
                                                              elevation: 0),
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
                                                    groceryC.deleteList(
                                                        list.id, context);
                                                  }
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: "Starred",
                                                  child: Text("Starred",
                                                      style: AppTextStyle
                                                          .regularBlack16),
                                                ),
                                                PopupMenuItem(
                                                  value: "Delete",
                                                  child: Text("Delete",
                                                      style: AppTextStyle
                                                          .mediumBlack16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.868,
                                      child: LinearProgressIndicator(
                                        value:
                                            total > 0 ? completed / total : 0,
                                        backgroundColor: Colors.grey[300],
                                        color: Colors.green,
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () => _showCreateListBottomSheet(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Resting elevation
          highlightElevation: 0,
          // Pressed elevation
          splashColor: Colors.transparent,
          // Removes ripple effect
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/images/ic_grocery-1.webp'),
          ),
        ),
      ),
    );
  }

  void _showCreateListBottomSheet(BuildContext context) {
    final TextEditingController listNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.black),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: listNameController,
              decoration: InputDecoration(
                hintText: "Add new list",
                hintStyle: AppTextStyle.regularBlack16
                    .copyWith(color: Color(0xffAFAFAF)),
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
            Text('Suggestions', style: AppTextStyle.mediumBlack16),
            SizedBox(height: 8),
            Wrap(
              spacing: 24,
              runSpacing: 10,
              children: groceryC.initialSuggestions.map((suggestion) {
                return GestureDetector(
                  onTap: () => listNameController.text = suggestion,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xffF7F7F7),
                      borderRadius: BorderRadius.circular(62),
                    ),
                    child: Text(
                      suggestion,
                      style: AppTextStyle.regularBlack14
                          .copyWith(color: Color(0xff8A8A8A)),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (listNameController.text.isNotEmpty) {
                  groceryC.createNewList(listNameController.text);
                  Get.back();
                  Get.to(() => GroceryListDetailScreen(
                        listId: groceryC.currentListId.value,
                        listName: listNameController.text,
                      ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Center(
                child: Text("Create",
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white)),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
