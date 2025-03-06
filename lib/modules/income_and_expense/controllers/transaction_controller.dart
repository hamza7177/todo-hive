import 'package:get/get.dart';
import '../database_service/database_service.dart';
import '../models/transaction.dart';

class TransactionController extends GetxController {
  final DatabaseService _db = DatabaseService();
  RxList<Transaction> transactions = <Transaction>[].obs;
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  RxString filter = 'Daily'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    transactions.value = _db.getAllTransactions();
    calculateTotals();
  }

  void calculateTotals() {
    totalIncome.value = transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
    totalExpense.value = transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  void addTransaction(Transaction t) {
    _db.addTransaction(t);
    loadTransactions();
  }

  void updateFilter(String newFilter) {
    filter.value = newFilter;
    // Add logic to filter transactions based on Daily/Weekly/Monthly/Yearly
  }
}