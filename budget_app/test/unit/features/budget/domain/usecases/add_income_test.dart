import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/add_income.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeIncomeEntry extends Fake implements IncomeEntry {}

void main() {
  late AddIncome useCase;
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeIncomeEntry());
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    useCase = AddIncome(mockRepository);
  });

  group('AddIncome', () {
    test('should call repository.addIncome with the given income', () async {
      final income = IncomeEntry(
        id: '1',
        budgetId: 'budget1',
        amount: 100.0,
        date: DateTime(2024, 1, 15),
        description: 'Test income',
      );

      when(() => mockRepository.addIncome(any())).thenAnswer((_) async {});

      await useCase.call(income);

      verify(() => mockRepository.addIncome(income)).called(1);
    });
  });
}
