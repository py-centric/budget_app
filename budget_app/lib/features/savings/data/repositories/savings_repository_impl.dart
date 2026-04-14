import 'package:sqflite/sqflite.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_contribution.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../../budget/data/datasources/local_database.dart';
import '../models/savings_goal_model.dart';
import '../models/savings_contribution_model.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final LocalDatabase _database;

  SavingsRepositoryImpl(this._database);

  @override
  Future<List<SavingsGoal>> getAllGoals() async {
    final db = await _database.database;
    final maps = await db.query('savings_goals', orderBy: 'created_at DESC');
    return maps.map((map) => SavingsGoalModel.fromMap(map)).toList();
  }

  @override
  Future<SavingsGoal?> getGoalById(String id) async {
    final db = await _database.database;
    final maps = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SavingsGoalModel.fromMap(maps.first);
  }

  @override
  Future<void> saveGoal(SavingsGoal goal) async {
    final db = await _database.database;
    final model = SavingsGoalModel.fromEntity(goal);
    final map = model.toMap();

    await db.insert(
      'savings_goals',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    final db = await _database.database;
    await db.delete(
      'savings_contributions',
      where: 'goal_id = ?',
      whereArgs: [id],
    );
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addContribution(SavingsContribution contribution) async {
    final db = await _database.database;
    final model = SavingsContributionModel.fromEntity(contribution);

    await db.transaction((txn) async {
      await txn.insert(
        'savings_contributions',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final goalMaps = await txn.query(
        'savings_goals',
        where: 'id = ?',
        whereArgs: [contribution.goalId],
      );

      if (goalMaps.isNotEmpty) {
        final goal = SavingsGoalModel.fromMap(goalMaps.first);
        final newCurrentAmount = goal.currentAmount + contribution.amount;
        final isCompleted = newCurrentAmount >= goal.targetAmount;

        await txn.update(
          'savings_goals',
          {
            'current_amount': newCurrentAmount,
            'is_completed': isCompleted ? 1 : 0,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [contribution.goalId],
        );
      }
    });
  }

  @override
  Future<List<SavingsContribution>> getContributionsForGoal(
    String goalId,
  ) async {
    final db = await _database.database;
    final maps = await db.query(
      'savings_contributions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => SavingsContributionModel.fromMap(map)).toList();
  }

  @override
  Future<void> deleteContribution(String id) async {
    final db = await _database.database;
    await db.delete('savings_contributions', where: 'id = ?', whereArgs: [id]);
  }
}
