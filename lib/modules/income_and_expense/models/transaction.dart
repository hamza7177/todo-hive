import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 10)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String type; // 'income', 'expense', 'transfer'

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final String? paymentMethod;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final String? fromWallet; // For transfer

  @HiveField(8)
  final String? toWallet; // For transfer

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    this.category,
    this.paymentMethod,
    this.note,
    this.fromWallet,
    this.toWallet,
  });
}