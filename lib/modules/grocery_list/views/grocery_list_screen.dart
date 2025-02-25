import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/modules/grocery_list/controllers/grocery_list_controller.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../todo_list/widgets/todo_list_filter.dart';

class GroceryListScreen extends StatelessWidget {
  GroceryListScreen({super.key});

  final GroceryListController groceryC = Get.put(GroceryListController());

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
          'Grocery List',
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
                  'Never forget an item again—your perfect grocery list companion.',
                  style: AppTextStyle.mediumBlack16,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => TodoListFilter(
                            label: "All",
                            isSelected: groceryC.selectedFilter.value == "All",
                            onTap: () => groceryC.setFilter("All"),
                          )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                            label: "Starred",
                            isSelected:
                                groceryC.selectedFilter.value == "Starred",
                            onTap: () => groceryC.setFilter("Starred"),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/ic_grocery_list.webp',
                    height: 140,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your grocery list is empty.',
                    style: AppTextStyle.mediumBlack18.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start adding items now!',
                    style: AppTextStyle.regularBlack16,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70, // Adjust size as needed
        height: 70,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Adjust for rounded shape
            child: Image.asset('assets/images/ic_grocery-1.webp'),
          ),
        ),
      ),
    );
  }
}
