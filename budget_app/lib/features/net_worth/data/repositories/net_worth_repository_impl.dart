import '../../domain/entities/net_worth_snapshot.dart';
import '../../domain/repositories/net_worth_repository.dart';
import '../../../budget/data/datasources/local_database.dart';

class NetWorthRepositoryImpl implements NetWorthRepository {
  final LocalDatabase _localDatabase;

  NetWorthRepositoryImpl(this._localDatabase);

  @override
  Future<List<NetWorthSnapshot>> getSnapshots({int limit = 12}) async {
    final db = await _localDatabase.database;
    final maps = await db.query('net_worth_snapshots', orderBy: 'date DESC', limit: limit);
    return maps.map(NetWorthSnapshot.fromMap).toList();
  }

  @override
  Future<NetWorthSnapshot> addSnapshot(NetWorthSnapshot snapshot) async {
    final db = await _localDatabase.database;
    await db.insert('net_worth_snapshots', snapshot.toMap());
    return snapshot;
  }

  @override
  Future<void> deleteSnapshot(String id) async {
    final db = await _localDatabase.database;
    await db.delete('net_worth_snapshots', where: 'id = ?', whereArgs: [id]);
  }
}
