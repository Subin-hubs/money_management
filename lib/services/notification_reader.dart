import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/category_model.dart';

class NotificationReader {
  static const String _portName = 'notification_listener_port';

  static void initialize() async {
    bool? hasPermission = await NotificationsListener.hasPermission;
    if (!hasPermission!) {
      await NotificationsListener.openPermissionSettings();
    }

    // Initialize the listener
    NotificationsListener.initialize(callbackHandle: _onNotificationBackground);

    // Setup a port to communicate with the UI
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((event) {
      // This is triggered when a new notification is parsed
      print("New Transaction Captured: ${event.text}");
    });
  }

  // This runs in the BACKGROUND even when the app is closed
  @pragma('vm:entry-point')
  static void _onNotificationBackground(NotificationEvent event) async {
    final String title = event.title?.toLowerCase() ?? "";
    final String text = event.text?.toLowerCase() ?? "";
    final String fullContent = "$title $text";

    // 1. Regex for Nepali Money (NPR 500, Rs. 500, Rs 500)
    RegExp amountRegex = RegExp(r'(?:npr|rs\.?|nrs)\s?(\d+(?:,\d+)*(?:\.\d+)?)');
    var match = amountRegex.firstMatch(fullContent);

    if (match != null) {
      double amount = double.parse(match.group(1)!.replaceAll(',', ''));

      // 2. Identify Type for Nepal Banks (Debited = Expense, Credited = Income)
      TransactionType type = TransactionType.expense;
      if (fullContent.contains('credited') || fullContent.contains('received')) {
        type = TransactionType.income;
      }

      // 3. Save to a "Pending" Box so user can confirm it later
      final pendingTx = TransactionModel(
        type: type,
        amount: amount,
        category: AppCategories.expense.last, // Default to 'Others'
        date: DateTime.now(),
        note: "From ${event.title}",
      );

      // We use a separate box for 'unconfirmed' items
      var box = await Hive.openBox<TransactionModel>('pending_transactions');
      await box.add(pendingTx);
    }
  }
}