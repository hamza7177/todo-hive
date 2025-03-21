import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import 'new_transaction_screen.dart';

class MainScreen extends GetView<TransactionController> {
  @override
  Widget build(BuildContext context) {
    String formatCurrency(num amount) {
      return NumberFormat('#,##0').format(amount);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreen3,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'Income & Expense Manager',
          style: AppTextStyle.mediumBlack18.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
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
                Obx(
                      () => Text(
                    '${controller.selectedCurrency.value} ${formatCurrency(controller.totalIncome.value - controller.totalExpense.value)}',
                    style: AppTextStyle.mediumBlack28
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Obx(() => _buildBalanceItem('Expense', controller.totalExpense.value, Colors.red)),
                    Obx(() => _buildBalanceItem('Income', controller.totalIncome.value, Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: AppTextStyle.mediumBlack16,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Obx(
                  () => controller.transactions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/ic_income-1.webp', height: 140),
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
                itemCount: controller.groupedTransactions.length,
                itemBuilder: (context, index) {
                  String date = controller.groupedTransactions.keys.elementAt(index);
                  List<Transaction> transactions = List<Transaction>.from(controller.groupedTransactions[date]!['transactions']);

                  double totalIncome = transactions
                      .where((t) => t.type == 'income')
                      .fold(0.0, (sum, t) => sum + t.amount);

                  double totalExpenses = transactions
                      .where((t) => t.type == 'expense')
                      .fold(0.0, (sum, t) => sum + t.amount);

                  double dayTotal = totalIncome - totalExpenses;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        height: 35,
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: AppTextStyle.regularBlack14.copyWith(color: Color(0xff8A8A8a)),
                            ),
                            Text(
                              "${controller.selectedCurrency.value} ${formatCurrency(dayTotal)}",
                              style: AppTextStyle.regularBlack14.copyWith(
                                color: Color(0xff8A8A8a),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...transactions.map((transaction) {
                        return Dismissible(
                          key: Key(transaction.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  title: Text(
                                    "Delete Transaction",
                                    style: AppTextStyle.mediumBlack18,
                                  ),
                                  content: Text(
                                    "Are you sure you want to delete this transaction?",
                                    style: AppTextStyle.regularBlack14,
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: const Color(0xffF0F0F0),
                                          minimumSize:
                                          Size(100, 40),
                                          elevation:
                                          0
                                      ),
                                      child: Text(
                                        'No',
                                        style: AppTextStyle.mediumPrimary14,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        controller.deleteTransaction(transaction.id);
                                        Get.back(result: true);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: AppColors.primary,
                                          minimumSize:
                                          Size(100, 40),
                                          elevation:
                                          0
                                      ),
                                      child: Text(
                                        "Yes",
                                        style: AppTextStyle.mediumBlack14.copyWith(color: AppColors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: ListTile(
                            leading: Container(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: transaction.type == 'income' ? AppColors.lightGreen3 : Color(0xffFFEEEE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset(
                                transaction.type == 'income' ? 'assets/icons/ic_downward.png' : 'assets/icons/ic_upward.png',
                                height: 40,
                              ),
                            ),
                            title: Text(
                              transaction.category ?? 'Transfer',
                              style: AppTextStyle.regularBlack18,
                            ),
                            subtitle: transaction.note != null && transaction.note!.isNotEmpty
                                ? Text(
                              transaction.note!,
                              style: AppTextStyle.regularBlack14.copyWith(color: Color(0xff8A8A8A)),
                              overflow: TextOverflow.ellipsis,
                            )
                                : null,
                            trailing: Text(
                              '${transaction.type == 'income' ? '+' : '-'}${controller.selectedCurrency.value}${formatCurrency(transaction.amount)}',
                              style: AppTextStyle.regularBlack14.copyWith(
                                color: transaction.type == 'income' ? Colors.green : Color(0xffED1C24),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
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
          highlightElevation: 0,
          splashColor: Colors.transparent,
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
      height: Get.height * 0.1,
      width: Get.width * 0.43,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        height: Get.height * 0.08,
        width: Get.width * 0.4,
        decoration: BoxDecoration(
          color: label == 'Expense' ? Color(0xffFFEEEE) : AppColors.lightGreen3,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: Get.height * 0.042,
              width: Get.width * 0.09,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                label == 'Expense'
                    ? 'assets/icons/ic_upward.png'
                    : 'assets/icons/ic_downward.png',
                height: Get.height * 0.035,
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
                Obx(() => Text(
                  '${controller.selectedCurrency.value}${NumberFormat('#,##0').format(value)}',
                  style: AppTextStyle.mediumBlack16
                      .copyWith(fontWeight: FontWeight.w600, fontSize: Get.height * 0.018),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}