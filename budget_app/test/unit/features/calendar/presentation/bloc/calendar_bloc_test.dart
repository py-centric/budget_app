import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/get_calendar_data.dart';
import 'package:budget_app/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:budget_app/features/calendar/presentation/bloc/calendar_event.dart'
    as events;
import 'package:budget_app/features/calendar/presentation/bloc/calendar_state.dart';

class MockGetCalendarData extends Mock implements GetCalendarData {}

void main() {
  late CalendarBloc calendarBloc;
  late MockGetCalendarData mockGetCalendarData;

  setUp(() {
    mockGetCalendarData = MockGetCalendarData();
    calendarBloc = CalendarBloc(getCalendarData: mockGetCalendarData);
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
          when(() => mockGetCalendarData.forMonth(any(), any())).thenAnswer(
            (_) async => const CalendarMonthData(
              incomes: [],
              expenses: [],
              categories: [],
            ),
          );
          when(
            () => mockGetCalendarData.getExpensesBefore(any()),
          ).thenAnswer((_) async => []);
          when(
            () => mockGetCalendarData.getIncomesBefore(any()),
          ).thenAnswer((_) async => []);
          return calendarBloc;
        },
        act: (bloc) =>
            bloc.add(const events.LoadCalendarMonth(year: 2026, month: 5)),
        expect: () => [isA<CalendarLoading>(), isA<CalendarLoaded>()],
      );

      blocTest<CalendarBloc, CalendarState>(
        'emits [CalendarLoading, CalendarError] when LoadCalendarMonth fails',
        build: () {
          when(
            () => mockGetCalendarData.forMonth(any(), any()),
          ).thenThrow(Exception('Database error'));
          return calendarBloc;
        },
        act: (bloc) =>
            bloc.add(const events.LoadCalendarMonth(year: 2026, month: 5)),
        expect: () => [isA<CalendarLoading>(), isA<CalendarError>()],
      );

      blocTest<CalendarBloc, CalendarState>(
        'sets correct month boundaries in CalendarLoaded',
        build: () {
          when(() => mockGetCalendarData.forMonth(any(), any())).thenAnswer(
            (_) async => const CalendarMonthData(
              incomes: [],
              expenses: [],
              categories: [],
            ),
          );
          when(
            () => mockGetCalendarData.getExpensesBefore(any()),
          ).thenAnswer((_) async => []);
          when(
            () => mockGetCalendarData.getIncomesBefore(any()),
          ).thenAnswer((_) async => []);
          return calendarBloc;
        },
        act: (bloc) =>
            bloc.add(const events.LoadCalendarMonth(year: 2026, month: 5)),
        expect: () => [
          isA<CalendarLoading>(),
          isA<CalendarLoaded>()
              .having((s) => s.year, 'year', 2026)
              .having((s) => s.month, 'month', 5),
        ],
      );
    });

    group('SelectCalendarDay', () {
      blocTest<CalendarBloc, CalendarState>(
        'emits loaded state with selected date when day selected',
        build: () {
          when(() => mockGetCalendarData.forMonth(any(), any())).thenAnswer(
            (_) async => const CalendarMonthData(
              incomes: [],
              expenses: [],
              categories: [],
            ),
          );
          when(
            () => mockGetCalendarData.getExpensesBefore(any()),
          ).thenAnswer((_) async => []);
          when(
            () => mockGetCalendarData.getIncomesBefore(any()),
          ).thenAnswer((_) async => []);
          return calendarBloc;
        },
        act: (bloc) {
          bloc.add(const events.LoadCalendarMonth(year: 2026, month: 5));
          bloc.add(events.SelectCalendarDay(DateTime(2026, 5, 15)));
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
        act: (bloc) =>
            bloc.add(events.SelectCalendarDay(DateTime(2026, 5, 15))),
        expect: () => [],
      );
    });
  });
}
