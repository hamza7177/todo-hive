import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final Function(String) onMethodSelected;

  PaymentMethodBottomSheet({required this.onMethodSelected});

  final methods = ['Cash', 'Debit Card', 'Account','GPay','Other'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Method', style: AppTextStyle.mediumBlack16),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: methods.map((method) {
                return GestureDetector(
                  onTap: () {
                    onMethodSelected(method);
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(62),
                    ),
                    child: Text(
                      method,
                      style: AppTextStyle.regularBlack14.copyWith(color: AppColors.grey),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}