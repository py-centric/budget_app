import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';

class SavingsDao extends BaseDao {
  SavingsDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final database = await db;
    return await database.query('savings_goals', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getGoalById(String id) async {
    final database = await db;
    final maps = await database.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> saveGoal(Map<String, dynamic> goal) async {
    final database = await db;
    await database.insert(
      'savings_goals',
      goal,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteGoal(String id) async {
    final database = await db;
    await database.delete(
      'savings_contributions',
      where: 'goal_id = ?',
      whereArgs: [id],
    );
    await database.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addContribution(
    Map<String, dynamic> contribution,
    String goalId,
    double amount,
  ) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.insert(
        'savings_contributions',
        contribution,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final goalMaps = await txn.query(
        'savings_goals',
        where: 'id = ?',
        whereArgs: [goalId],
      );

      if (goalMaps.isNotEmpty) {
        final currentAmount = (goalMaps.first['current_amount'] as num?)?.toDouble() ?? 0.0;
        final targetAmount = (goalMaps.first['target_amount'] as num?)?.toDouble() ?? 0.0;
        final newCurrentAmount = currentAmount + amount;
        final isCompleted = newCurrentAmount >= targetAmount;

        await txn.update(
          'savings_goals',
          {
            'current_amount': newCurrentAmount,
            'is_completed': isCompleted ? 1 : 0,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [goalId],
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getContributionsForGoal(String goalId) async {
    final database = await db;
    return await database.query(
      'savings_contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC',
    );
  }

  Future<void> deleteContribution(String id) async {
    final database = await db;
    await database.delete('savings_contributions', where: 'id = ?', whereArgs: [id]);
  }
}
