import 'package:equatable/equatable.dart';

class SpendingTrend extends Equatable {
  final String categoryId;
  final String categoryName;
  final List<MonthlySpending> monthlyData;
  final double averageMonthly;
  final double trendPercentage;

  const SpendingTrend({
    required this.categoryId,
    required this.categoryName,
    required this.monthlyData,
    required this.averageMonthly,
    required this.trendPercentage,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, monthlyData, averageMonthly, trendPercentage];
}

class MonthlySpending extends Equatable {
  final int year;
  final int month;
  final double amount;

  const MonthlySpending({required this.year, required this.month, required this.amount});

  @override
  List<Object?> get props => [year, month, amount];
}
