import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/financial_tools/domain/repositories/financial_repository.dart';
import 'package:budget_app/features/financial_tools/domain/entities/saved_calculation.dart';

class MockFinancialRepository extends Mock implements FinancialRepository {}

class FakeSavedCalculation extends Fake implements SavedCalculation {}

void main() {
  late MockFinancialRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeSavedCalculation());
  });

  setUp(() {
    mockRepository = MockFinancialRepository();
  });

  group('FinancialRepository', () {
    test('saveCalculation should call repository', () async {
      when(
        () => mockRepository.saveCalculation(any()),
      ).thenAnswer((_) async {});

      final calculation = SavedCalculation(
        id: '1',
        type: 'loan',
        name: 'My Loan',
        data: {'principal': 100000},
        createdAt: DateTime(2024, 1, 1),
      );

      await mockRepository.saveCalculation(calculation);

      verify(() => mockRepository.saveCalculation(calculation)).called(1);
    });

    test('getSavedCalculations should return list of calculations', () async {
      final calculations = [
        SavedCalculation(
          id: '1',
          type: 'loan',
          name: 'Loan 1',
          data: {},
          createdAt: DateTime(2024, 1, 1),
        ),
        SavedCalculation(
          id: '2',
          type: 'savings',
          name: 'Savings 1',
          data: {},
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      when(
        () => mockRepository.getSavedCalculations(),
      ).thenAnswer((_) async => calculations);

      final result = await mockRepository.getSavedCalculations();

      expect(result, calculations);
      expect(result.length, 2);
    });

    test('deleteCalculation should call repository', () async {
      when(
        () => mockRepository.deleteCalculation('1'),
      ).thenAnswer((_) async {});

      await mockRepository.deleteCalculation('1');

      verify(() => mockRepository.deleteCalculation('1')).called(1);
    });

    test(
      'getSavedCalculations should return empty list when none exist',
      () async {
        when(
          () => mockRepository.getSavedCalculations(),
        ).thenAnswer((_) async => []);

        final result = await mockRepository.getSavedCalculations();

        expect(result, isEmpty);
      },
    );
  });
}
