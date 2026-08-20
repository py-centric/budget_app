import 'base_dao.dart';

class NetWorthDao extends BaseDao {
  NetWorthDao(super.getDb);

  Future<List<Map<String, dynamic>>> getSnapshots({int limit = 12}) async {
    final database = await db;
    return await database.query(
      'net_worth_snapshots',
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> getSnapshotById(String id) async {
    final database = await db;
    final maps = await database.query(
      'net_worth_snapshots',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> saveSnapshot(Map<String, dynamic> snapshot) async {
    final database = await db;
    await database.insert('net_worth_snapshots', snapshot);
  }

  Future<void> deleteSnapshot(String id) async {
    final database = await db;
    await database.delete('net_worth_snapshots', where: 'id = ?', whereArgs: [id]);
  }
}
