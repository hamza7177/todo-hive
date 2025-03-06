import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/transaction_controller.dart';
import 'new_transaction_screen.dart';

class MainScreen extends GetView<TransactionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreen3,
        elevation: 0,
        // Removes the shadow when not scrolled
        scrolledUnderElevation: 0,
        // Prevents shadow on scroll with Material 3
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'Income & Expense Manager',
          style:
              AppTextStyle.mediumBlack18.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Balance Summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGreen3,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Total Balance',
                  style: AppTextStyle.regularBlack14
                      .copyWith(color: Color(0xff8A8A8A)),
                ),
                SizedBox(height: 8),
                Obx(() => Text(
                      'Rs ${(controller.totalIncome.value - controller.totalExpense.value).toStringAsFixed(0)}',
                      style: AppTextStyle.mediumBlack28
                          .copyWith(fontWeight: FontWeight.w600),
                    )),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBalanceItem(
                        'Expense', controller.totalExpense.value, Colors.red),
                    _buildBalanceItem(
                        'Income', controller.totalIncome.value, Colors.green),
                  ],
                ),
              ],
            ),
          ),
          // Transactions List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: AppTextStyle.mediumBlack16,
                ),
                Obx(() => DropdownButton<String>(
                      value: controller.filter.value,
                      items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) controller.updateFilter(value);
                      },
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => controller.transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/ic_income-1.webp',
                            height: 140),
                        const SizedBox(height: 10),
                        Text(
                          'Your transaction history is empty.',
                          style: AppTextStyle.mediumBlack18
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Text('Start managing your journey now!',
                            style: AppTextStyle.regularBlack16),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.transactions[index];
                      return Card(
                        color: AppColors.cardColor,
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Container(
                            height: 40,
                            width: 40,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: transaction.type == 'income'
                                    ? AppColors.lightGreen3
                                    : Color(0xffFFEEEE),
                                borderRadius: BorderRadius.circular(10)),
                            child: Image.asset(
                              transaction.type == 'income'
                                  ? 'assets/icons/ic_downward.png'
                                  : 'assets/icons/ic_upward.png',
                              height: 40,
                            ),
                          ),
                          title: Text(
                            transaction.category ?? 'Transfer',
                            style: AppTextStyle.regularBlack18,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEE, dd/MM/yyyy')
                                    .format(transaction.date),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (transaction.note != null &&
                                  transaction.note!.isNotEmpty)
                                Text(transaction.note!,
                                    style: AppTextStyle.regularBlack14
                                        .copyWith(color: Color(0xff8A8A8A))),
                            ],
                          ),
                          trailing: Text(
                            '${transaction.type == 'income' ? '+' : '-'}Rs${transaction.amount.toStringAsFixed(0)}',
                            style: AppTextStyle.regularBlack14.copyWith(color: transaction.type == 'income' ? Colors.green : Color(0xffED1C24)),
                          ),
                        ),
                      );
                    },
                  )),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () => Get.to(() => NewTransactionScreen()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Resting elevation
          highlightElevation: 0,
          // Pressed elevation
          splashColor: Colors.transparent,
          // Removes ripple effect
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/icons/ic_add_income.webp'),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      height: 88,
      width: 175,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        height: 78,
        width: 165,
        decoration: BoxDecoration(
          color: label == 'Expense' ? Color(0xffFFEEEE) : AppColors.lightGreen3,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                label == 'Expense'
                    ? 'assets/icons/ic_upward.png'
                    : 'assets/icons/ic_downward.png',
                height: 40,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyle.regularBlack14
                      .copyWith(color: Color(0xff8A8A8A)),
                ),
                Text(
                  'Rs${value.toStringAsFixed(0)}',
                  style: AppTextStyle.mediumBlack16
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
