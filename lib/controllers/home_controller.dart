import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';

class HomeController {
  final Box<TransactionModel> transactionBox =
  Hive.box<TransactionModel>('transactions');

  double get totalIncome {
    return transactionBox.values
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return transactionBox.values
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;
}