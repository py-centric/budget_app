import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/usecases/get_available_periods.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late GetAvailablePeriods useCase;
  late MockBudgetRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetRepository();
    useCase = GetAvailablePeriods(mockRepository);
  });

  group('GetAvailablePeriods', () {
    test(
      'should return periods from repository with current and next period added',
      () async {
        final existingPeriod = BudgetPeriod(year: 2024, month: 1);
        when(
          () => mockRepository.getAvailablePeriods(),
        ).thenAnswer((_) async => [existingPeriod]);

        final result = await useCase.call();

        expect(result.contains(existingPeriod), true);
        expect(result.contains(BudgetPeriod.current()), true);
        expect(result.contains(BudgetPeriod.current().next), true);
      },
    );

    test('should sort periods in descending order', () async {
      final period1 = BudgetPeriod(year: 2026, month: 3);
      final period2 = BudgetPeriod(year: 2026, month: 1);

      when(
        () => mockRepository.getAvailablePeriods(),
      ).thenAnswer((_) async => [period1, period2]);

      final result = await useCase.call();

      expect(result.first.year, 2026);
      expect(result.first.month, greaterThanOrEqualTo(result[1].month));
    });

    test('should not duplicate current period if already exists', () async {
      final currentPeriod = BudgetPeriod.current();

      when(
        () => mockRepository.getAvailablePeriods(),
      ).thenAnswer((_) async => [currentPeriod]);

      final result = await useCase.call();

      final currentCount = result.where((p) => p == currentPeriod).length;
      expect(currentCount, 1);
    });
  });
}
