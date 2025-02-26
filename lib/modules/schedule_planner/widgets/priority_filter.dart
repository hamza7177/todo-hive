import 'package:flutter/material.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../../utils/app_colors.dart';

class PriorityFilter extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  PriorityFilter(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 49.0,
        width: 113,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightRed.withOpacity(0.1)
              : Color(0xffE9E9E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(label,
              style: AppTextStyle.regularBlack16.copyWith(
                color: isSelected ? AppColors.lightRed : Color(0xffAFAFAF),
              )),
        ),
      ),
    );
  }
}
