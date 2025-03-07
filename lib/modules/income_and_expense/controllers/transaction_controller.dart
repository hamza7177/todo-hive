import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  void deleteTransaction(String id) {
    _db.deleteTransaction(id);
    loadTransactions();
  }

  Map<String, Map<String, dynamic>> get groupedTransactions {
    Map<String, Map<String, dynamic>> grouped = {};

    for (var transaction in transactions) {
      String dateKey = DateFormat('EEE dd/MM/yyyy').format(transaction.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {
          'transactions': [],
          'total': 0.0,
        };
      }

      grouped[dateKey]!['transactions'].add(transaction);
      grouped[dateKey]!['total'] += transaction.amount; // Sum daily total
    }

    return grouped;
  }


  void updateFilter(String newFilter) {
    filter.value = newFilter;
    // Add logic to filter transactions based on Daily/Weekly/Monthly/Yearly
  }
}