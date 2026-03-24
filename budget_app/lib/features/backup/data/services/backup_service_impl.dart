import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/import_result.dart';
import '../../domain/services/backup_service.dart';
import '../../../budget/data/datasources/local_database.dart';

class BackupServiceImpl implements BackupService {
  @override
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return p.join(databasesPath, 'budget.db');
  }

  @override
  Future<String> exportDatabase() async {
    final dbPath = await getDatabasePath();
    final sourceFile = File(dbPath);

    if (!await sourceFile.exists()) {
      throw Exception('Database file not found');
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFileName = 'budget_backup_$timestamp.db';

    final dir = await getApplicationDocumentsDirectory();
    final backupPath = '${dir.path}/$backupFileName';

    await sourceFile.copy(backupPath);
    return backupPath;
  }

  @override
  Future<ImportResult> importDatabase(String filePath) async {
    try {
      final backupFile = File(filePath);

      if (!await backupFile.exists()) {
        return ImportResult.failure('Backup file not found');
      }

      if (!await validateBackup(filePath)) {
        return ImportResult.failure(
          'Invalid backup file - not a valid SQLite database',
        );
      }

      final currentDbPath = await getDatabasePath();
      final db = await LocalDatabase.instance.database;
      await db.close();

      final currentDbFile = File(currentDbPath);
      final tempBackupPath = '$currentDbPath.backup';
      await currentDbFile.copy(tempBackupPath);

      try {
        await backupFile.copy(currentDbPath);

        final db2 = await openDatabase(
          currentDbPath,
          version: 1,
          readOnly: false,
        );

        final tables = await db2.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        );

        int totalRecords = 0;
        for (final table in tables) {
          final tableName = table['name'] as String;
          final count =
              Sqflite.firstIntValue(
                await db2.rawQuery('SELECT COUNT(*) FROM $tableName'),
              ) ??
              0;
          totalRecords += count;
        }

        final tempFile = File(tempBackupPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        return ImportResult(
          success: true,
          tablesImported: tables.length,
          recordsImported: totalRecords,
        );
      } catch (e) {
        final tempFile = File(tempBackupPath);
        if (await tempFile.exists()) {
          await tempFile.copy(currentDbPath);
        }
        LocalDatabase.instance.database;
        return ImportResult.failure(
          'Failed to restore database: ${e.toString()}',
        );
      }
    } catch (e) {
      return ImportResult.failure('Import failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> validateBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final bytes = await file.openRead(0, 16).first;
      final header = String.fromCharCodes(bytes);

      return header.startsWith('SQLite format 3');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> shareBackup(String filePath) async {
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(filePath)]);
  }
}
