import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:budget_app/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:budget_app/features/calendar/presentation/bloc/calendar_state.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late CalendarBloc calendarBloc;
  late MockBudgetRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetRepository();
    calendarBloc = CalendarBloc(budgetRepository: mockRepository);
  });

  tearDown(() {
    calendarBloc.close();
  });

  group('CalendarBloc', () {
    test('initial state is CalendarInitial', () {
      expect(calendarBloc.state, CalendarInitial());
    });

    group('LoadCalendarMonth', () {
      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarLoaded] when LoadCalendarMonth succeeds',
        build: () {
          when(() => mockRepository.getAllIncome())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getAllExpenses())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getCategories())
              .thenAnswer((_) async => []);
          return calendarBloc;
        },
        act: (bloc) => bloc.add(const LoadCalendarMonth(year: 2026, month: 5)),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarLoaded>(),
        ],
      );

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarError] when LoadCalendarMonth fails',
        build: () {
          when(() => mockRepository.getAllIncome())
              .thenThrow(Exception('Database error'));
          return calendarBloc;
        },
        act: (bloc) => bloc.add(const LoadCalendarMonth(year: 2026, month: 5)),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarError>(),
        ],
      );

      blocTest<CalendarBloc, CalendarState>(
        'sets correct month boundaries in CalendarLoaded',
        build: () {
          when(() => mockRepository.getAllIncome())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getAllExpenses())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getCategories())
              .thenAnswer((_) async => []);
          return calendarBloc;
        },
        act: (bloc) => bloc.add(const LoadCalendarMonth(year: 2026, month: 5)),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarLoaded>().having(
            (s) => s.year,
            'year',
            2026,
          ).having(
            (s) => s.month,
            'month',
            5,
          ),
        ],
      );
    });

    group('SelectCalendarDay', () {
      blocTest<CalendarBloc, CalendarState>(
        'emits loaded state with selected date when day selected',
        build: () {
          when(() => mockRepository.getAllIncome())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getAllExpenses())
              .thenAnswer((_) async => []);
          when(() => mockRepository.getCategories())
              .thenAnswer((_) async => []);
          return calendarBloc;
        },
        act: (bloc) {
          bloc.add(const LoadCalendarMonth(year: 2026, month: 5));
          bloc.add(SelectCalendarDay(DateTime(2026, 5, 15)));
        },
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarLoaded>(),
          isA<CalendarLoaded>().having(
            (s) => s.selectedDate,
            'selectedDate',
            DateTime(2026, 5, 15),
          ),
        ],
      );

      blocTest<CalendarBloc, CalendarState>(
        'does nothing when not in loaded state',
        build: () => calendarBloc,
        act: (bloc) => bloc.add(SelectCalendarDay(DateTime(2026, 5, 15))),
        expect: () => [],
      );
    });
  });
}
