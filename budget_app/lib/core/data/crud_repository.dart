import 'base_repository.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';

/// A higher-level CRUD repository that works directly with entities
/// instead of raw maps.
///
/// Accepts constructor-injected mapping functions so no subclass is needed
/// for simple entities:
///
/// ```dart
/// final repo = CrudRepository<Account>(
///   localDatabase,
///   'accounts',
///   AccountModel.fromMap,
///   (a) => AccountModel.fromEntity(a).toMap(),
///   (a) => a.id,
/// );
///
/// await repo.save(account);
/// final accounts = await repo.getAll(orderBy: 'name ASC');
/// ```
class CrudRepository<T> extends BaseRepository<T> {
  final T Function(Map<String, dynamic>) _fromMap;
  final Map<String, dynamic> Function(T) _toMap;
  final String Function(T) _getId;

  CrudRepository(
    LocalDatabase localDatabase,
    String tableName,
    T Function(Map<String, dynamic>) fromMap,
    Map<String, dynamic> Function(T) toMap,
    String Function(T) getId,
  ) : _fromMap = fromMap,
      _toMap = toMap,
      _getId = getId,
      super(localDatabase, tableName);

  @override
  T fromMap(Map<String, dynamic> map) => _fromMap(map);

  /// Saves (inserts or updates) the entity based on whether a record
  /// with the same [idColumn] already exists.
  Future<void> save(T entity, {String idColumn = 'id'}) async {
    final map = _toMap(entity);
    final id = _getId(entity);
    final existing = await get(id, idColumn: idColumn);
    if (existing != null) {
      await update(map, idColumn: idColumn);
    } else {
      await insert(map);
    }
  }
}
