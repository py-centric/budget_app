import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/savings/domain/entities/savings_goal.dart';
import 'package:budget_app/features/savings/domain/entities/savings_contribution.dart';
import 'package:budget_app/features/savings/domain/repositories/savings_repository.dart';
import 'package:budget_app/features/savings/presentation/bloc/savings_bloc.dart';
import 'package:budget_app/features/savings/presentation/bloc/savings_event.dart';
import 'package:budget_app/features/savings/presentation/bloc/savings_state.dart';

class MockSavingsRepository extends Mock implements SavingsRepository {}

class FakeSavingsGoal extends Fake implements SavingsGoal {}

void main() {
  late SavingsBloc savingsBloc;
  late MockSavingsRepository mockRepository;

  final testGoal = SavingsGoal(
    id: '1',
    name: 'Vacation',
    targetAmount: 5000.0,
    currentAmount: 1000.0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeSavingsGoal());
  });

  setUp(() {
    mockRepository = MockSavingsRepository();
    savingsBloc = SavingsBloc(repository: mockRepository);
  });

  tearDown(() {
    savingsBloc.close();
  });

  group('SavingsBloc', () {
    test('initial state is SavingsInitial', () {
      expect(savingsBloc.state, SavingsInitial());
    });

    group('LoadSavingsGoals', () {
      blocTest<SavingsBloc, SavingsState>(
        'emits [SavingsLoading, SavingsLoaded] when load succeeds',
        build: () {
          when(() => mockRepository.getAllGoals())
              .thenAnswer((_) async => [testGoal]);
          when(() => mockRepository.getContributionsForGoal(any()))
              .thenAnswer((_) async => []);
          return savingsBloc;
        },
        act: (bloc) => bloc.add(LoadSavingsGoals()),
        expect: () => [
          isA<SavingsLoading>(),
          isA<SavingsLoaded>().having(
            (s) => s.goals.length, 'goal count', 1,
          ),
        ],
      );

      blocTest<SavingsBloc, SavingsState>(
        'emits [SavingsLoading, SavingsError] when load fails',
        build: () {
          when(() => mockRepository.getAllGoals())
              .thenThrow(Exception('Database error'));
          return savingsBloc;
        },
        act: (bloc) => bloc.add(LoadSavingsGoals()),
        expect: () => [
          isA<SavingsLoading>(),
          isA<SavingsError>(),
        ],
      );
    });

    group('AddSavingsGoal', () {
      blocTest<SavingsBloc, SavingsState>(
        'saves goal and reloads',
        build: () {
          when(() => mockRepository.saveGoal(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getAllGoals())
              .thenAnswer((_) async => [testGoal]);
          when(() => mockRepository.getContributionsForGoal(any()))
              .thenAnswer((_) async => []);
          return savingsBloc;
        },
        act: (bloc) => bloc.add(
          const AddSavingsGoal(name: 'New Goal', targetAmount: 1000.0),
        ),
        expect: () => containsAll([
          isA<SavingsLoading>(),
          isA<SavingsLoaded>(),
        ]),
        verify: (bloc) {
          verify(() => mockRepository.saveGoal(any())).called(1);
        },
      );
    });

    group('UpdateSavingsGoal', () {
      blocTest<SavingsBloc, SavingsState>(
        'updates goal and reloads',
        build: () {
          when(() => mockRepository.saveGoal(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getAllGoals())
              .thenAnswer((_) async => [testGoal]);
          when(() => mockRepository.getContributionsForGoal(any()))
              .thenAnswer((_) async => []);
          return savingsBloc;
        },
        act: (bloc) => bloc.add(UpdateSavingsGoal(testGoal)),
        expect: () => containsAll([
          isA<SavingsLoading>(),
          isA<SavingsLoaded>(),
        ]),
        verify: (bloc) {
          verify(() => mockRepository.saveGoal(any())).called(1);
        },
      );
    });

    group('DeleteSavingsGoal', () {
      blocTest<SavingsBloc, SavingsState>(
        'deletes goal and reloads',
        build: () {
          when(() => mockRepository.deleteGoal(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getAllGoals())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getContributionsForGoal(any()))
              .thenAnswer((_) async => []);
          return savingsBloc;
        },
        act: (bloc) => bloc.add(const DeleteSavingsGoal('1')),
        expect: () => containsAll([
          isA<SavingsLoading>(),
          isA<SavingsLoaded>(),
        ]),
        verify: (bloc) {
          verify(() => mockRepository.deleteGoal('1')).called(1);
        },
      );
    });

    group('AddContribution', () {
      blocTest<SavingsBloc, SavingsState>(
        'adds contribution and updates goal current amount',
        build: () {
          when(() => mockRepository.addContribution(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getGoalById(any()))
              .thenAnswer((_) async => testGoal);
          when(() => mockRepository.saveGoal(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getAllGoals())
              .thenAnswer((_) async => [testGoal]);
          when(() => mockRepository.getContributionsForGoal(any()))
              .thenAnswer((_) async => []);
          return savingsBloc;
        },
        act: (bloc) => bloc.add(
          AddContribution(
            goalId: '1',
            amount: 500.0,
            date: DateTime(2026, 5, 1),
          ),
        ),
        expect: () => containsAll([
          isA<SavingsLoading>(),
          isA<SavingsLoaded>(),
        ]),
        verify: (bloc) {
          verify(() => mockRepository.addContribution(any())).called(1);
          verify(() => mockRepository.saveGoal(any())).called(1);
        },
      );
    });

    group('DeleteContribution', () {
      final testContribution = SavingsContribution(
        id: 'c1',
        goalId: '1',
        amount: 500.0,
        date: DateTime(2026, 5, 1),
        createdAt: DateTime(2026, 5, 1),
      );

      blocTest<SavingsBloc, SavingsState>(
        'deletes contribution and updates goal',
        build: () {
          when(() => mockRepository.getContributionsForGoal(any()))
              .thenAnswer((_) async => [testContribution]);
          when(() => mockRepository.deleteContribution(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getGoalById(any()))
              .thenAnswer((_) async => testGoal);
          when(() => mockRepository.saveGoal(any()))
              .thenAnswer((_) async {});
          when(() => mockRepository.getAllGoals())
              .thenAnswer((_) async => [testGoal]);
          return savingsBloc;
        },
        act: (bloc) => bloc.add(
          const DeleteContribution(contributionId: 'c1', goalId: '1'),
        ),
        expect: () => containsAll([
          isA<SavingsLoading>(),
          isA<SavingsLoaded>(),
        ]),
        verify: (bloc) {
          verify(() => mockRepository.deleteContribution('c1')).called(1);
        },
      );
    });
  });
}
