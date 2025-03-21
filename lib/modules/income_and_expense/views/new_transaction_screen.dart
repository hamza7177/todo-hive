import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
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

  final FocusNode amountFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();
  final TransactionController controller = Get.find<TransactionController>();

  // List of available currency signs
  final List<String> currencyOptions = [
    'Rs', '\$', '€', '£', '¥', '₹', '₽', '₩', '₪', '฿', '₫', '₣'
  ];
  bool isCurrencyLocked = false;
  @override
  void initState() {
    super.initState();
    final savedCurrency = Hive.box('settings').get('selectedCurrency');
    if (savedCurrency != null) {
      isCurrencyLocked = true;
      controller.updateCurrency(savedCurrency);
    }
    amountFocusNode.addListener(() {
      if (amountFocusNode.hasFocus) {
        print("Amount TextField gained focus");
      }
    });
    noteFocusNode.addListener(() {
      if (noteFocusNode.hasFocus) {
        print("Note TextField gained focus");
      }
    });
  }

  @override
  void dispose() {
    amountFocusNode.dispose();
    noteFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard(BuildContext context) {
    if (amountFocusNode.hasFocus || noteFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(FocusNode());
      Future.delayed(Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_sharp, color: AppColors.black),
        ),
        title: Text(
          'New Transaction',
          style: AppTextStyle.mediumBlack18.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: GestureDetector(
        onTap: () => _dismissKeyboard(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Income', 'Expense', 'Transfer'].map((tab) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = tab;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          tab,
                          style: selectedTab == tab
                              ? AppTextStyle.mediumBlack16
                              : AppTextStyle.regularBlack16
                              .copyWith(color: Color(0xff8A8A8A)),
                        ),
                        if (selectedTab == tab)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            height: 2,
                            width: 70,
                            color: Colors.black,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              // Amount with Currency Selection
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selectedTab == 'Income' ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Obx(() => Container(
                      decoration: BoxDecoration(
                        color: selectedTab == 'Income' ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: isCurrencyLocked
                          ? Text(
                        controller.selectedCurrency.value,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                        ),
                      )
                          : DropdownButton<String>(
                        value: controller.selectedCurrency.value,
                        items: currencyOptions
                            .map((String currency) => DropdownMenuItem<String>(
                          value: currency,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              currency,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateCurrency(value);
                          }
                        },
                        underline: SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        focusNode: amountFocusNode,
                        decoration: InputDecoration(
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
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (selectedTab != 'Transfer') ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textFieldColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 8), // Fix: Replace 'custom' with 'bottom'
                  child: ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Category', style: AppTextStyle.regularBlack16),
                        SizedBox(width: 5),
                        Icon(Icons.chevron_right, color: AppColors.lightRed),
                        SizedBox(width: 5),
                        Text(
                          selectedCategory ?? 'Select',
                          style: AppTextStyle.mediumBlack16,
                        ),
                      ],
                    ),
                    onTap: () {
                      _dismissKeyboard(context);
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
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textFieldColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 8), // Fix: Replace 'custom' with 'bottom'
                  child: ListTile(
                    title: Row(
                      children: [
                        Text('Payment Method', style: AppTextStyle.regularBlack16),
                        SizedBox(width: 5),
                        Icon(Icons.chevron_right, color: AppColors.lightRed),
                        SizedBox(width: 5),
                        Text(
                          selectedPaymentMethod ?? 'Select',
                          style: AppTextStyle.mediumBlack16,
                        ),
                      ],
                    ),
                    onTap: () {
                      _dismissKeyboard(context);
                      Get.bottomSheet(PaymentMethodBottomSheet(
                        onMethodSelected: (method) {
                          setState(() {
                            selectedPaymentMethod = method;
                          });
                        },
                      ));
                    },
                  ),
                ),
              ] else ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textFieldColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 8), // Fix: Replace 'custom' with 'bottom'
                  child: ListTile(
                    title: Row(
                      children: [
                        Text('From', style: AppTextStyle.regularBlack16),
                        SizedBox(width: 5),
                        Icon(Icons.chevron_right, color: AppColors.lightRed),
                        SizedBox(width: 5),
                        Text(
                          fromWallet ?? 'Select',
                          style: AppTextStyle.mediumBlack16,
                        ),
                      ],
                    ),
                    onTap: () {
                      _dismissKeyboard(context);
                      Get.bottomSheet(WalletBottomSheet(
                        onWalletSelected: (wallet) {
                          setState(() {
                            fromWallet = wallet;
                          });
                        },
                      ));
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textFieldColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 8), // Fix: Replace 'custom' with 'bottom'
                  child: ListTile(
                    title: Row(
                      children: [
                        Text('To', style: AppTextStyle.regularBlack16),
                        SizedBox(width: 5),
                        Icon(Icons.chevron_right, color: AppColors.lightRed),
                        SizedBox(width: 5),
                        Text(
                          toWallet ?? 'Select',
                          style: AppTextStyle.mediumBlack16,
                        ),
                      ],
                    ),
                    onTap: () {
                      _dismissKeyboard(context);
                      Get.bottomSheet(WalletBottomSheet(
                        onWalletSelected: (wallet) {
                          setState(() {
                            toWallet = wallet;
                          });
                        },
                      ));
                    },
                  ),
                ),
              ],
              Container(
                decoration: BoxDecoration(
                  color: AppColors.textFieldColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 8), // Fix: Replace 'custom' with 'bottom'
                child: ListTile(
                  title: Row(
                    children: [
                      Text('Date', style: AppTextStyle.regularBlack16),
                      SizedBox(width: 5),
                      Icon(Icons.chevron_right, color: AppColors.lightRed),
                      SizedBox(width: 5),
                      Text(
                        DateFormat('EEE, dd/MM/yyyy').format(selectedDate),
                        style: AppTextStyle.mediumBlack16,
                      ),
                    ],
                  ),
                  onTap: () async {
                    _dismissKeyboard(context);
                    final DateTime? picked = await showRoundedDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      theme: ThemeData(
                        primaryColor: AppColors.primary,
                      ),
                      height: MediaQuery.of(context).size.height * 0.4,
                      styleDatePicker: MaterialRoundedDatePickerStyle(
                        textStyleDayButton: TextStyle(color: AppColors.white, fontSize: 20),
                        textStyleYearButton: TextStyle(color: AppColors.white, fontSize: 20),
                        textStyleDayHeader: TextStyle(color: AppColors.primary, fontSize: 14),
                        backgroundPicker: Colors.white,
                        decorationDateSelected:
                        BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        textStyleDayOnCalendarSelected: TextStyle(
                            fontSize: 14, color: AppColors.white, fontWeight: FontWeight.bold),
                        textStyleButtonPositive:
                        TextStyle(fontSize: 14, color: AppColors.primary),
                        textStyleButtonNegative: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                    await Future.delayed(Duration(milliseconds: 50));
                    _dismissKeyboard(context);
                  },
                ),
              ),
              TextField(
                focusNode: noteFocusNode,
                decoration: InputDecoration(
                  hintText: "Note",
                  hintStyle: AppTextStyle.regularBlack16
                      .copyWith(color: Color(0xffAFAFAF)),
                  filled: true,
                  fillColor: AppColors.textFieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                minLines: 3,
                maxLines: 5,
                style: AppTextStyle.regularBlack16,
                onChanged: (value) {
                  note = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
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
                  if (!isCurrencyLocked) {
                    Hive.box('settings').put('selectedCurrency', controller.selectedCurrency.value);
                    setState(() {
                      isCurrencyLocked = true;
                    });
                  }
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Center(
                  child: Text(
                    "Save",
                    style: AppTextStyle.mediumBlack16
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}