# Tasks: Budget Export Feature (027-budget-export)

**Feature**: Budget Export (CSV, PDF, Excel)  
**Branch**: `027-budget-export` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Summary

- **Total Tasks**: 26
- **User Stories**: 5
- **Parallelizable Tasks**: 9
- **MVP Scope**: User Story 1 + User Story 2 (CSV + PDF exports)

## Dependencies Graph

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational)
    │
    ├─────────────────────┬─────────────────────┐
    ▼                     ▼                     ▼
Phase 3 [US1]        Phase 4 [US2]        Phase 5 [US3]
CSV Export           PDF Export           Excel Export
    │                     │                     │
    └─────────────────────┼─────────────────────┘
                         ▼
                   Phase 6 [US4]
              Select Export Period
                         │
                         ▼
                   Phase 7 [US5]
                   Share Files
                         │
                         ▼
                   Phase 8 (Polish)
```

## Parallel Execution Examples

- T001, T002, T003 (Setup) can run in parallel
- T006, T007, T008 (entities) can run in parallel
- T009b, T009c, T009d (BLoC) can run in parallel
- T010, T013, T015 (format generation) can run in parallel

---

## Phase 1: Setup

- [X] T001 Add csv dependency to pubspec.yaml
- [X] T002 Add excel dependency to pubspec.yaml
- [X] T003 Add share_plus dependency to pubspec.yaml
- [X] T004 Run flutter pub get to install dependencies

---

## Phase 2: Foundational

- [X] T005 [P] Create export feature directory structure
- [X] T006 Create ExportConfiguration entity in budget_app/lib/features/export/domain/entities/export_configuration.dart
- [X] T007 Create ExportFormat enum in budget_app/lib/features/export/domain/entities/export_format.dart
- [X] T008 Create ExportPeriod enum in budget_app/lib/features/export/domain/entities/export_period.dart
- [X] T009 Create ExportService interface in budget_app/lib/features/export/domain/services/export_service.dart
- [X] T009b [P] Create ExportBloc in budget_app/lib/features/export/presentation/bloc/export_bloc.dart
- [X] T009c [P] Create ExportEvent in budget_app/lib/features/export/presentation/bloc/export_event.dart
- [X] T009d [P] Create ExportState in budget_app/lib/features/export/presentation/bloc/export_state.dart
- [X] T009e Add transaction fetching from BudgetRepository in budget_app/lib/features/export/data/services/export_service_impl.dart

---

## Phase 3: User Story 1 - Export Budget to CSV [US1]

**Goal**: Allow users to export budget data to CSV format

**Independent Test**: Open a budget period, tap "Export", select CSV format, receive file that opens correctly in Excel/Google Sheets.

- [X] T010 [US1] Implement CSV generation in ExportService in budget_app/lib/features/export/data/services/export_service_impl.dart
- [X] T011 [US1] Create export dialog widget with format selection in budget_app/lib/features/export/presentation/widgets/export_dialog.dart
- [X] T012 [US1] Add export button to budget period view in budget_app/lib/features/budget/presentation/pages/home_page.dart

---

## Phase 4: User Story 2 - Export Budget to PDF [US2]

**Goal**: Allow users to export budget summary to PDF format

**Independent Test**: Open a budget period, tap "Export", select PDF format, receive a formatted PDF document.

- [X] T013 [US2] Implement PDF generation in ExportService in budget_app/lib/features/export/data/services/export_service_impl.dart
- [X] T014 [US2] Create PDF report layout with summary in budget_app/lib/features/export/data/services/pdf_report_generator.dart

---

## Phase 5: User Story 3 - Export Budget to Excel [US3]

**Goal**: Allow users to export budget to Excel format with color-coded categories

**Independent Test**: Open a budget period, tap "Export", select Excel format, receive an .xlsx file that opens in Excel with proper formatting.

- [X] T015 [US3] Implement Excel generation in ExportService in budget_app/lib/features/export/data/services/export_service_impl.dart

---

## Phase 6: User Story 4 - Select Export Period [US4]

**Goal**: Allow users to choose export period (current month, custom range, all time)

**Independent Test**: Open export dialog, select date range, verify exported data matches selected period.

- [X] T016 [US4] Create period selector widget in budget_app/lib/features/export/presentation/widgets/period_selector_widget.dart
- [X] T017 [US4] Implement data fetching by period in budget_app/lib/features/export/data/services/export_service_impl.dart

---

## Phase 7: User Story 5 - Share Exported Files [US5]

**Goal**: Allow users to share exported files via system share sheet

**Independent Test**: Export a file, tap "Share", select a sharing method (email, messaging, etc.)

- [X] T018 [US5] Implement share functionality in ExportService in budget_app/lib/features/export/data/services/export_service_impl.dart
- [X] T019 [US5] Create export dialog with share and save buttons in budget_app/lib/features/export/presentation/widgets/export_dialog.dart
- [X] T019b Implement save file functionality in ExportService

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T020 Add progress indicator for large datasets in budget_app/lib/features/export/presentation/widgets/export_progress_widget.dart
- [X] T021 Handle empty budget edge case in ExportBloc
- [X] T022 Add error handling for export failures in budget_app/lib/features/export/presentation/bloc/export_bloc.dart

---

## Implementation Strategy

### MVP (User Stories 1 + 2)

1. Setup: T001-T004
2. Foundational: T005-T009
3. CSV Export: T010-T012
4. PDF Export: T013-T014
5. Polish: T020-T022

### Incremental Delivery

- **Increment 1**: Setup + Foundational (T001-T009)
- **Increment 2**: CSV Export (T010-T012)
- **Increment 3**: PDF Export (T013-T014)
- **Increment 4**: Excel Export (T015)
- **Increment 5**: Period Selection (T016-T017)
- **Increment 6**: Share Files (T018-T019)
- **Increment 7**: Polish (T020-T022)
