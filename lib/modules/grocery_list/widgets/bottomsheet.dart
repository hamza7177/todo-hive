import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/utils/app_colors.dart';

import '../../../utils/app_text_style.dart';
import '../controllers/grocery_list_controller.dart';
import '../views/grocery_list_details_screen.dart';

class TodoListBottomSheet extends StatelessWidget {
  TodoListBottomSheet({Key? key}) : super(key: key);
  final TextEditingController listNameController = TextEditingController();
  final GroceryListController groceryC = Get.find<GroceryListController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.58,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Main bottom sheet content
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 70),
                  // "Add new list" text input
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  SizedBox(height: 20),
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
          ),
          // Close (X) button
          Positioned(
            top: 15,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          // Clipboard icon circle
          Positioned(
            top: 0,
            child: Container(
                width: 132,
                height: 132,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 28),
                  child: Image.asset(
                    'assets/icons/grocery.png',
                    height: 50,
                    width: 50,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
