import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_projection.dart';
import 'package:budget_app/features/budget/data/models/user_settings.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}
class MockRecurringRepository extends Mock implements RecurringRepository {}

void main() {
  late MockBudgetRepository repository;
  late MockRecurringRepository recurringRepository;
  late CalculateProjection usecase;

  setUp(() {
    repository = MockBudgetRepository();
    recurringRepository = MockRecurringRepository();
    usecase = CalculateProjection(repository, recurringRepository);
  });

  final today = DateTime(2026, 3, 15);

  test('calculates correct starting balance and points for MONTH horizon without actuals', () async {
    when(() => repository.getIncomeBefore(today)).thenAnswer((_) async => [
      IncomeEntry(id: '1', budgetId: 'default', amount: 1000.0, date: DateTime(2026, 3, 1)),
    ]);
    when(() => repository.getExpensesBefore(today)).thenAnswer((_) async => [
      ExpenseEntry(id: '2', budgetId: 'default', amount: 300.0, categoryId: 'Food', date: DateTime(2026, 3, 5)),
    ]);
    
    when(() => repository.getIncomeForDateRange(any(), any())).thenAnswer((_) async => [
      IncomeEntry(id: '3', budgetId: 'default', amount: 500.0, date: DateTime(2026, 3, 20)),
    ]);
    when(() => repository.getExpensesForDateRange(any(), any())).thenAnswer((_) async => [
      ExpenseEntry(id: '4', budgetId: 'default', amount: 100.0, categoryId: 'Food', date: DateTime(2026, 3, 16)),
    ]);

    when(() => recurringRepository.getAllRecurringTransactions()).thenAnswer((_) async => []);
    when(() => recurringRepository.getAllOverrides()).thenAnswer((_) async => []);

    final settings = const UserSettings(defaultProjectionHorizon: 'MONTH');

    final points = await usecase(
      settings: settings,
      showActuals: false,
      today: today,
    );

    // Month ends on 31st. From 15th to 31st = 17 days.
    expect(points.length, 17);
    
    // Starting balance = 1000 - 300 = 700
    // On 15th, no new transactions -> 700
    expect(points.first.balance, 700.0);
    
    // On 16th, 100 expense -> 600
    expect(points[1].balance, 600.0);
    
    // On 20th, 500 income -> 1100
    expect(points[5].balance, 1100.0);
    
    // Ending balance -> 1100
    expect(points.last.balance, 1100.0);
  });
}
