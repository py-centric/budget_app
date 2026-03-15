# Implementation Plan: Recurring Transactions

**Branch**: `010-recurring-transactions` | **Date**: 2026-03-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/010-recurring-transactions/spec.md`

## Summary

Implement recurring income and expenses with flexible frequencies (Every X Days/Weeks/Months/Years). This feature includes the ability to override specific occurrences and automatically integrates these planned transactions into the financial projections (graph and table).

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `intl`, `uuid`  
**Storage**: SQLite (`recurring_transactions`, `recurring_overrides` tables)  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Android, iOS, Desktop (Linux/Windows/macOS)  
**Performance Goals**: Projection calculation including recurrences < 300ms for a 90-day horizon.  
**Constraints**: Fully offline operation as per Constitution.  
**Scale/Scope**: Data model expansion and Use Case integration.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack**: Uses Flutter, BLoC, and SQLite. (PASS)
2. **Offline-First**: All recurrence calculations and overrides are local. (PASS)
3. **Clean Architecture**: Domain layer handles calculation logic; Data layer handles SQLite templates. (PASS)
4. **UX/Accessibility**: Integrated into existing transaction forms; clear indicators in projection table. (PASS)
5. **License Compliance**: No new external dependencies introduced. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/010-recurring-transactions/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by speckit.tasks)
```

### Source Code (repository root)

```text
budget_app/lib/features/budget/
├── domain/
│   ├── entities/ (recurring_transaction.dart, recurring_override.dart)
│   └── usecases/ (manage_recurring.dart, update to calculate_projection.dart)
├── data/
│   ├── models/ (recurring_model.dart)
│   └── datasources/ (local_database.dart - table updates)
└── presentation/
    ├── widgets/ (recurring_settings_widget.dart)
    └── pages/ (manage_recurring_page.dart)
```

**Structure Decision**: Feature-first Clean Architecture as defined in the Constitution.

## Complexity Tracking

*(No violations)*
