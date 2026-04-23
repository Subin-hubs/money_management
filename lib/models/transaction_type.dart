import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/app_colors.dart';

part 'transaction_type.g.dart';

@HiveType(typeId: 12) // FIXED (must be unique)
enum TransactionType {
  @HiveField(0)
  expense,

  @HiveField(1)
  income
}

extension TransactionTypeX on TransactionType {
  String get label =>
      this == TransactionType.expense ? '↓ Expense' : '↑ Income';

  String get amountLabel =>
      this == TransactionType.expense ? 'Total Expense' : 'Total Income';

  Color get accentColor =>
      this == TransactionType.expense ? AppColors.expense : AppColors.income;

  Color get lightColor =>
      this == TransactionType.expense
          ? AppColors.expenseLight
          : AppColors.incomeLight;
}