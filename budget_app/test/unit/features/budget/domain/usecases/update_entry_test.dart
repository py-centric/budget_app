import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/update_entry.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeExpenseEntry extends Fake implements ExpenseEntry {}

class FakeIncomeEntry extends Fake implements IncomeEntry {}

void main() {
  late UpdateEntry useCase;
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeExpenseEntry());
    registerFallbackValue(FakeIncomeEntry());
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    useCase = UpdateEntry(mockRepository);
  });

  group('UpdateEntry', () {
    test(
      'should call repository.updateExpense when expense is provided',
      () async {
        final expense = ExpenseEntry(
          id: '1',
          budgetId: 'budget1',
          amount: 50.0,
          categoryId: 'cat1',
          date: DateTime(2024, 1, 15),
          description: 'Test expense',
        );

        when(
          () => mockRepository.updateExpense(any()),
        ).thenAnswer((_) async {});

        await useCase.call(expense: expense);

        verify(() => mockRepository.updateExpense(expense)).called(1);
      },
    );

    test(
      'should call repository.updateIncome when income is provided',
      () async {
        final income = IncomeEntry(
          id: '1',
          budgetId: 'budget1',
          amount: 100.0,
          date: DateTime(2024, 1, 15),
          description: 'Test income',
        );

        when(() => mockRepository.updateIncome(any())).thenAnswer((_) async {});

        await useCase.call(income: income);

        verify(() => mockRepository.updateIncome(income)).called(1);
      },
    );
  });
}
