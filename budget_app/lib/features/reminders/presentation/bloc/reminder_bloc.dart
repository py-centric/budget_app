import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bill_reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../../budget/domain/repositories/recurring_repository.dart';
import '../../../budget/domain/entities/recurring_transaction.dart';
import '../../../../core/notifications/notification_service.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _repository;
  final RecurringRepository _recurringRepository;
  final NotificationService _notificationService;

  ReminderBloc({
    required ReminderRepository repository,
    required RecurringRepository recurringRepository,
    required NotificationService notificationService,
  }) : _repository = repository,
       _recurringRepository = recurringRepository,
       _notificationService = notificationService,
       super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<LoadUpcomingReminders>(_onLoadUpcomingReminders);
    on<CreateReminder>(_onCreateReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<DeleteRemindersForTransaction>(_onDeleteRemindersForTransaction);
    on<CheckAndSendReminders>(_onCheckAndSendReminders);
    on<MarkReminderAsNotified>(_onMarkReminderAsNotified);
    on<RefreshReminders>(_onRefreshReminders);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      final reminders = await _repository.getAllReminders();
      final remindersWithDetails = await _getRemindersWithDetails(reminders);

      emit(
        ReminderLoaded(
          reminders: remindersWithDetails,
          unreadCount: remindersWithDetails
              .where((r) => !r.reminder.isNotified)
              .length,
        ),
      );
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onLoadUpcomingReminders(
    LoadUpcomingReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      final reminders = await _repository.getUpcomingReminders(
        days: event.days,
      );
      final remindersWithDetails = await _getRemindersWithDetails(reminders);

      emit(
        ReminderLoaded(
          reminders: remindersWithDetails,
          unreadCount: remindersWithDetails
              .where((r) => !r.reminder.isNotified)
              .length,
        ),
      );
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onCreateReminder(
    CreateReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final reminder = BillReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recurringTransactionId: event.recurringTransactionId,
        dueDate: event.dueDate,
        daysBeforeDue: event.daysBeforeDue,
        isNotified: false,
        createdAt: DateTime.now(),
      );

      await _repository.saveReminder(reminder);

      await _scheduleNotification(reminder);

      add(RefreshReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _repository.saveReminder(event.reminder);
      await _cancelNotification(event.reminder.id);
      await _scheduleNotification(event.reminder);
      add(RefreshReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _cancelNotification(event.reminderId);
      await _repository.deleteReminder(event.reminderId);
      add(RefreshReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteRemindersForTransaction(
    DeleteRemindersForTransaction event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final reminders = await _repository.getRemindersByTransactionId(
        event.transactionId,
      );
      for (final reminder in reminders) {
        await _cancelNotification(reminder.id);
      }
      await _repository.deleteRemindersByTransactionId(event.transactionId);
      add(RefreshReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onCheckAndSendReminders(
    CheckAndSendReminders event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final pendingReminders = await _repository.getPendingReminders();

      for (final reminder in pendingReminders) {
        if (reminder.shouldNotify) {
          final transaction = await _recurringRepository
              .getRecurringTransactionById(reminder.recurringTransactionId);

          await _notificationService.showNotificationForReminder(
            reminder,
            transaction?.description ?? 'Bill Reminder',
          );

          await _repository.markAsNotified(reminder.id);
        }
      }

      add(RefreshReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onMarkReminderAsNotified(
    MarkReminderAsNotified event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _repository.markAsNotified(event.reminderId);
      add(RefreshReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onRefreshReminders(
    RefreshReminders event,
    Emitter<ReminderState> emit,
  ) async {
    add(LoadReminders());
  }

  Future<List<BillReminderWithDetails>> _getRemindersWithDetails(
    List<BillReminder> reminders,
  ) async {
    final result = <BillReminderWithDetails>[];

    for (final reminder in reminders) {
      RecurringTransaction? transaction;
      try {
        transaction = await _recurringRepository.getRecurringTransactionById(
          reminder.recurringTransactionId,
        );
      } catch (_) {}

      result.add(
        BillReminderWithDetails(
          reminder: reminder,
          transactionTitle: transaction?.description,
          transactionDescription: transaction?.description,
          amount: transaction?.amount,
        ),
      );
    }

    return result;
  }

  Future<void> _scheduleNotification(BillReminder reminder) async {
    final scheduledDate = reminder.dueDate.subtract(
      Duration(days: reminder.daysBeforeDue),
    );

    if (scheduledDate.isAfter(DateTime.now())) {
      final transaction = await _recurringRepository
          .getRecurringTransactionById(reminder.recurringTransactionId);

      await _notificationService.scheduleBillReminder(
        id: reminder.id,
        title: transaction?.description ?? 'Bill Reminder',
        body: 'Upcoming bill due in ${reminder.daysBeforeDue} days',
        scheduledDate: scheduledDate,
        payload: reminder.recurringTransactionId,
      );
    }
  }

  Future<void> _cancelNotification(String id) async {
    await _notificationService.cancelNotification(id);
  }
}
