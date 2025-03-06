import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class DatabaseService {
  static const String boxName = 'transactions';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    await Hive.openBox<Transaction>(boxName);
  }

  Box<Transaction> get _transactionBox => Hive.box<Transaction>(boxName);

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  List<Transaction> getAllTransactions() => _transactionBox.values.toList();

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }
}