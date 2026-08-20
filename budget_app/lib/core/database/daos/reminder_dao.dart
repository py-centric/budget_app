import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';

class ReminderDao extends BaseDao {
  ReminderDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final database = await db;
    return await database.query('bill_reminders', orderBy: 'due_date ASC');
  }

  Future<Map<String, dynamic>?> getReminderById(String id) async {
    final database = await db;
    final maps = await database.query(
      'bill_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<List<Map<String, dynamic>>> getRemindersByTransactionId(
    String transactionId,
  ) async {
    final database = await db;
    return await database.query(
      'bill_reminders',
      where: 'recurring_transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'due_date ASC',
    );
  }

  Future<void> saveReminder(Map<String, dynamic> reminder) async {
    final database = await db;
    await database.insert(
      'bill_reminders',
      reminder,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteReminder(String id) async {
    final database = await db;
    await database.delete('bill_reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteRemindersByTransactionId(String transactionId) async {
    final database = await db;
    await database.delete(
      'bill_reminders',
      where: 'recurring_transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<List<Map<String, dynamic>>> getUpcomingReminders({int days = 7}) async {
    final database = await db;
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    return await database.query(
      'bill_reminders',
      where: 'due_date >= ? AND due_date <= ? AND is_notified = 0',
      whereArgs: [
        DateTime(now.year, now.month, now.day).toIso8601String(),
        DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        ).toIso8601String(),
      ],
      orderBy: 'due_date ASC',
    );
  }

  Future<void> markAsNotified(String id) async {
    final database = await db;
    await database.update(
      'bill_reminders',
      {'is_notified': 1, 'notified_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingReminders() async {
    final database = await db;
    return await database.query(
      'bill_reminders',
      where: 'is_notified = 0',
      orderBy: 'due_date ASC',
    );
  }
}
