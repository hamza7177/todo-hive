import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../../utils/app_colors.dart';

class CategoryBottomSheet extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String transactionType;
  final String? selectedCategory; // Add this to track the selected category

  CategoryBottomSheet({
    required this.onCategorySelected,
    required this.transactionType,
    this.selectedCategory, // Optional selected category
  });

  // Define main categories and their subcategories
  final Map<String, List<String>> expenseCategories = {
    'Food & Drink': ['Groceries', 'Restaurants', 'Cafes', 'Snacks'],
    'Shopping': ['Clothing', 'Electronics', 'Accessories', 'Gifts'],
    'Transport': ['Public Transport', 'Fuel', 'Taxi', 'Maintenance'],
    'Housing': ['Rent', 'Utilities', 'Maintenance', 'Furniture'],
    'Entertainment': ['Movies', 'Concerts', 'Sports', 'Hobbies'],
    'Social Life': ['Dining Out', 'Parties', 'Events', 'Gifts'],
    'Pets': ['Food', 'Vet', 'Toys', 'Grooming'],
    'Gift': ['Birthday', 'Anniversary', 'Wedding', 'Other'],
    'Culture': ['Books', 'Museums', 'Theater', 'Art'],
    'Apparel': ['Clothing', 'Shoes', 'Accessories', 'Jewelry'],
    'Health': ['Medicines', 'Gym', 'Doctor', 'Supplements'],
    'Other': ['Miscellaneous', 'Uncategorized'],
  };

  final incomeCategories = [
    'Salary',
    'Allowance',
    'Bonus',
    'Investment',
    'Gift',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final categories = transactionType == 'income'
        ? incomeCategories
        : expenseCategories.keys.toList();

    return DefaultTabController(
      length: transactionType == 'income' ? 1 : expenseCategories.length,
      child: Container(
        width: Get.width,
        height: Get.height * 0.27,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text('Category', style: AppTextStyle.mediumBlack16),
              SizedBox(height: 16),
              if (transactionType == 'expense')
                Align(
                  alignment: Alignment.topLeft,
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.black,
                    labelStyle: AppTextStyle.mediumBlack14,
                    unselectedLabelStyle: AppTextStyle.regularBlack14
                        .copyWith(color: Color(0xff8A8A8a)),
                    isScrollable: true,
                    tabs: categories
                        .map((category) => Tab(text: category))
                        .toList(),
                  ),
                ),
              SizedBox(height: 16),
              Expanded(
                child: transactionType == 'income'
                    ? _buildCategoryList(incomeCategories)
                    : TabBarView(
                        children: categories.map((category) {
                          return _buildCategoryList(
                              expenseCategories[category]!);
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<String> categories) {
    return Wrap(
      spacing: 24,
      runSpacing: 10,
      children: categories.map((category) {
        // Check if the current category is selected
        final isSelected = selectedCategory == category;

        return GestureDetector(
          onTap: () {
            onCategorySelected(category);
            Get.back();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // Apply red color if selected, otherwise use the default card color
              color: isSelected ? Colors.red : AppColors.cardColor,
              borderRadius: BorderRadius.circular(62),
            ),
            child: Text(
              category,
              style: AppTextStyle.regularBlack14.copyWith(
                color: isSelected
                    ? AppColors.white
                    : AppColors
                        .grey, // White text for selected, gray for unselected
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
