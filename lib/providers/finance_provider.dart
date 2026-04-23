import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/finance_datasource.dart';
import '../domain/calculate_decision.dart';
import '../models/user_finance_model.dart';
import 'calculator_provider.dart';

// ─────────────────────────────────────────────
// Datasource
// ─────────────────────────────────────────────
final financeDatasourceProvider = Provider<FinanceDatasource>((ref) {
  return FinanceDatasource();
});

// ─────────────────────────────────────────────
// Finance Profile State
// ─────────────────────────────────────────────
class FinanceProfileNotifier extends StateNotifier<FinanceProfile?> {
  final FinanceDatasource _datasource;

  FinanceProfileNotifier(this._datasource) : super(null) {
    _load();
  }

  void _load() {
    state = _datasource.getProfile();
  }

  Future<void> saveProfile({
    required double income,
    required IncomeType incomeType,
    required double savings,
  }) async {
    final profile = FinanceProfile(
      income: income,
      incomeType: incomeType,
      savings: savings,
    );

    await _datasource.saveProfile(profile);
    state = profile;
  }

  Future<void> updateProfile({
    required double income,
    required IncomeType incomeType,
    required double savings,
  }) {
    return saveProfile(
      income: income,
      incomeType: incomeType,
      savings: savings,
    );
  }

  bool get hasProfile => state != null;
}

final financeProfileProvider =
StateNotifierProvider<FinanceProfileNotifier, FinanceProfile?>((ref) {
  final datasource = ref.watch(financeDatasourceProvider);
  return FinanceProfileNotifier(datasource);
});

// ─────────────────────────────────────────────
// Calculation State
// ─────────────────────────────────────────────
class CalculationNotifier extends StateNotifier<CalculationResult?> {
  final CalculatePurchaseUseCase _useCase;

  CalculationNotifier(this._useCase) : super(null);

  void calculate({
    required double itemPrice,
    required FinanceProfile profile,
  }) {
    state = _useCase.execute(
      itemPrice: itemPrice,
      profile: profile,
    );
  }

  void reset() {
    state = null;
  }
}

final calculationUseCaseProvider =
Provider<CalculatePurchaseUseCase>((ref) {
  return CalculatePurchaseUseCase();
});

final calculationProvider =
StateNotifierProvider<CalculationNotifier, CalculationResult?>((ref) {
  final useCase = ref.read(calculationUseCaseProvider);
  return CalculationNotifier(useCase);
});