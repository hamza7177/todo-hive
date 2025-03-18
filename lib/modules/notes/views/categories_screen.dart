import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/notes_controller.dart';
import '../models/category_model.dart';

class CategoriesScreen extends StatelessWidget {
  final NotesController noteC = Get.find<NotesController>();

  CategoriesScreen({super.key});

  void showCategoryBottomSheet(BuildContext context,
      {Category? categoryToUpdate}) {
    final TextEditingController categoryController = TextEditingController(
      text: categoryToUpdate?.name ?? '',
    );
    showModalBottomSheet(
      backgroundColor: AppColors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  hintText: categoryToUpdate == null
                      ? "Input your new category here..."
                      : "Update category name...",
                  hintStyle: AppTextStyle.regularBlack16
                      .copyWith(color: const Color(0xffAFAFAF)),
                  filled: true,
                  fillColor: AppColors.textFieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: AppTextStyle.regularBlack16,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (categoryController.text.isNotEmpty) {
                    if (categoryToUpdate != null) {
                      noteC.updateCategory(
                          categoryToUpdate, categoryController.text);
                    } else {
                      noteC.addCategory(categoryController.text);
                    }
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Center(
                  child: Text(
                    categoryToUpdate != null
                        ? "Update Category"
                        : "Add Category",
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void confirmDeleteCategory(BuildContext context, Category category) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text("Delete Category", style: AppTextStyle.mediumBlack16),
        content: Text(
          "Are you sure you want to delete '${category.name}'? Notes with this category will be set to 'Untitled'.",
          style: AppTextStyle.regularBlack14,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: const Color(0xffF0F0F0),
            ),
            child: Text('No', style: AppTextStyle.mediumPrimary14),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              "Yes",
              style:
                  AppTextStyle.mediumBlack14.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      noteC.deleteCategory(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'Categories',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: noteC.categories.length,
            itemBuilder: (context, index) {
              final category = noteC.categories[index];
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => showCategoryBottomSheet(context,
                              categoryToUpdate: category),
                          child: Icon(
                            Icons.edit,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        Center(
                            child: Text(category.name,
                                style: AppTextStyle.mediumBlack16)),
                        GestureDetector(
                          onTap: () => confirmDeleteCategory(context, category),
                          child: Icon(
                            Icons.delete,
                            color: AppColors.lightRed,
                            size: 20,
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            },
          )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () => showCategoryBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Center(
              child: Text("Add a new Category",
                  style: AppTextStyle.mediumBlack16
                      .copyWith(color: AppColors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
