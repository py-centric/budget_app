import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/reminders/domain/entities/bill_reminder.dart';
import 'package:budget_app/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_event.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/core/notifications/notification_service.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}
class MockRecurringRepository extends Mock implements RecurringRepository {}
class MockNotificationService extends Mock implements NotificationService {}

class FakeBillReminder extends Fake implements BillReminder {}

void main() {
  late ReminderBloc reminderBloc;
  late MockReminderRepository mockReminderRepository;
  late MockRecurringRepository mockRecurringRepository;
  late MockNotificationService mockNotificationService;

  final testReminder = BillReminder(
    id: '1',
    recurringTransactionId: 'rt1',
    dueDate: DateTime(2026, 6, 15),
    daysBeforeDue: 3,
    isNotified: false,
    createdAt: DateTime(2026, 5, 1),
  );

  final testTransaction = RecurringTransaction(
    id: 'rt1',
    budgetId: 'b1',
    type: 'EXPENSE',
    amount: 200.0,
    categoryId: 'c1',
    description: 'Electric Bill',
    startDate: DateTime(2026, 1, 1),
    interval: 1,
    unit: RecurrenceUnit.months,
  );

  setUpAll(() {
    registerFallbackValue(FakeBillReminder());
  });

  setUp(() {
    mockReminderRepository = MockReminderRepository();
    mockRecurringRepository = MockRecurringRepository();
    mockNotificationService = MockNotificationService();
    reminderBloc = ReminderBloc(
      repository: mockReminderRepository,
      recurringRepository: mockRecurringRepository,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    reminderBloc.close();
  });

  group('ReminderBloc', () {
    test('initial state is ReminderInitial', () {
      expect(reminderBloc.state, ReminderInitial());
    });

    group('LoadReminders', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits [ReminderLoading, ReminderLoaded] when load succeeds',
        build: () {
          when(() => mockReminderRepository.getAllReminders())
              .thenAnswer((_) async => [testReminder]);
          when(() => mockRecurringRepository.getRecurringTransactionById(any()))
              .thenAnswer((_) async => testTransaction);
          return reminderBloc;
        },
        act: (bloc) => bloc.add(LoadReminders()),
        expect: () => [
          isA<ReminderLoading>(),
          isA<ReminderLoaded>().having(
            (s) => s.reminders.length, 'reminder count', 1,
          ),
        ],
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits [ReminderLoading, ReminderError] when load fails',
        build: () {
          when(() => mockReminderRepository.getAllReminders())
              .thenThrow(Exception('Database error'));
          return reminderBloc;
        },
        act: (bloc) => bloc.add(LoadReminders()),
        expect: () => [
          isA<ReminderLoading>(),
          isA<ReminderError>(),
        ],
      );
    });

    group('LoadUpcomingReminders', () {
      blocTest<ReminderBloc, ReminderState>(
        'emits loaded with upcoming reminders',
        build: () {
          when(() => mockReminderRepository.getUpcomingReminders(days: 7))
              .thenAnswer((_) async => [testReminder]);
          when(() => mockRecurringRepository.getRecurringTransactionById(any()))
              .thenAnswer((_) async => testTransaction);
          return reminderBloc;
        },
        act: (bloc) => bloc.add(const LoadUpcomingReminders(days: 7)),
        expect: () => [
          isA<ReminderLoading>(),
          isA<ReminderLoaded>(),
        ],
      );
    });

    group('CreateReminder', () {
      blocTest<ReminderBloc, ReminderState>(
        'creates reminder and refreshes',
        build: () {
          when(() => mockReminderRepository.saveReminder(any()))
              .thenAnswer((_) async {});
          when(() => mockRecurringRepository.getRecurringTransactionById(any()))
              .thenAnswer((_) async => testTransaction);
          when(() => mockNotificationService.scheduleBillReminder(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async {});
          when(() => mockReminderRepository.getAllReminders())
              .thenAnswer((_) async => [testReminder]);
          return reminderBloc;
        },
        act: (bloc) => bloc.add(
          CreateReminder(
            recurringTransactionId: 'rt1',
            dueDate: DateTime(2026, 6, 15),
            daysBeforeDue: 3,
          ),
        ),
        expect: () => containsAll([
          isA<ReminderLoading>(),
          isA<ReminderLoaded>(),
        ]),
        verify: (bloc) {
          verify(() => mockReminderRepository.saveReminder(any())).called(1);
        },
      );

      blocTest<ReminderBloc, ReminderState>(
        'emits error when create fails',
        build: () {
          when(() => mockReminderRepository.saveReminder(any()))
              .thenThrow(Exception('Save failed'));
          return reminderBloc;
        },
        act: (bloc) => bloc.add(
          CreateReminder(
            recurringTransactionId: 'rt1',
            dueDate: DateTime(2026, 6, 15),
            daysBeforeDue: 3,
          ),
        ),
        expect: () => [isA<ReminderError>()],
      );
    });

    group('DeleteReminder', () {
      blocTest<ReminderBloc, ReminderState>(
        'deletes reminder and refreshes',
        build: () {
          when(() => mockNotificationService.cancelNotification(any()))
              .thenAnswer((_) async {});
          when(() => mockReminderRepository.deleteReminder(any()))
              .thenAnswer((_) async {});
          when(() => mockReminderRepository.getAllReminders())
              .thenAnswer((_) async => []);
          return reminderBloc;
        },
        act: (bloc) => bloc.add(const DeleteReminder('1')),
        expect: () => containsAll([
          isA<ReminderLoading>(),
          isA<ReminderLoaded>(),
        ]),
        verify: (bloc) {
          verify(() => mockReminderRepository.deleteReminder('1')).called(1);
        },
      );
    });
  });
}
