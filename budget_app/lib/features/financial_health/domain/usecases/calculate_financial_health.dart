import '../entities/financial_health_score.dart';

class CalculateFinancialHealth {
  const CalculateFinancialHealth();

  Future<FinancialHealthScore> call({
    required double monthlyIncome,
    required double monthlyExpenses,
    required double totalDebt,
    required double totalSavings,
  }) async {
    final savingsRate = monthlyIncome > 0
        ? ((monthlyIncome - monthlyExpenses) / monthlyIncome * 100)
        : 0.0;

    final debtToIncome = monthlyIncome > 0
        ? (totalDebt / monthlyIncome * 100)
        : totalDebt > 0 ? 100.0 : 0.0;

    final emergencyFundMonths = monthlyExpenses > 0
        ? totalSavings / monthlyExpenses
        : 0.0;

    final savingsGrade = _gradeSavingsRate(savingsRate);
    final debtGrade = _gradeDebtToIncome(debtToIncome);
    final emergencyGrade = _gradeEmergencyFund(emergencyFundMonths);

    final score = _calculateOverallScore(savingsRate, debtToIncome, emergencyFundMonths);
    final overallGrade = _gradeOverall(score);

    return FinancialHealthScore(
      savingsRate: savingsRate,
      savingsRateGrade: savingsGrade,
      debtToIncomeRatio: debtToIncome,
      debtToIncomeGrade: debtGrade,
      emergencyFundMonths: emergencyFundMonths,
      emergencyFundGrade: emergencyGrade,
      overallScore: score,
      overallGrade: overallGrade,
      totalIncome: monthlyIncome,
      totalExpenses: monthlyExpenses,
      totalDebt: totalDebt,
      totalSavings: totalSavings,
    );
  }

  HealthMetricType _gradeSavingsRate(double rate) {
    if (rate >= 20) return HealthMetricType.excellent;
    if (rate >= 10) return HealthMetricType.good;
    if (rate >= 0) return HealthMetricType.fair;
    return HealthMetricType.poor;
  }

  HealthMetricType _gradeDebtToIncome(double ratio) {
    if (ratio <= 10) return HealthMetricType.excellent;
    if (ratio <= 20) return HealthMetricType.good;
    if (ratio <= 36) return HealthMetricType.fair;
    return HealthMetricType.poor;
  }

  HealthMetricType _gradeEmergencyFund(double months) {
    if (months >= 6) return HealthMetricType.excellent;
    if (months >= 3) return HealthMetricType.good;
    if (months >= 1) return HealthMetricType.fair;
    return HealthMetricType.poor;
  }

  int _calculateOverallScore(double savingsRate, double debtToIncome, double emergencyMonths) {
    int score = 50;
    if (savingsRate >= 20) {
      score += 20;
    } else if (savingsRate >= 10) {
      score += 10;
    } else if (savingsRate < 0) {
      score -= 20;
    }

    if (debtToIncome <= 10) {
      score += 15;
    } else if (debtToIncome <= 20) {
      score += 5;
    } else if (debtToIncome > 36) {
      score -= 15;
    }

    if (emergencyMonths >= 6) {
      score += 15;
    } else if (emergencyMonths >= 3) {
      score += 5;
    } else if (emergencyMonths < 1) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }

  HealthMetricType _gradeOverall(int score) {
    if (score >= 80) return HealthMetricType.excellent;
    if (score >= 60) return HealthMetricType.good;
    if (score >= 40) return HealthMetricType.fair;
    return HealthMetricType.poor;
  }
}
