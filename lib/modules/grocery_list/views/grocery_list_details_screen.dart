import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/modules/grocery_list/controllers/grocery_list_controller.dart';
import 'package:todo_hive/modules/grocery_list/views/predefine_items_screen.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

class GroceryListDetailScreen extends StatelessWidget {
  final String listId;
  final String listName;

  GroceryListDetailScreen({required this.listId, required this.listName});

  @override
  Widget build(BuildContext context) {
    final GroceryListController groceryC = Get.find<GroceryListController>();
    groceryC.currentListId.value = listId;
    groceryC.loadCurrentList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          listName,
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() => groceryC.itemQuantities.isEmpty ||
              groceryC.itemQuantities.values.every((q) => q == 0)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/ic_grocery_list.webp', height: 140),
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
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    itemCount: groceryC.itemQuantities.length,
                    itemBuilder: (context, index) {
                      final itemName =
                          groceryC.itemQuantities.keys.elementAt(index);
                      final quantity = groceryC.itemQuantities[itemName] ?? 0;
                      if (quantity > 0) {
                        final item = groceryC.groceryItems
                            .firstWhereOrNull((i) => i.name == itemName);
                        return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item?.isCompleted,
                                  onChanged: (value) {
                                    if (item != null) {
                                      groceryC.toggleItemCompletion(
                                          item.name, value ?? false);
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Rounded shape
                                  ),
                                  checkColor: Colors.white,
                                  // Tick color when checked
                                  activeColor: Colors.green,
                                  // Box color when checked
                                  side: BorderSide(
                                      color: Colors.grey,
                                      width:
                                          1.5), // Border color for unchecked state
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  itemName,
                                  style: AppTextStyle.regularBlack14,
                                ),
                                Spacer(),
                                Text('$quantity added'),
                                SizedBox(
                                  width: 6,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      groceryC.updateQuantity(itemName, 0),
                                ),
                              ],
                            ));
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ],
            )),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: ElevatedButton(
          onPressed: () => Get.to(
              () => PredefinedItemsScreen(listId: listId, listName: listName)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
          child: Center(
            child: Text(
              "Start adding items",
              style:
                  AppTextStyle.mediumBlack16.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
