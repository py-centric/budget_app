import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/presentation/widgets/filter_models.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late MockBudgetRepository mockRepository;
  late CalculateSummary calculateSummary;

  const period = BudgetPeriod(year: 2026, month: 4);

  final testIncomes = [
    IncomeEntry(
      id: 'inc_1',
      budgetId: 'b_1',
      amount: 1000.0,
      date: DateTime(2026, 4, 1),
      accountId: 'acc_checking',
      isPotential: false,
    ),
    IncomeEntry(
      id: 'inc_2',
      budgetId: 'b_1',
      amount: 500.0,
      date: DateTime(2026, 4, 2),
      accountId: 'acc_savings',
      isPotential: false,
    ),
    IncomeEntry(
      id: 'inc_3',
      budgetId: 'b_1',
      amount: 200.0,
      date: DateTime(2026, 4, 3),
      accountId: null,
      isPotential: false,
    ),
  ];

  final testExpenses = [
    ExpenseEntry(
      id: 'exp_1',
      budgetId: 'b_1',
      amount: 300.0,
      categoryId: 'cat_rent',
      date: DateTime(2026, 4, 1),
      accountId: 'acc_checking',
      isPotential: false,
    ),
    ExpenseEntry(
      id: 'exp_2',
      budgetId: 'b_1',
      amount: 100.0,
      categoryId: 'cat_groceries',
      date: DateTime(2026, 4, 2),
      accountId: 'acc_savings',
      isPotential: false,
    ),
    ExpenseEntry(
      id: 'exp_3',
      budgetId: 'b_1',
      amount: 50.0,
      categoryId: 'cat_coffee',
      date: DateTime(2026, 4, 3),
      accountId: null,
      isPotential: false,
    ),
  ];

  setUp(() {
    mockRepository = MockBudgetRepository();
    calculateSummary = CalculateSummary(mockRepository);

    when(() => mockRepository.getIncomeForPeriod(period))
        .thenAnswer((_) async => List.from(testIncomes));
    when(() => mockRepository.getExpensesForPeriod(period))
        .thenAnswer((_) async => List.from(testExpenses));
  });

  group('CalculateSummary Account Filtering Tests', () {
    test('calculates full summary when no accountFilter is provided', () async {
      final summary = await calculateSummary(period: period);

      expect(summary.totalIncome, equals(1700.0));
      expect(summary.totalExpenses, equals(450.0));
      expect(summary.balance, equals(1250.0));
      expect(summary.incomeEntries.length, equals(3));
      expect(summary.expenseEntries.length, equals(3));
    });

    test('calculates filtered summary for specific account', () async {
      const filter = AccountFilter(selectedAccountIds: {'acc_checking'});
      final summary = await calculateSummary(
        period: period,
        accountFilter: filter,
      );

      expect(summary.totalIncome, equals(1000.0));
      expect(summary.totalExpenses, equals(300.0));
      expect(summary.balance, equals(700.0));
      expect(summary.incomeEntries.length, equals(1));
      expect(summary.expenseEntries.length, equals(1));
    });

    test('calculates filtered summary including unassigned transactions', () async {
      const filter = AccountFilter(
        selectedAccountIds: {'acc_savings'},
        includeUnassigned: true,
      );
      final summary = await calculateSummary(
        period: period,
        accountFilter: filter,
      );

      expect(summary.totalIncome, equals(700.0)); // 500 + 200
      expect(summary.totalExpenses, equals(150.0)); // 100 + 50
      expect(summary.balance, equals(550.0));
      expect(summary.incomeEntries.length, equals(2));
      expect(summary.expenseEntries.length, equals(2));
    });
  });
}
