import 'package:sqflite/sqflite.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/entities/recurring_override.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../datasources/local_database.dart';
import '../models/recurring_transaction_model.dart';
import '../models/recurring_override_model.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final LocalDatabase _localDatabase;

  RecurringRepositoryImpl(this._localDatabase);

  @override
  Future<void> saveRecurringTransaction(RecurringTransaction recurring) async {
    final db = await _localDatabase.database;
    final model = RecurringTransactionModel.fromEntity(recurring);
    await db.insert(
      'recurring_transactions',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    final db = await _localDatabase.database;
    await db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    final db = await _localDatabase.database;
    final maps = await db.query('recurring_transactions');
    return maps.map<RecurringTransaction>((map) => RecurringTransactionModel.fromMap(map)).toList();
  }

  @override
  Future<RecurringTransaction?> getRecurringTransactionById(String id) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return RecurringTransactionModel.fromMap(maps.first);
  }

  @override
  Future<void> saveRecurringOverride(RecurringOverride override) async {
    final db = await _localDatabase.database;
    final model = RecurringOverrideModel.fromEntity(override);
    await db.insert(
      'recurring_overrides',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteRecurringOverride(String id) async {
    final db = await _localDatabase.database;
    await db.delete(
      'recurring_overrides',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<RecurringOverride>> getOverridesForTemplate(String templateId) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'recurring_overrides',
      where: 'recurring_transaction_id = ?',
      whereArgs: [templateId],
    );
    return maps.map<RecurringOverride>((map) => RecurringOverrideModel.fromMap(map)).toList();
  }

  @override
  Future<List<RecurringOverride>> getAllOverrides() async {
    final db = await _localDatabase.database;
    final maps = await db.query('recurring_overrides');
    return maps.map<RecurringOverride>((map) => RecurringOverrideModel.fromMap(map)).toList();
  }
}
