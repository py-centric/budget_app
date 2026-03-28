import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/add_expense.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeExpenseEntry extends Fake implements ExpenseEntry {}

void main() {
  late AddExpense useCase;
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeExpenseEntry());
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    useCase = AddExpense(mockRepository);
  });

  group('AddExpense', () {
    test('should call repository.addExpense with the given expense', () async {
      final expense = ExpenseEntry(
        id: '1',
        budgetId: 'budget1',
        amount: 50.0,
        categoryId: 'cat1',
        date: DateTime(2024, 1, 15),
        description: 'Test expense',
      );

      when(() => mockRepository.addExpense(any())).thenAnswer((_) async {});

      await useCase.call(expense);

      verify(() => mockRepository.addExpense(expense)).called(1);
    });
  });
}
