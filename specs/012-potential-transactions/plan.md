# Implementation Plan: Potential Transactions Tracking

**Branch**: `012-potential-transactions` | **Date**: 2026-03-13 | **Spec**: [specs/012-potential-transactions/spec.md](spec.md)
**Input**: Feature specification from `/specs/012-potential-transactions/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

This feature introduces the ability to track "Potential" transactions (income and expenses) that allow users to model hypothetical financial scenarios. These transactions are excluded from actual balance calculations but included in a secondary "Potential Balance" projection series. Users can confirm potential items to make them actual or delete them to remove the hypothesis.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `fl_chart`, `uuid`  
**Storage**: SQLite (`income_entries` and `expense_entries` tables updated with `is_potential` flag)  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Mobile (Android/iOS)  
**Project Type**: Mobile App  
**Performance Goals**: 60 fps UI interactions, < 200ms projection calculation  
**Constraints**: Offline-capable (SQLite only), must handle database migrations  
**Scale/Scope**: ~10 screens, dual-series line chart visualization  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Tech Stack: Adheres to Flutter/Dart/Bloc/SQLite requirements.
- [x] Offline-First: All potential data is stored locally.
- [x] Architecture: Follows Clean Architecture (UI -> Domain -> Data).
- [x] Migrations: Database version bump to 8 is required to add `is_potential` column.

## Project Structure

### Documentation (this feature)

```text
specs/012-potential-transactions/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── features/
│   └── budget/
│       ├── data/
│       │   ├── datasources/local_database.dart
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       │       ├── calculate_projection.dart
│       │       └── confirm_potential_transaction.dart
│       └── presentation/
│           ├── bloc/
│           └── widgets/
│               ├── potential_transaction_dialog.dart
│               └── projection_chart.dart
```

**Structure Decision**: Single project (Feature-first Clean Architecture)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
