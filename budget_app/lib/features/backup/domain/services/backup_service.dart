import '../entities/import_result.dart';

abstract class BackupService {
  Future<String> exportDatabase();
  Future<ImportResult> importDatabase(String filePath);
  Future<bool> validateBackup(String filePath);
  Future<void> shareBackup(String filePath);
  Future<String> getDatabasePath();
}
