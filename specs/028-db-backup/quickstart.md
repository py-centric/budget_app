# Quickstart: Database Backup & Restore

## Developer Setup

### 1. Dependencies

No new dependencies required - uses existing:
- `sqflite` - Database access
- `path_provider` - File paths
- `share_plus` - File sharing (from export feature)

### 2. Project Structure

Create the following directory structure:

```
lib/features/backup/
├── data/
│   └── services/
│       └── backup_service_impl.dart
├── domain/
│   └── services/
│       └── backup_service.dart
└── presentation/
    ├── bloc/
    │   ├── backup_bloc.dart
    │   ├── backup_event.dart
    │   └── backup_state.dart
    └── widgets/
        └── backup_dialog.dart
```

### 3. Integration Points

- **LocalDatabase**: Access database path for backup
- **SettingsPage**: Add backup/restore buttons

## Test Scenarios

### Export Database
1. Tap "Backup Database" in Settings
2. Verify file created: `budget_backup_YYYYMMDD_HHMMSS.db`
3. Verify file size > 0

### Import Database
1. Tap "Restore Database" in Settings
2. Select backup file
3. Verify success message with table count
4. Verify data restored (check transactions, categories)

### Invalid File Import
1. Select non-SQLite file
2. Verify error message shown
3. Verify existing data unchanged

### Share Backup
1. After export, tap "Share"
2. Verify share sheet appears

### Large Database (>50MB)
1. Export large database
2. Verify progress indicator shown
3. Verify operation completes successfully
