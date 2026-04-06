import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/apply_recurring_override.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_override.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}

class FakeRecurringOverride extends Fake implements RecurringOverride {}

void main() {
  late ApplyRecurringOverride usecase;
  late MockRecurringRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeRecurringOverride());
  });

  setUp(() {
    mockRepository = MockRecurringRepository();
    usecase = ApplyRecurringOverride(mockRepository);
  });

  group('ApplyRecurringOverride', () {
    test('should save override to repository', () async {
      final override = RecurringOverride(
        id: '1',
        recurringTransactionId: 't-1',
        targetDate: DateTime(2024, 1, 15),
        newAmount: 1500.0,
      );

      when(
        () => mockRepository.saveRecurringOverride(any()),
      ).thenAnswer((_) async {});

      await usecase.call(override);

      verify(() => mockRepository.saveRecurringOverride(override)).called(1);
    });

    test('should save override with isDeleted flag', () async {
      final override = RecurringOverride(
        id: '1',
        recurringTransactionId: 't-1',
        targetDate: DateTime(2024, 2, 1),
        isDeleted: true,
      );

      when(
        () => mockRepository.saveRecurringOverride(any()),
      ).thenAnswer((_) async {});

      await usecase.call(override);

      verify(() => mockRepository.saveRecurringOverride(override)).called(1);
    });

    test('should save override with newDate', () async {
      final override = RecurringOverride(
        id: '1',
        recurringTransactionId: 't-1',
        targetDate: DateTime(2024, 1, 1),
        newDate: DateTime(2024, 1, 15),
      );

      when(
        () => mockRepository.saveRecurringOverride(any()),
      ).thenAnswer((_) async {});

      await usecase.call(override);

      verify(() => mockRepository.saveRecurringOverride(override)).called(1);
    });
  });
}
