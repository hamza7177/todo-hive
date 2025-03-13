import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class DashboardCard extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final String imagePath;
  final Color color;

  const DashboardCard({
    super.key,
    required this.onPressed,
    required this.text,
    required this.imagePath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        height: Get.height * 0.1,
        width: Get.width * 0.42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          height: Get.height * 0.08,
          width: Get.width * 0.4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                height: 40,
              ),
              SizedBox(width: 10),
              Text(
                text,
                style: AppTextStyle.regularBlack16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
