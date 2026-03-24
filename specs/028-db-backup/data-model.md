# Data Model: Database Backup & Restore

## Backup Entities

### DatabaseBackup
| Field | Type | Description |
|-------|------|-------------|
| `filePath` | `String` | Path to backup file |
| `createdAt` | `DateTime` | Backup creation timestamp |
| `sizeBytes` | `int` | File size in bytes |
| `tableCount` | `int` | Number of tables in database |

### ImportResult
| Field | Type | Description |
|-------|------|-------------|
| `success` | `bool` | Whether import succeeded |
| `tablesImported` | `int` | Number of tables restored |
| `recordsImported` | `int` | Total records restored |
| `errorMessage` | `String?` | Error message if failed |

## State Transitions

### Backup Flow
```
User initiates backup
    │
    ▼
Create backup file
    │
    ├─► Success: Save to storage, return path
    │
    └─► Failure: Show error message
```

### Restore Flow
```
User selects backup file
    │
    ▼
Validate file (is valid SQLite?)
    │
    ├─► Invalid: Show error, keep existing data
    │
    └─► Valid:
          │
          ▼
    Close existing database
          │
          ▼
    Replace database file
          │
          ▼
    Verify restore
          │
          ├─► Success: Show success message
          │
          └─► Failure: Rollback to previous database
```

## Persistence

- Backup files stored in app's documents directory
- Backup files named: `budget_backup_YYYYMMDD_HHMMSS.db`
- Temporary backups cleaned up after successful import
- No permanent metadata storage needed (stateless)

## Data Source

- Database accessed via existing LocalDatabase class
- Database path retrieved from sqflite
- Schema validated by checking SQLite header
