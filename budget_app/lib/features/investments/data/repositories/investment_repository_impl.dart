import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import '../../../budget/data/datasources/local_database.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final LocalDatabase _localDatabase;

  InvestmentRepositoryImpl(this._localDatabase);

  @override
  Future<List<Investment>> getAllInvestments() async {
    final db = await _localDatabase.database;
    final maps = await db.query('investments', orderBy: 'name ASC');
    return maps.map(Investment.fromMap).toList();
  }

  @override
  Future<Investment?> getInvestmentById(String id) async {
    final db = await _localDatabase.database;
    final maps = await db.query('investments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Investment.fromMap(maps.first);
  }

  @override
  Future<Investment> addInvestment(Investment investment) async {
    final db = await _localDatabase.database;
    await db.insert('investments', investment.toMap());
    return investment;
  }

  @override
  Future<void> updateInvestment(Investment investment) async {
    final db = await _localDatabase.database;
    await db.update('investments', investment.toMap(), where: 'id = ?', whereArgs: [investment.id]);
  }

  @override
  Future<void> deleteInvestment(String id) async {
    final db = await _localDatabase.database;
    await db.delete('investments', where: 'id = ?', whereArgs: [id]);
  }
}
