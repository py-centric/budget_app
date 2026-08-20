import 'package:sqflite/sqflite.dart';

abstract class BaseDao {
  final Future<Database> Function() _getDb;

  BaseDao(this._getDb);

  Future<Database> get db => _getDb();
}
