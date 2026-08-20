import 'package:sqflite/sqflite.dart';

class MigrationsV29 {
  static Future<void> migrate(Database db, int oldVersion) async {
    if (oldVersion < 29) {
      await db.execute('ALTER TABLE income_entries ADD COLUMN account_id TEXT');
      await db.execute('ALTER TABLE expense_entries ADD COLUMN account_id TEXT');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_income_account ON income_entries (account_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_expense_account ON expense_entries (account_id)',
      );
    }
  }
}
