import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';

import '../../../utils/app_colors.dart';

class TodoListFilter extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  TodoListFilter(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.0,
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
            color: isSelected ? AppColors.lightRed : Colors.white,
            borderRadius: BorderRadius.circular(102),
          border: Border.all(color: isSelected? AppColors.lightRed : Color(0xffD9D9D9), width: 1.0),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
