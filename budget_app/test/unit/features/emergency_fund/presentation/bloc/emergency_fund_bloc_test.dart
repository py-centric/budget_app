import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';
import 'package:budget_app/features/emergency_fund/domain/repositories/emergency_fund_repository.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_bloc.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_event.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_state.dart';

class MockEmergencyFundRepository extends Mock implements EmergencyFundRepository {}

class FakeEmergencyExpense extends Fake implements EmergencyExpense {}

void main() {
  late EmergencyFundBloc emergencyFundBloc;
  late MockEmergencyFundRepository mockRepository;

  final testExpenses = [
    const EmergencyExpense(
      id: '1',
      name: 'Rent',
      amount: 1500.0,
      isSuggestion: true,
      sortOrder: 0,
    ),
    const EmergencyExpense(
      id: '2',
      name: 'Groceries',
      amount: 600.0,
      isSuggestion: true,
      sortOrder: 1,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeEmergencyExpense());
  });

  setUp(() {
    mockRepository = MockEmergencyFundRepository();
    when(() => mockRepository.watchTotalTarget())
        .thenAnswer((_) => const Stream<double>.empty());
    emergencyFundBloc = EmergencyFundBloc(mockRepository);
  });

  tearDown(() {
    emergencyFundBloc.close();
  });

  group('EmergencyFundBloc', () {
    test('initial state is EmergencyFundState with status initial', () {
      expect(emergencyFundBloc.state.status, EmergencyFundStatus.initial);
    });

    group('LoadEmergencyFund', () {
      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'emits [loading, success] with expenses when load succeeds',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          return emergencyFundBloc;
        },
        act: (bloc) => bloc.add(LoadEmergencyFund()),
        expect: () => [
          isA<EmergencyFundState>().having(
            (s) => s.status, 'status', EmergencyFundStatus.loading,
          ),
          isA<EmergencyFundState>().having(
            (s) => s.status, 'status', EmergencyFundStatus.success,
          ).having(
            (s) => s.expenses.length, 'expense count', 2,
          ).having(
            (s) => s.averageMonthlySpending, 'avg monthly', 2100.0,
          ),
        ],
      );

      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'emits [loading, failure] when load fails',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenThrow(Exception('Database error'));
          return emergencyFundBloc;
        },
        act: (bloc) => bloc.add(LoadEmergencyFund()),
        expect: () => [
          isA<EmergencyFundState>().having(
            (s) => s.status, 'status', EmergencyFundStatus.loading,
          ),
          isA<EmergencyFundState>().having(
            (s) => s.status, 'status', EmergencyFundStatus.failure,
          ),
        ],
      );
    });

    group('CalculateLivingExpenses', () {
      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'emits state with calculated living expenses',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          return emergencyFundBloc;
        },
        act: (bloc) => bloc.add(const CalculateLivingExpenses(6)),
        expect: () => [
          isA<EmergencyFundState>().having(
            (s) => s.calculatedLivingExpenses, '6 months', 12600.0,
          ).having(
            (s) => s.averageMonthlySpending, 'avg monthly', 2100.0,
          ),
        ],
      );
    });

    group('UpdateExpenseAmount', () {
      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'saves updated expense amount',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          when(() => mockRepository.saveExpense(any()))
              .thenAnswer((_) async {});
          return emergencyFundBloc;
        },
        act: (bloc) {
          bloc.add(LoadEmergencyFund());
          bloc.add(const UpdateExpenseAmount(id: '1', amount: 1600.0));
        },
        expect: () => [
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
        ],
        verify: (bloc) {
          verify(() => mockRepository.saveExpense(any())).called(1);
        },
      );

      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'emits failure when save fails',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          when(() => mockRepository.saveExpense(any()))
              .thenThrow(Exception('Save failed'));
          return emergencyFundBloc;
        },
        act: (bloc) {
          bloc.add(LoadEmergencyFund());
          bloc.add(const UpdateExpenseAmount(id: '1', amount: 1600.0));
        },
        expect: () => [
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>().having(
            (s) => s.status, 'status', EmergencyFundStatus.failure,
          ),
        ],
      );
    });

    group('AddCustomExpense', () {
      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'saves new expense and reloads',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          when(() => mockRepository.saveExpense(any()))
              .thenAnswer((_) async {});
          return emergencyFundBloc;
        },
        act: (bloc) {
          bloc.add(LoadEmergencyFund());
          bloc.add(const AddCustomExpense('Insurance', 200.0));
        },
        expect: () => containsAll([
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
        ]),
        verify: (bloc) {
          verify(() => mockRepository.saveExpense(any())).called(1);
        },
      );

      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'emits failure when add fails',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          when(() => mockRepository.saveExpense(any()))
              .thenThrow(Exception('Add failed'));
          return emergencyFundBloc;
        },
        act: (bloc) {
          bloc.add(LoadEmergencyFund());
          bloc.add(const AddCustomExpense('Insurance', 200.0));
        },
        expect: () => containsAll([
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>().having(
            (s) => s.status, 'status', EmergencyFundStatus.failure,
          ),
        ]),
      );
    });

    group('DeleteExpense', () {
      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'deletes expense',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          when(() => mockRepository.deleteExpense(any()))
              .thenAnswer((_) async {});
          return emergencyFundBloc;
        },
        act: (bloc) {
          bloc.add(LoadEmergencyFund());
          bloc.add(const DeleteExpense('1'));
        },
        expect: () => containsAll([
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
        ]),
        verify: (bloc) {
          verify(() => mockRepository.deleteExpense('1')).called(1);
        },
      );

      blocTest<EmergencyFundBloc, EmergencyFundState>(
        'emits failure when delete fails',
        build: () {
          when(() => mockRepository.getExpenses())
              .thenAnswer((_) async => testExpenses);
          when(() => mockRepository.getAverageMonthlySpending())
              .thenAnswer((_) async => 2100.0);
          when(() => mockRepository.deleteExpense(any()))
              .thenThrow(Exception('Delete failed'));
          return emergencyFundBloc;
        },
        act: (bloc) {
          bloc.add(LoadEmergencyFund());
          bloc.add(const DeleteExpense('1'));
        },
        expect: () => containsAll([
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>(),
          isA<EmergencyFundState>().having(
            (s) => s.status, 'status', EmergencyFundStatus.failure,
          ),
        ]),
      );
    });
  });
}
