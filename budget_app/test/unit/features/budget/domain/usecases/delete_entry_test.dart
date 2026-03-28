import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/delete_entry.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late DeleteEntry useCase;
  late MockBudgetRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetRepository();
    useCase = DeleteEntry(mockRepository);
  });

  group('DeleteEntry', () {
    test('should call repository.deleteIncome for income type', () async {
      when(() => mockRepository.deleteIncome(any())).thenAnswer((_) async {});

      await useCase.call('entry1', EntryType.income);

      verify(() => mockRepository.deleteIncome('entry1')).called(1);
    });

    test('should call repository.deleteExpense for expense type', () async {
      when(() => mockRepository.deleteExpense(any())).thenAnswer((_) async {});

      await useCase.call('entry1', EntryType.expense);

      verify(() => mockRepository.deleteExpense('entry1')).called(1);
    });
  });
}
