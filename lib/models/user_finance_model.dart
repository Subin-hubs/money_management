import 'package:hive/hive.dart';

part 'user_finance_model.g.dart';

@HiveType(typeId: 13)
enum IncomeType {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,
}

@HiveType(typeId: 14) // FIXED (was 1 ❌)
class FinanceProfile extends HiveObject {
  @HiveField(0)
  double income;

  @HiveField(1)
  IncomeType incomeType;

  @HiveField(2)
  double savings;

  FinanceProfile({
    required this.income,
    required this.incomeType,
    required this.savings,
  });

  double get hourlyIncome {
    switch (incomeType) {
      case IncomeType.daily:
        return income / 8;
      case IncomeType.weekly:
        return income / 56;
      case IncomeType.monthly:
        return income / 240;
    }
  }

  String get incomeTypeLabel {
    switch (incomeType) {
      case IncomeType.daily:
        return 'Daily';
      case IncomeType.weekly:
        return 'Weekly';
      case IncomeType.monthly:
        return 'Monthly';
    }
  }
}