import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/modules/grocery_list/controllers/grocery_list_controller.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

class PredefinedItemsScreen extends GetView<GroceryListController> {
  final String listId;
  final String listName;

  PredefinedItemsScreen({required this.listId, required this.listName});

  void _showAddCustomItemBottomSheet(BuildContext context) {
    final TextEditingController customItemController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customItemController,
              decoration: InputDecoration(
                hintText: "Add new item",
                hintStyle: AppTextStyle.regularBlack16.copyWith(color: Color(0xffAFAFAF)),
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final name = customItemController.text.trim();
                if (name.isNotEmpty && !controller.allItems.contains(name)) {
                  controller.allItems.add(name); // Only add to suggestions
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Center(
                child: Text("Save Item", style: AppTextStyle.mediumBlack16.copyWith(color: AppColors.white)),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.currentListId.value = listId; // Set the current list
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
          'List of items',
          style: AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          children: [
            DottedBorder(
              color: Color(0xffE9E9E9),
              dashPattern: [8, 4],
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              child: GestureDetector(
                onTap: () => _showAddCustomItemBottomSheet(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Add new item',
                      style: AppTextStyle.regularBlack16.copyWith(color: Color(0xffAFAFAF)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.allItems.length,
              itemBuilder: (context, index) {
                final itemName = controller.allItems[index];
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Obx(() {
                          final quantity = controller.itemQuantities[itemName] ?? 0;
                          return GestureDetector(
                            onTap: () => controller.addPredefinedItem(itemName),
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: quantity > 0 ? AppColors.lightRed : Color(0xffDDDDDD),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(Icons.add, color: Colors.white, size: 16),
                              ),
                            ),
                          );
                        }),
                        title: Text(itemName, style: AppTextStyle.regularBlack16),
                        trailing: Obx(() {
                          final quantity = controller.itemQuantities[itemName] ?? 0;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (quantity > 0)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('$quantity added', style: AppTextStyle.regularBlack14),
                                ),
                              if (quantity > 0)
                                IconButton(
                                  icon: Icon(Icons.remove, color: Colors.red),
                                  onPressed: () => controller.removeQuantity(itemName),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                    Obx(() => controller.recentlyAddedItem.value == itemName
                        ? Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      alignment: Alignment.center,
                      child: Text('Added', style: AppTextStyle.regularBlack14.copyWith(color: Colors.green)),
                    )
                        : SizedBox()),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
          ],
        );
      }),
    );
  }
}