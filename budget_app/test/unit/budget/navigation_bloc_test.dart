import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/usecases/get_available_periods.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';

class MockGetAvailablePeriods extends Mock implements GetAvailablePeriods {}

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockStorage extends Mock implements Storage {}

class FakeBudgetPeriod extends Fake implements BudgetPeriod {}

class FakeBudget extends Fake implements Budget {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBudgetPeriod());
    registerFallbackValue(BudgetPeriod.current());
    registerFallbackValue(FakeBudget());
  });

  late MockGetAvailablePeriods mockGetAvailablePeriods;
  late MockBudgetRepository mockBudgetRepository;
  late MockStorage mockStorage;

  setUp(() {
    mockGetAvailablePeriods = MockGetAvailablePeriods();
    mockBudgetRepository = MockBudgetRepository();
    when(
      () => mockBudgetRepository.getBudgetsForPeriod(any()),
    ).thenAnswer((_) async => []);
    when(
      () => mockBudgetRepository.addBudget(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockGetAvailablePeriods.call(),
    ).thenAnswer((_) async => [BudgetPeriod.current()]);
    mockStorage = MockStorage();
    when(
      () => mockStorage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;
  });

  group('NavigationBloc', () {
    test('initial state has current period', () {
      final bloc = NavigationBloc(
        getAvailablePeriodsUseCase: mockGetAvailablePeriods,
        budgetRepository: mockBudgetRepository,
      );
      expect(bloc.state.currentPeriod, equals(BudgetPeriod.current()));
    });

    blocTest<NavigationBloc, NavigationState>(
      'emits new state when ChangePeriod is added',
      build: () => NavigationBloc(
        getAvailablePeriodsUseCase: mockGetAvailablePeriods,
        budgetRepository: mockBudgetRepository,
      ),
      act: (bloc) =>
          bloc.add(const ChangePeriod(BudgetPeriod(year: 2024, month: 1))),
      verify: (bloc) {
        expect(
          bloc.state.currentPeriod,
          const BudgetPeriod(year: 2024, month: 1),
        );
      },
    );

    blocTest<NavigationBloc, NavigationState>(
      'emits new state when LoadAvailablePeriods is added',
      build: () {
        when(
          () => mockGetAvailablePeriods.call(),
        ).thenAnswer((_) async => [const BudgetPeriod(year: 2024, month: 1)]);
        return NavigationBloc(
          getAvailablePeriodsUseCase: mockGetAvailablePeriods,
          budgetRepository: mockBudgetRepository,
        );
      },
      act: (bloc) => bloc.add(const LoadAvailablePeriods()),
      verify: (bloc) {
        expect(bloc.state.availablePeriods, [
          const BudgetPeriod(year: 2024, month: 1),
        ]);
      },
    );
  });
}
