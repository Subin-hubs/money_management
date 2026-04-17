import 'package:flutter/material.dart';
import 'package:money_manage/pages/navbar/navbar.dart';

import 'features/notficatation/notificatation_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/category_model.dart';
import 'models/transaction.dart';
import 'models/transaction_type.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  await Hive.initFlutter();


  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<TransactionModel>('pending_transactions');


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: NavbarSide(0),
    );
  }
}