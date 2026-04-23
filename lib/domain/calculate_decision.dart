enum DecisionType { easyBuy, thinkTwice, notWorthIt, fromSavings }

class CalculationResult {
  final double itemPrice;
  final double hoursToWork;
  final double daysToWork;
  final double savingsImpact;
  final double remainingAfterPurchase;
  final DecisionType decision;
  final double savingsUsed;

  const CalculationResult({
    required this.itemPrice,
    required this.hoursToWork,
    required this.daysToWork,
    required this.savingsImpact,
    required this.remainingAfterPurchase,
    required this.decision,
    required this.savingsUsed,
  });

  String get decisionLabel {
    switch (decision) {
      case DecisionType.easyBuy:
        return 'Easy Buy';
      case DecisionType.thinkTwice:
        return 'Think Twice';
      case DecisionType.notWorthIt:
        return "Don't Buy";
      case DecisionType.fromSavings:
        return 'Covered by Savings';
    }
  }

  String get emotionalMessage {
    switch (decision) {
      case DecisionType.fromSavings:
        return "Great news — your savings fully cover this. Zero hours of your life needed.";
      case DecisionType.easyBuy:
        return "This costs you ${hoursToWork.toStringAsFixed(1)} hours of your life. Totally manageable.";
      case DecisionType.thinkTwice:
        return "This purchase costs you ${hoursToWork.toStringAsFixed(1)} hours of your life — that's ${daysToWork.toStringAsFixed(1)} working days. Still worth it?";
      case DecisionType.notWorthIt:
        return "You'd spend ${hoursToWork.toStringAsFixed(1)} hours — ${daysToWork.toStringAsFixed(1)} working days — just to afford this. Is it really worth your time?";
    }
  }

  String get subMessage {
    switch (decision) {
      case DecisionType.fromSavings:
        return "Your financial health stays intact.";
      case DecisionType.easyBuy:
        return "Go for it — your finances can handle this.";
      case DecisionType.thinkTwice:
        return "Take a moment before you decide.";
      case DecisionType.notWorthIt:
        return "We'd recommend skipping this one.";
    }
  }
}