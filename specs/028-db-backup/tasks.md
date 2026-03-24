# Tasks: Database Backup & Restore (028-db-backup)

**Feature**: Database Backup & Restore  
**Branch**: `028-db-backup` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Summary

- **Total Tasks**: 17
- **User Stories**: 3
- **Parallelizable Tasks**: 5
- **MVP Scope**: User Story 1 + User Story 2 (Export + Import)

## Dependencies Graph

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational)
    │
    ├─────────────────────┐
    ▼                     ▼
Phase 3 [US1]        Phase 4 [US2]
Export Database      Import Database
    │                     │
    └──────────┬──────────┘
               ▼
          Phase 5 [US3]
          Share Backup
               │
               ▼
          Phase 6 (Polish)
```

## Parallel Execution Examples

- T001, T002 (Setup) can run in parallel
- T003, T004 (entities + service interface) can run in parallel
- T005, T006 (BLoC) can run in parallel

---

## Phase 1: Setup

- [X] T001 Add backup feature directory structure
- [X] T002 Verify existing dependencies (sqflite, path_provider, share_plus)

---

## Phase 2: Foundational

- [X] T003 [P] Create ImportResult entity in budget_app/lib/features/backup/domain/entities/import_result.dart
- [X] T004 Create BackupService interface in budget_app/lib/features/backup/domain/services/backup_service.dart
- [X] T004b Access LocalDatabase path for backup in budget_app/lib/features/backup/data/services/backup_service_impl.dart

---

## Phase 3: User Story 1 - Export Database [US1]

**Goal**: Allow users to export the entire SQLite database to a file

**Independent Test**: Go to Settings, tap "Backup Database", receive .db file saved to device or shared.

- [X] T005 [P] [US1] Create BackupBloc in budget_app/lib/features/backup/presentation/bloc/backup_bloc.dart
- [X] T006 [P] [US1] Create BackupEvent in budget_app/lib/features/backup/presentation/bloc/backup_event.dart
- [X] T007 [P] [US1] Create BackupState in budget_app/lib/features/backup/presentation/bloc/backup_state.dart
- [X] T008 [US1] Implement BackupService in budget_app/lib/features/backup/data/services/backup_service_impl.dart
- [X] T008b [US1] Create backup dialog widget in budget_app/lib/features/backup/presentation/widgets/backup_dialog.dart
- [X] T009 [US1] Add backup/restore buttons to Settings page in budget_app/lib/features/settings/presentation/pages/settings_page.dart

---

## Phase 4: User Story 2 - Import Database [US2]

**Goal**: Allow users to import a SQLite database backup

**Independent Test**: Go to Settings, tap "Restore Database", select a .db file, verify all data is restored.

- [X] T010 [US2] Add import/restore functionality to BackupService in budget_app/lib/features/backup/data/services/backup_service_impl.dart
- [X] T012 [US2] Add file picker for selecting backup files in budget_app/lib/features/settings/presentation/pages/settings_page.dart

---

## Phase 5: User Story 3 - Share Backup [US3]

**Goal**: Allow users to share backup files via system share sheet

**Independent Test**: Export database, tap "Share", select sharing method (email, cloud, etc.)

- [X] T013 [US3] Add share functionality to BackupService in budget_app/lib/features/backup/data/services/backup_service_impl.dart
- [X] T014 [US3] Add share button to backup dialog in budget_app/lib/features/settings/presentation/pages/settings_page.dart

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T015 Add progress indicator for large database operations in backup_service_impl.dart
- [X] T016 Add error handling for corrupted files and insufficient storage in BackupService

---

## Implementation Strategy

### MVP (User Stories 1 + 2)

1. Setup: T001-T002
2. Foundational: T003-T004
3. Export: T005-T009
4. Import: T010-T012
5. Polish: T015-T016

### Incremental Delivery

- **Increment 1**: Setup + Foundational (T001-T004)
- **Increment 2**: Export Database (T005-T009)
- **Increment 3**: Import Database (T010-T012)
- **Increment 4**: Share Backup (T013-T014)
- **Increment 5**: Polish (T015-T016)