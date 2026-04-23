import '../domain/calculate_decision.dart';
import '../models/user_finance_model.dart';

class CalculatePurchaseUseCase {
  CalculationResult execute({
    required double itemPrice,
    required FinanceProfile profile,
  }) {
    final hourlyIncome = profile.hourlyIncome;
    final savings = profile.savings;
    final remainingAmount = itemPrice - savings;

    double hoursToWork;
    double savingsUsed;
    DecisionType decision;

    if (remainingAmount <= 0) {
      hoursToWork = 0;
      savingsUsed = itemPrice;
      decision = DecisionType.fromSavings;
    } else {
      hoursToWork = hourlyIncome > 0 ? remainingAmount / hourlyIncome : double.infinity;
      savingsUsed = savings;

      if (hoursToWork <= 5) {
        decision = DecisionType.easyBuy;
      } else if (hoursToWork <= 20) {
        decision = DecisionType.thinkTwice;
      } else {
        decision = DecisionType.notWorthIt;
      }
    }

    final daysToWork = hoursToWork / 8;
    final savingsImpact = savings > 0 ? (savingsUsed / savings) * 100 : 0.0;
    final remainingAfterPurchase = savings - savingsUsed;

    return CalculationResult(
      itemPrice: itemPrice,
      hoursToWork: hoursToWork,
      daysToWork: daysToWork,
      savingsImpact: savingsImpact,
      remainingAfterPurchase: remainingAfterPurchase.clamp(0, double.infinity),
      decision: decision,
      savingsUsed: savingsUsed,
    );
  }
}