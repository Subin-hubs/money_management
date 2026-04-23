import 'package:hive/hive.dart';
import 'transaction_type.dart';
import 'category_model.dart';

part 'transaction.g.dart';

@HiveType(typeId: 10) // FIXED (was 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final TransactionType type;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final CategoryModel category;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? note;

  TransactionModel({
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  @override
  String toString() {
    return 'TransactionModel(type: $type, amount: $amount, category: $category, date: $date, note: $note)';
  }
}