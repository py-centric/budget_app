import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/usecases/save_recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}

class FakeRecurringTransaction extends Fake implements RecurringTransaction {}

void main() {
  late SaveRecurringTransaction useCase;
  late MockRecurringRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeRecurringTransaction());
  });

  setUp(() {
    mockRepository = MockRecurringRepository();
    useCase = SaveRecurringTransaction(mockRepository);
  });

  group('SaveRecurringTransaction', () {
    test('should call repository.saveRecurringTransaction', () async {
      final recurring = RecurringTransaction(
        id: '1',
        budgetId: 'budget1',
        type: 'EXPENSE',
        amount: 100.0,
        categoryId: 'cat1',
        description: 'Monthly rent',
        startDate: DateTime(2024, 1, 1),
        interval: 1,
        unit: RecurrenceUnit.months,
      );

      when(
        () => mockRepository.saveRecurringTransaction(any()),
      ).thenAnswer((_) async {});

      await useCase.call(recurring);

      verify(
        () => mockRepository.saveRecurringTransaction(recurring),
      ).called(1);
    });
  });
}
