import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_override.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}

class FakeRecurringTransaction extends Fake implements RecurringTransaction {}

class FakeRecurringOverride extends Fake implements RecurringOverride {}

void main() {
  late MockRecurringRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeRecurringTransaction());
    registerFallbackValue(FakeRecurringOverride());
  });

  setUp(() {
    mockRepository = MockRecurringRepository();
  });

  group('RecurringRepository', () {
    test(
      'getAllRecurringTransactions should return list of transactions',
      () async {
        final transactions = [
          RecurringTransaction(
            id: '1',
            budgetId: 'b-1',
            type: 'INCOME',
            amount: 1000.0,
            categoryId: 'cat-1',
            description: 'Monthly Salary',
            startDate: DateTime(2024, 1, 1),
            interval: 1,
            unit: RecurrenceUnit.months,
          ),
        ];

        when(
          () => mockRepository.getAllRecurringTransactions(),
        ).thenAnswer((_) async => transactions);

        final result = await mockRepository.getAllRecurringTransactions();

        expect(result, transactions);
        expect(result.length, 1);
        expect(result.first.description, 'Monthly Salary');
      },
    );

    test('getRecurringTransactionById should return transaction', () async {
      final transaction = RecurringTransaction(
        id: '1',
        budgetId: 'b-1',
        type: 'EXPENSE',
        amount: 500.0,
        categoryId: 'cat-2',
        description: 'Rent',
        startDate: DateTime(2024, 1, 1),
        interval: 1,
        unit: RecurrenceUnit.months,
      );

      when(
        () => mockRepository.getRecurringTransactionById('1'),
      ).thenAnswer((_) async => transaction);

      final result = await mockRepository.getRecurringTransactionById('1');

      expect(result, transaction);
      expect(result!.id, '1');
    });

    test(
      'getRecurringTransactionById should return null for unknown id',
      () async {
        when(
          () => mockRepository.getRecurringTransactionById('unknown'),
        ).thenAnswer((_) async => null);

        final result = await mockRepository.getRecurringTransactionById(
          'unknown',
        );

        expect(result, isNull);
      },
    );

    test('saveRecurringTransaction should call repository', () async {
      when(
        () => mockRepository.saveRecurringTransaction(any()),
      ).thenAnswer((_) async {});

      final transaction = RecurringTransaction(
        id: '1',
        budgetId: 'b-1',
        type: 'INCOME',
        amount: 1000.0,
        categoryId: 'cat-1',
        description: 'Test',
        startDate: DateTime(2024, 1, 1),
        interval: 1,
        unit: RecurrenceUnit.months,
      );

      await mockRepository.saveRecurringTransaction(transaction);

      verify(
        () => mockRepository.saveRecurringTransaction(transaction),
      ).called(1);
    });

    test('deleteRecurringTransaction should call repository', () async {
      when(
        () => mockRepository.deleteRecurringTransaction('1'),
      ).thenAnswer((_) async {});

      await mockRepository.deleteRecurringTransaction('1');

      verify(() => mockRepository.deleteRecurringTransaction('1')).called(1);
    });

    test('getOverridesForTemplate should return overrides', () async {
      final overrides = [
        RecurringOverride(
          id: '1',
          recurringTransactionId: 't-1',
          targetDate: DateTime(2024, 1, 15),
          newAmount: 1500.0,
        ),
      ];

      when(
        () => mockRepository.getOverridesForTemplate('t-1'),
      ).thenAnswer((_) async => overrides);

      final result = await mockRepository.getOverridesForTemplate('t-1');

      expect(result, overrides);
      expect(result.length, 1);
    });

    test('getAllOverrides should return all overrides', () async {
      final overrides = [
        RecurringOverride(
          id: '1',
          recurringTransactionId: 't-1',
          targetDate: DateTime(2024, 1, 15),
          newAmount: 1500.0,
        ),
        RecurringOverride(
          id: '2',
          recurringTransactionId: 't-2',
          targetDate: DateTime(2024, 2, 10),
          newAmount: 200.0,
        ),
      ];

      when(
        () => mockRepository.getAllOverrides(),
      ).thenAnswer((_) async => overrides);

      final result = await mockRepository.getAllOverrides();

      expect(result, overrides);
      expect(result.length, 2);
    });

    test('saveRecurringOverride should call repository', () async {
      when(
        () => mockRepository.saveRecurringOverride(any()),
      ).thenAnswer((_) async {});

      final override = RecurringOverride(
        id: '1',
        recurringTransactionId: 't-1',
        targetDate: DateTime(2024, 1, 15),
        newAmount: 1500.0,
      );

      await mockRepository.saveRecurringOverride(override);

      verify(() => mockRepository.saveRecurringOverride(override)).called(1);
    });
  });
}
