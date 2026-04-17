import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';

class AddTransactionController extends ChangeNotifier {
  // ── State ─────────────────────────────────────
  TransactionType _type            = TransactionType.expense;
  int             _selectedCategory = 0;
  DateTime        _date             = DateTime.now();
  String          _amount           = '';
  String          _note             = '';

  // ── Getters ───────────────────────────────────
  TransactionType   get type             => _type;
  int               get selectedCategory => _selectedCategory;
  DateTime          get date             => _date;
  String            get amount           => _amount;
  String            get note             => _note;

  // This is the line that fixes your error!
  bool get hasAmount => _amount.trim().isNotEmpty;

  List<CategoryModel> get categories => AppCategories.forType(_type);
  CategoryModel get currentCategory => categories[_selectedCategory];

  // ── Setters ───────────────────────────────────
  void setType(TransactionType type) {
    if (_type == type) return;
    _type             = type;
    _selectedCategory = 0;
    notifyListeners();
  }

  void setCategory(int index) {
    _selectedCategory = index;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  void setAmount(String value) {
    _amount = value;
    notifyListeners();
  }

  void setNote(String value) {
    _note = value;
  }

  // ── Validation ────────────────────────────────
  String? validate() {
    if (_amount.trim().isEmpty) return 'Please enter an amount';
    final parsed = double.tryParse(_amount.trim());
    if (parsed == null || parsed <= 0) return 'Please enter a valid amount';
    return null;
  }

  // ── Hive Save Logic ───────────────────────────
  Future<bool> saveTransaction() async {
    final validationError = validate();
    if (validationError != null) return false;

    final parsedAmount = double.tryParse(_amount.trim());
    if (parsedAmount == null) return false;

    final transaction = TransactionModel(
      type:     _type,
      amount:   parsedAmount,
      category: currentCategory,
      date:     _date,
      note:     _note.trim().isEmpty ? null : _note.trim(),
    );

    try {
      final box = Hive.box<TransactionModel>('transactions');
      await box.add(transaction);
      return true;
    } catch (e) {
      debugPrint('Hive Save Error: $e');
      return false;
    }
  }
}