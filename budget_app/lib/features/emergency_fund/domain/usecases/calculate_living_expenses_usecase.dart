import 'package:budget_app/features/emergency_fund/domain/repositories/emergency_fund_repository.dart';

class CalculateLivingExpensesUseCase {
  final EmergencyFundRepository _repository;

  CalculateLivingExpensesUseCase(this._repository);

  Future<double> execute(int months) async {
    final average = await _repository.getAverageMonthlySpending();
    return average * months;
  }
}
