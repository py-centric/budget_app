import '../entities/debt_payoff_plan.dart';

class CalculateDebtPayoff {
  DebtPayoffPlan call({
    required List<DebtInput> debts,
    required double monthlyPayment,
    required PayoffStrategy strategy,
  }) {
    final sortedDebts = List<DebtInput>.from(debts);
    if (strategy == PayoffStrategy.snowball) {
      sortedDebts.sort((a, b) => a.balance.compareTo(b.balance));
    } else if (strategy == PayoffStrategy.avalanche) {
      sortedDebts.sort((a, b) => b.apr.compareTo(a.apr));
    }

    final items = <DebtPayoffItem>[];
    var remainingPayment = monthlyPayment;
    var totalMonths = 0;
    var totalInterest = 0.0;
    var totalPaid = 0.0;

    for (var order = 0; order < sortedDebts.length; order++) {
      final debt = sortedDebts[order];
      var balance = debt.balance;
      var months = 0;
      var interest = 0.0;
      final monthlyRate = debt.apr / 100 / 12;
      final minPayment = debt.minimumPayment;

      while (balance > 0 && months < 600) {
        final interestThisMonth = balance * monthlyRate;
        interest += interestThisMonth;
        balance += interestThisMonth;

        final payment = order == 0
            ? (remainingPayment > balance ? balance : remainingPayment)
            : (minPayment > balance ? balance : minPayment);

        balance -= payment;
        totalPaid += payment;
        months++;
      }

      totalMonths = totalMonths > months ? totalMonths : months;
      totalInterest += interest;

      items.add(DebtPayoffItem(
        name: debt.name,
        balance: debt.balance,
        apr: debt.apr,
        minimumPayment: debt.minimumPayment,
        payoffOrder: order + 1,
        monthsToPayoff: months,
        interestPaid: interest,
      ));

      if (order == 0) {
        remainingPayment += items.first.minimumPayment;
      }
    }

    return DebtPayoffPlan(
      strategy: strategy,
      debts: items,
      monthlyPayment: monthlyPayment,
      totalMonths: totalMonths,
      totalInterest: totalInterest,
      totalPaid: totalPaid,
    );
  }
}

class DebtInput {
  final String name;
  final double balance;
  final double apr;
  final double minimumPayment;

  const DebtInput({
    required this.name,
    required this.balance,
    required this.apr,
    required this.minimumPayment,
  });
}
