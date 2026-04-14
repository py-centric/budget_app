import 'package:sqflite/sqflite.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import '../../domain/entities/bill_reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../models/bill_reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final LocalDatabase _database;

  ReminderRepositoryImpl(this._database);

  @override
  Future<List<BillReminder>> getAllReminders() async {
    final db = await _database.database;
    final maps = await db.query('bill_reminders', orderBy: 'due_date ASC');
    return maps
        .map((map) => BillReminderModel.fromMap(map).toEntity())
        .toList();
  }

  @override
  Future<BillReminder?> getReminderById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'bill_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BillReminderModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<List<BillReminder>> getRemindersByTransactionId(
    String transactionId,
  ) async {
    final db = await _database.database;
    final maps = await db.query(
      'bill_reminders',
      where: 'recurring_transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'due_date ASC',
    );
    return maps
        .map((map) => BillReminderModel.fromMap(map).toEntity())
        .toList();
  }

  @override
  Future<void> saveReminder(BillReminder reminder) async {
    final db = await _database.database;
    final model = BillReminderModel.fromEntity(reminder);
    await db.insert(
      'bill_reminders',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteReminder(String id) async {
    final db = await _database.database;
    await db.delete('bill_reminders', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteRemindersByTransactionId(String transactionId) async {
    final db = await _database.database;
    await db.delete(
      'bill_reminders',
      where: 'recurring_transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  @override
  Future<List<BillReminder>> getUpcomingReminders({int days = 7}) async {
    final db = await _database.database;
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    final maps = await db.query(
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
    return maps
        .map((map) => BillReminderModel.fromMap(map).toEntity())
        .toList();
  }

  @override
  Future<void> markAsNotified(String id) async {
    final db = await _database.database;
    await db.update(
      'bill_reminders',
      {'is_notified': 1, 'notified_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<BillReminder>> getPendingReminders() async {
    final db = await _database.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final maps = await db.query(
      'bill_reminders',
      where: 'is_notified = 0',
      orderBy: 'due_date ASC',
    );

    return maps.map((map) => BillReminderModel.fromMap(map).toEntity()).where((
      reminder,
    ) {
      final reminderDate = DateTime(
        reminder.reminderDate.year,
        reminder.reminderDate.month,
        reminder.reminderDate.day,
      );
      return reminderDate.isAtSameMomentAs(today) ||
          reminderDate.isBefore(today);
    }).toList();
  }
}
