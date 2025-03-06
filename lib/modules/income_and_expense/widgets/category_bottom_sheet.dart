import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class CategoryBottomSheet extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String transactionType;

  CategoryBottomSheet({required this.onCategorySelected, required this.transactionType});

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
    final categories = transactionType == 'income' ? incomeCategories : expenseCategories.keys.toList();

    return DefaultTabController(
      length: transactionType == 'income' ? 1 : expenseCategories.length,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            Text('Category', style: AppTextStyle.mediumBlack16),
            SizedBox(height: 16),
            if (transactionType == 'expense')
              TabBar(
                isScrollable: true,
                tabs: categories.map((category) => Tab(text: category)).toList(),
              ),
            SizedBox(height: 16),
            Expanded(
              child: transactionType == 'income'
                  ? _buildCategoryList(incomeCategories)
                  : TabBarView(
                children: categories.map((category) {
                  return _buildCategoryList(expenseCategories[category]!);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<String> categories) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: categories.map((category) {
        return GestureDetector(
          onTap: () {
            onCategorySelected(category);
            Get.back();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(62),
            ),
            child: Text(
              category,
              style: AppTextStyle.regularBlack14.copyWith(color: AppColors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }
}