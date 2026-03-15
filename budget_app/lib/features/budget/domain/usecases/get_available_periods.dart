import '../entities/budget_period.dart';
import '../repositories/budget_repository.dart';

class GetAvailablePeriods {
  final BudgetRepository _repository;

  GetAvailablePeriods(this._repository);

  Future<List<BudgetPeriod>> call() async {
    final periods = await _repository.getAvailablePeriods();
    
    final currentPeriod = BudgetPeriod.current();
    final nextPeriod = currentPeriod.next;

    if (!periods.contains(currentPeriod)) {
      periods.add(currentPeriod);
    }
    if (!periods.contains(nextPeriod)) {
      periods.add(nextPeriod);
    }

    periods.sort((a, b) => b.compareTo(a)); // Descending order

    return periods;
  }
}
