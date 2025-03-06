import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class WalletBottomSheet extends StatelessWidget {
  final Function(String) onWalletSelected;

  WalletBottomSheet({required this.onWalletSelected});

  final wallets = ['Cash', 'Account', 'Card'];

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.black),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Text('Wallet', style: AppTextStyle.mediumBlack16),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: wallets.map((wallet) {
                return GestureDetector(
                  onTap: () {
                    onWalletSelected(wallet);
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(62),
                    ),
                    child: Text(
                      wallet,
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