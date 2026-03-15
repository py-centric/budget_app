# Implementation Plan: Duplicate Budgets

**Branch**: `011-duplicate-budgets` | **Date**: 2026-03-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/011-duplicate-budgets/spec.md`

## Summary

Implement the ability to duplicate budgets across periods and support multiple distinct budgets within the same month. This involves a significant data model migration to introduce a `budgets` table and updating the application navigation to be budget-centric rather than implicitly period-centric.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `uuid`  
**Storage**: SQLite (v6 migration)  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Android, iOS, Desktop (Linux/Windows/macOS)  
**Performance Goals**: Duplication of a full budget in < 1.5s.  
**Constraints**: Fully offline operation; must preserve all existing user data via backfilling.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack**: Uses Flutter, BLoC, and SQLite. (PASS)
2. **Offline-First**: All duplication and migration logic is local. (PASS)
3. **Clean Architecture**: Design separates migration logic (Data) from duplication logic (Domain). (PASS)
4. **UX/Accessibility**: Adds flexibility for planning versions and reduces setup friction. (PASS)
5. **License Compliance**: No new dependencies. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/011-duplicate-budgets/
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
│   ├── entities/ (budget.dart)
│   └── usecases/ (duplicate_budget.dart)
├── data/
│   ├── repositories/ (budget_repository_impl.dart - updated)
│   └── datasources/ (local_database.dart - updated)
└── presentation/
    ├── bloc/ (navigation_bloc.dart - updated)
    └── widgets/ (budget_selector.dart, duplication_dialog.dart)
```

**Structure Decision**: Feature-first Clean Architecture as defined in the Constitution.

## Complexity Tracking

*(No violations)*
