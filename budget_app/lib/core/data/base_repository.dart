import 'package:sqflite/sqflite.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';

/// Base repository that eliminates CRUD boilerplate for SQLite-backed
/// repositories. Subclasses provide [fromMap] for the entity mapping;
/// all standard query/insert/update/delete operations are inherited.
///
/// Type parameter [T] is the domain entity or model class.
///
/// Example:
/// ```dart
/// class GoalRepository extends BaseRepository<SavingsGoal> {
///   GoalRepository(LocalDatabase db)
///       : super(db, 'savings_goals');
///
///   @override
///   SavingsGoal fromMap(Map<String, dynamic> map) =>
///       SavingsGoalModel.fromMap(map);
/// }
/// ```
abstract class BaseRepository<T> {
  final LocalDatabase localDatabase;
  final String tableName;

  BaseRepository(this.localDatabase, this.tableName);

  /// Convenience getter for the underlying SQLite database.
  Future<Database> get db => localDatabase.database;

  /// Fetch a single record by [id] (defaults to column `'id'`).
  /// Returns `null` when no record matches.
  Future<T?> get(String id, {String idColumn = 'id'}) async {
    final db = await this.db;
    final maps = await db.query(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  /// Fetch all records, optionally sorted by [orderBy]
  /// (e.g. `'created_at DESC'`).
  Future<List<T>> getAll({String? orderBy}) async {
    final db = await this.db;
    final maps = await db.query(tableName, orderBy: orderBy);
    return maps.map((m) => fromMap(m)).toList();
  }

  /// Insert a row from a raw column-value [map].
  Future<void> insert(Map<String, dynamic> map) async {
    final db = await this.db;
    await db.insert(tableName, map);
  }

  /// Update the row identified by [idColumn] in [map].
  /// The column used for matching defaults to `'id'`.
  Future<void> update(
    Map<String, dynamic> map, {
    String idColumn = 'id',
  }) async {
    final db = await this.db;
    await db.update(
      tableName,
      map,
      where: '$idColumn = ?',
      whereArgs: [map[idColumn]],
    );
  }

  /// Delete the record identified by [id] (defaults to column `'id'`).
  Future<void> delete(String id, {String idColumn = 'id'}) async {
    final db = await this.db;
    await db.delete(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  /// Custom query — returns raw maps for repositories that need
  /// complex WHERE clauses or joins.
  Future<List<Map<String, dynamic>>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await this.db;
    return db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Subclasses must implement this to map a database row back to the
  /// entity type [T].
  T fromMap(Map<String, dynamic> map);
}
