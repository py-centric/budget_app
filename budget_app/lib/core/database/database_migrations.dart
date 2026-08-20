import 'package:sqflite/sqflite.dart';
import 'migrations/migrations_v1_v10.dart';
import 'migrations/migrations_v11_v20.dart';
import 'migrations/migrations_v21_v28.dart';
import 'migrations/migrations_v29.dart';

class DatabaseMigrations {
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await MigrationsV1ToV10.migrate(db, oldVersion);
    await MigrationsV11ToV20.migrate(db, oldVersion);
    await MigrationsV21ToV28.migrate(db, oldVersion);
    await MigrationsV29.migrate(db, oldVersion);
  }
}
