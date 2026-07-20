import '../entities/spending_trend.dart';
import '../../../budget/domain/repositories/budget_repository.dart';

class CalculateSpendingTrends {
  final BudgetRepository _repository;

  CalculateSpendingTrends(this._repository);

  Future<List<SpendingTrend>> call({int months = 12}) async {
    final now = DateTime.now();
    final allExpenses = await _repository.getAllExpenses();
    final categories = await _repository.getCategories();

    final trends = <SpendingTrend>[];

    for (final category in categories.where((c) => c.type.name == 'expense')) {
      final monthlyData = <MonthlySpending>[];
      for (var i = months - 1; i >= 0; i--) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        final year = targetDate.year;
        final month = targetDate.month;
        final total = allExpenses
            .where((e) =>
                e.categoryId == category.id &&
                e.date.year == year &&
                e.date.month == month)
            .fold(0.0, (sum, e) => sum + e.amount);
        monthlyData.add(MonthlySpending(year: year, month: month, amount: total));
      }

      final nonZeroMonths = monthlyData.where((m) => m.amount > 0).toList();
      final average = nonZeroMonths.isNotEmpty
          ? nonZeroMonths.map((m) => m.amount).reduce((a, b) => a + b) / nonZeroMonths.length
          : 0.0;

      double trend = 0;
      if (monthlyData.length >= 2 && monthlyData.first.amount > 0 && monthlyData.last.amount > 0) {
        trend = ((monthlyData.last.amount - monthlyData.first.amount) / monthlyData.first.amount) * 100;
      }

      trends.add(SpendingTrend(
        categoryId: category.id,
        categoryName: category.name,
        monthlyData: monthlyData,
        averageMonthly: average,
        trendPercentage: trend,
      ));
    }

    return trends;
  }
}
