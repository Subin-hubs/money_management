import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:money_manage/pages/navbar/navbar.dart';

import 'features/notficatation/noti_bridge.dart';
import 'features/notficatation/notificatation_service.dart';

import 'models/category_model.dart';
import 'models/transaction.dart';
import 'models/transaction_type.dart';
import 'models/user_finance_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // 🔥 ADAPTERS
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(IncomeTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(FinanceProfileAdapter()); // FIXED

  // 🔥 BOXES
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<TransactionModel>('pending_transactions');
  await Hive.openBox<FinanceProfile>('finance');

  // 🔔 INIT SERVICES
  await NotificationService.init();
  NotiBridge.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Manage',
      home: NavbarSide(0),
    );
  }
}