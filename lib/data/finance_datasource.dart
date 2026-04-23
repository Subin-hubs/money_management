import 'package:hive/hive.dart';
import '../models/user_finance_model.dart';

class FinanceDatasource {
  final _box = Hive.box<FinanceProfile>('finance');

  FinanceProfile? getProfile() {
    if (_box.isEmpty) return null;
    return _box.getAt(0);
  }

  Future<void> saveProfile(FinanceProfile profile) async {
    await _box.put(0, profile);
  }
}