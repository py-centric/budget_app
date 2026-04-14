import 'package:sqflite/sqflite.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import '../../domain/entities/transaction_split.dart';
import '../../domain/repositories/split_repository.dart';
import '../models/transaction_split_model.dart';

class SplitRepositoryImpl implements SplitRepository {
  final LocalDatabase _database;

  SplitRepositoryImpl(this._database);

  @override
  Future<List<TransactionSplit>> getSplitsForTransaction(
    String parentId,
  ) async {
    final db = await _database.database;
    final maps = await db.query(
      'transaction_splits',
      where: 'parent_transaction_id = ?',
      whereArgs: [parentId],
      orderBy: 'created_at ASC',
    );
    return maps
        .map((map) => TransactionSplitModel.fromMap(map).toEntity())
        .toList();
  }

  @override
  Future<void> saveSplit(TransactionSplit split) async {
    final db = await _database.database;
    final model = TransactionSplitModel.fromEntity(split);
    await db.insert(
      'transaction_splits',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteSplit(String id) async {
    final db = await _database.database;
    await db.delete('transaction_splits', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteSplitsForTransaction(String parentId) async {
    final db = await _database.database;
    await db.delete(
      'transaction_splits',
      where: 'parent_transaction_id = ?',
      whereArgs: [parentId],
    );
  }

  @override
  Future<double> getTotalSplitAmount(String parentId) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transaction_splits WHERE parent_transaction_id = ?',
      [parentId],
    );
    if (result.isEmpty || result.first['total'] == null) {
      return 0;
    }
    return (result.first['total'] as num).toDouble();
  }

  @override
  Future<bool> hasSplits(String parentId) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transaction_splits WHERE parent_transaction_id = ?',
      [parentId],
    );
    if (result.isEmpty) return false;
    return (result.first['count'] as int) > 0;
  }
}
