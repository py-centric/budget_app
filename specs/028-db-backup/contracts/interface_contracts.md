# Interface Contracts: Database Backup & Restore

## BackupBloc

### Events

```dart
abstract class BackupEvent extends Equatable {
  const BackupEvent();
  
  @override
  List<Object?> get props => [];
}

/// Export database to backup file
class BackupExport extends BackupEvent {}

/// Import database from backup file
class BackupImport extends BackupEvent {
  final String filePath;
  
  const BackupImport({required this.filePath});
  
  @override
  List<Object?> get props => [filePath];
}

/// Share backup file
class BackupShare extends BackupEvent {
  final String filePath;
  
  const BackupShare({required this.filePath});
  
  @override
  List<Object?> get props => [filePath];
}

/// Validate backup file
class BackupValidate extends BackupEvent {
  final String filePath;
  
  const BackupValidate({required this.filePath});
  
  @override
  List<Object?> get props => [filePath];
}

/// Reset backup state
class BackupReset extends BackupEvent {}
```

### States

```dart
abstract class BackupState extends Equatable {
  const BackupState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class BackupInitial extends BackupState {}

/// Loading/processing state
class BackupLoading extends BackupState {
  final String message;
  final int progress; // 0-100
  
  const BackupLoading({
    this.message = 'Processing...',
    this.progress = 0,
  });
  
  @override
  List<Object?> get props => [message, progress];
}

/// Operation succeeded
class BackupSuccess extends BackupState {
  final String filePath;
  final String message;
  final int? tableCount;
  final int? recordCount;
  
  const BackupSuccess({
    required this.filePath,
    required this.message,
    this.tableCount,
    this.recordCount,
  });
  
  @override
  List<Object?> get props => [filePath, message, tableCount, recordCount];
}

/// Operation failed
class BackupError extends BackupState {
  final String message;
  
  const BackupError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
```

## BackupService Interface

```dart
abstract class BackupService {
  /// Export database to backup file
  /// Returns path to created backup file
  Future<String> exportDatabase();
  
  /// Import database from backup file
  /// Returns ImportResult with success status and details
  Future<ImportResult> importDatabase(String filePath);
  
  /// Validate backup file is valid SQLite database
  /// Returns true if valid
  Future<bool> validateBackup(String filePath);
  
  /// Share backup file via system share sheet
  Future<void> shareBackup(String filePath);
  
  /// Get database file path
  Future<String> getDatabasePath();
}
```

## ImportResult

```dart
class ImportResult {
  final bool success;
  final int tablesImported;
  final int recordsImported;
  final String? errorMessage;
  
  const ImportResult({
    required this.success,
    this.tablesImported = 0,
    this.recordsImported = 0,
    this.errorMessage,
  });
  
  factory ImportResult.failure(String error) => ImportResult(
    success: false,
    errorMessage: error,
  );
}
```

## File Naming Convention

Generated backup files:
```
budget_backup_YYYYMMDD_HHMMSS.db

Example:
budget_backup_20260324_143022.db
```
