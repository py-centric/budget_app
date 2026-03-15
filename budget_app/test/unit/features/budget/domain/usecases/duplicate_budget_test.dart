import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/duplicate_budget.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}
class FakeBudget extends Fake implements Budget {}
class FakeIncomeEntry extends Fake implements IncomeEntry {}
class FakeExpenseEntry extends Fake implements ExpenseEntry {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBudget());
    registerFallbackValue(FakeIncomeEntry());
    registerFallbackValue(FakeExpenseEntry());
  });

  late MockBudgetRepository mockRepository;
  late DuplicateBudget usecase;

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = DuplicateBudget(mockRepository);
  });

  final sourceBudget = const Budget(id: 's1', name: 'Source', periodMonth: 1, periodYear: 2026);
  final targetPeriod = const BudgetPeriod(year: 2026, month: 2);

  test('duplicates budget structure without transactions', () async {
    when(() => mockRepository.addBudget(any())).thenAnswer((_) async {});

    final newBudget = await usecase(
      sourceBudget: sourceBudget,
      targetPeriod: targetPeriod,
      newName: 'New Budget',
      includeTransactions: false,
    );

    expect(newBudget.name, 'New Budget');
    expect(newBudget.periodMonth, 2);
    expect(newBudget.periodYear, 2026);
    
    verify(() => mockRepository.addBudget(newBudget)).called(1);
    verifyNever(() => mockRepository.getIncomeForBudget(any()));
  });

  test('duplicates budget structure and transactions', () async {
    when(() => mockRepository.addBudget(any())).thenAnswer((_) async {});
    when(() => mockRepository.getIncomeForBudget('s1')).thenAnswer((_) async => [
      IncomeEntry(id: 'i1', budgetId: 's1', amount: 100, date: DateTime(2026, 1, 15)),
    ]);
    when(() => mockRepository.getExpensesForBudget('s1')).thenAnswer((_) async => [
      ExpenseEntry(id: 'e1', budgetId: 's1', amount: 50, categoryId: 'c1', date: DateTime(2026, 1, 31)), // Jan 31
    ]);
    when(() => mockRepository.addIncome(any())).thenAnswer((_) async {});
    when(() => mockRepository.addExpense(any())).thenAnswer((_) async {});

    final newBudget = await usecase(
      sourceBudget: sourceBudget,
      targetPeriod: targetPeriod,
      newName: '',
      includeTransactions: true,
    );

    expect(newBudget.name, 'Source - Copy');
    
    // Verify income copied
    final capturedIncome = verify(() => mockRepository.addIncome(captureAny())).captured.first as IncomeEntry;
    expect(capturedIncome.amount, 100);
    expect(capturedIncome.date, DateTime(2026, 2, 15)); // Date shifted

    // Verify expense copied with month-end clamp
    final capturedExpense = verify(() => mockRepository.addExpense(captureAny())).captured.first as ExpenseEntry;
    expect(capturedExpense.amount, 50);
    expect(capturedExpense.date, DateTime(2026, 2, 28)); // Clamped to Feb 28
  });
}
