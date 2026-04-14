import '../entities/bill_reminder.dart';

abstract class ReminderRepository {
  Future<List<BillReminder>> getAllReminders();
  Future<BillReminder?> getReminderById(String id);
  Future<List<BillReminder>> getRemindersByTransactionId(String transactionId);
  Future<void> saveReminder(BillReminder reminder);
  Future<void> deleteReminder(String id);
  Future<void> deleteRemindersByTransactionId(String transactionId);
  Future<List<BillReminder>> getUpcomingReminders({int days = 7});
  Future<void> markAsNotified(String id);
  Future<List<BillReminder>> getPendingReminders();
}
