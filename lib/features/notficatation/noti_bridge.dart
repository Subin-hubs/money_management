import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../models/category_model.dart';
import '../../models/transaction.dart';
import '../../models/transaction_type.dart';

class NotiBridge {
  static const MethodChannel _channel = MethodChannel('noti_channel');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onNotification") {
        final data = Map<String, dynamic>.from(call.arguments);

        print("🔥 FROM ANDROID: $data");

        final box = Hive.box<TransactionModel>('pending_transactions');

        final amount =
            double.tryParse(data['amount'].toString()) ?? 0;

        print("💰 PARSED AMOUNT: $amount");

        final tx = TransactionModel(
          type: TransactionType.expense,
          amount: amount,
          category: CategoryModel(
            label: "Auto Detected",
            iconCode: 0xe3f4, // notification icon
            colorValue: 0xFFFF9800,
          ),
          date: DateTime.now(),
          note: data['text'],
        );

        await box.add(tx);
      }
    });
  }
}