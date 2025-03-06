import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction.dart';
import '../widgets/category_bottom_sheet.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/wallet_bottom_sheet.dart';

class NewTransactionScreen extends StatefulWidget {
  @override
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  String selectedTab = 'Expense';
  double amount = 0.0;
  String? selectedCategory;
  String? selectedPaymentMethod;
  String? fromWallet;
  String? toWallet;
  DateTime selectedDate = DateTime.now();
  String note = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Transaction'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Expense', 'Income', 'Transfer'].map((tab) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = tab;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: selectedTab == tab ? Colors.blue[900] : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: selectedTab == tab ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Amount
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selectedTab == 'Income' ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixText: 'Rs ',
                hintText: '0',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                amount = double.tryParse(value) ?? 0.0;
              },
            ),
          ),
          // Fields
          if (selectedTab != 'Transfer') ...[
            ListTile(
              title: Text('Category'),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  selectedCategory ?? 'Select',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              onTap: () {
                Get.bottomSheet(CategoryBottomSheet(
                  onCategorySelected: (category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  transactionType: selectedTab.toLowerCase(),
                ));
              },
            ),
            ListTile(
              title: Text('Payment Method'),
              trailing: Text(selectedPaymentMethod ?? 'Select'),
              onTap: () {
                Get.bottomSheet(PaymentMethodBottomSheet(
                  onMethodSelected: (method) {
                    setState(() {
                      selectedPaymentMethod = method;
                    });
                  },
                ));
              },
            ),
          ] else ...[
            ListTile(
              title: Text('From Wallet'),
              trailing: Text(fromWallet ?? 'Select'),
              onTap: () {
                Get.bottomSheet(WalletBottomSheet(
                  onWalletSelected: (wallet) {
                    setState(() {
                      fromWallet = wallet;
                    });
                  },
                ));
              },
            ),
            ListTile(
              title: Text('To Wallet'),
              trailing: Text(toWallet ?? 'Select'),
              onTap: () {
                Get.bottomSheet(WalletBottomSheet(
                  onWalletSelected: (wallet) {
                    setState(() {
                      toWallet = wallet;
                    });
                  },
                ));
              },
            ),
          ],
          ListTile(
            title: Text('Date'),
            trailing: Text(DateFormat('EEE, dd/MM/yyyy').format(selectedDate)),
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => Container(
                  height: 200,
                  color: Colors.white,
                  child: CupertinoDatePicker(
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: TextField(
              decoration: InputDecoration(
                hintText: 'Note',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                note = value;
              },
            ),
          ),
          // Buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final controller = Get.find<TransactionController>();
                    final transaction = Transaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      amount: amount,
                      date: selectedDate,
                      type: selectedTab.toLowerCase(),
                      category: selectedCategory,
                      paymentMethod: selectedPaymentMethod,
                      note: note,
                      fromWallet: fromWallet,
                      toWallet: toWallet,
                    );
                    controller.addTransaction(transaction);
                    Get.back();
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}