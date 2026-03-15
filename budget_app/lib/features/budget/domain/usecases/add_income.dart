import '../entities/income_entry.dart';
import '../repositories/budget_repository.dart';

class AddIncome {
  final BudgetRepository repository;

  AddIncome(this.repository);

  Future<void> call(IncomeEntry income) async {
    await repository.addIncome(income);
  }
}
