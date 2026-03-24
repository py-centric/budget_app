# Implementation Plan: Database Backup & Restore

**Branch**: `028-db-backup` | **Date**: 2026-03-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/028-db-backup/spec.md`

## Summary

**Primary Requirement**: Allow users to export the entire SQLite database to a file and import a SQLite database backup.

**Technical Approach**: Use sqflite for database operations, path_provider for file access, and share_plus for sharing. Implement backup service to copy database file and restore service to replace database.

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.x)  
**Primary Dependencies**: sqflite (existing), path_provider (existing), share_plus (existing from export feature)  
**Storage**: SQLite database + local file system for backups  
**Testing**: flutter_test, mocktail (existing)  
**Target Platform**: iOS 15+, Android (latest stable)  
**Project Type**: Mobile-app (Flutter)  
**Performance Goals**: Export/import under 30-60 seconds  
**Constraints**: Offline-only, backup files stored locally  
**Scale/Scope**: Single user, local backup

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Use Flutter/Dart | ✅ PASS | Feature uses Dart with Flutter framework per constitution |
| Offline-First Architecture | ✅ PASS | All data stored locally; backup to local storage |
| SQLite Storage | ✅ PASS | Uses existing sqflite for database operations |
| Clean Architecture | ✅ PASS | Feature follows Clean Architecture pattern |
| License Compliance | ✅ PASS | All dependencies have permissive licenses |

**Constitution Alignment**: All gates pass. No violations detected.

## Project Structure

### Documentation (this feature)

```text
specs/028-db-backup/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md            # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── features/
│   ├── settings/                    # Existing - add backup UI
│   └── backup/                      # NEW feature
│       ├── data/
│       │   └── services/
│       └── presentation/
│           ├── bloc/
│           └── widgets/
└── core/
    └── database/
        └── local_database.dart      # Existing - access for backup

test/
├── unit/
└── widget/
```

**Structure Decision**: New backup feature module with Clean Architecture. Reuses existing LocalDatabase and shares UI with Settings.

---

# Phase 0: Research

## Research Findings

### 1. Database Backup Strategy
- **Decision**: Copy SQLite database file directly
- **Rationale**: Simple, complete backup of all data including schema
- **Alternatives Considered**: Export to JSON (loses schema), manual table export (complex)

### 2. Database Restore Strategy
- **Decision**: Replace database file after validation
- **Rationale**: Complete restoration of all data
- **Alternatives Considered**: Merge data (complex, potential conflicts)

### 3. File Validation
- **Decision**: Verify SQLite file header and schema
- **Rationale**: Detect corrupted or invalid files before restore
- **Alternatives Considered**: Try-catch on open (less informative)

---

# Phase 1: Design & Contracts

## Data Model

### DatabaseBackup
| Field | Type | Description |
|-------|------|-------------|
| `filePath` | String | Path to backup file |
| `createdAt` | DateTime | Backup creation timestamp |
| `sizeBytes` | int | File size |
| `tableCount` | int | Number of tables |

### ImportResult
| Field | Type | Description |
|-------|------|-------------|
| `success` | bool | Whether import succeeded |
| `tablesImported` | int | Tables restored |
| `recordsImported` | int | Total records restored |
| `errorMessage` | String? | Error if failed |

## Interface Contracts

### BackupBloc Events
- `BackupExport` - Create database backup
- `BackupImport(filePath)` - Import from backup file
- `BackupShare` - Share backup file
- `BackupValidate(filePath)` - Validate backup file

### BackupBloc States
- `BackupInitial` - Initial state
- `BackupLoading` - Processing
- `BackupSuccess(result)` - Operation succeeded
- `BackupError(message)` - Operation failed

### BackupService Interface
```dart
abstract class BackupService {
  Future<String> exportDatabase();
  Future<ImportResult> importDatabase(String filePath);
  Future<bool> validateBackup(String filePath);
  Future<void> shareBackup(String filePath);
}
```

## Quickstart

### Developer Setup
1. No new dependencies needed (uses existing)
2. Create BackupService for database operations
3. Create BackupBloc for state management
4. Add backup/restore buttons to Settings page

### Integration Points
- LocalDatabase: Access database path for backup
- Settings page: Add backup/restore UI
- Share functionality: Reuse from export feature

### Test Scenarios
1. Export database - verify file created with correct size
2. Import database - verify all tables and data restored
3. Import invalid file - verify error shown
4. Share backup - verify share sheet opens
