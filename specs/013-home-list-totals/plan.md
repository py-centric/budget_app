# Implementation Plan: Home List Totals and Potential Balances

**Branch**: `013-home-list-totals` | **Date**: 2026-03-13 | **Spec**: [specs/013-home-list-totals/spec.md](spec.md)
**Input**: Feature specification from `/specs/013-home-list-totals/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

This feature enhances the `HomePage` by displaying actual and potential totals directly in the "Income" and "Expenses" dropdown headers. It requires updating the `BudgetSummary` entity and `CalculateSummary` use case to provide these totals, and modifying the `ExpansionTile` headers in the `HomePage` to render them.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `intl`  
**Storage**: SQLite (`income_entries`, `expense_entries` already support `is_potential`)  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Mobile (Android/iOS)  
**Project Type**: Mobile App  
**Performance Goals**: UI updates < 300ms  
**Constraints**: Offline-capable, must maintain layout integrity with dual-totals  
**Scale/Scope**: ~2 widget updates, 1 use case update  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Tech Stack: Adheres to Flutter/Dart/Bloc requirements.
- [x] Offline-First: Logic remains local.
- [x] Architecture: Updates existing Clean Architecture layers (Domain/Presentation).
- [x] UX: Reduces clicks to see high-level totals.

## Project Structure

### Documentation (this feature)

```text
specs/013-home-list-totals/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
└── features/
    └── budget/
        ├── domain/
        │   ├── entities/
        │   │   └── calculate_summary.dart (BudgetSummary entity)
        │   └── usecases/
        │       └── calculate_summary.dart (CalculateSummary logic)
        └── presentation/
            └── pages/
                └── home_page.dart (ExpansionTile headers)
```

**Structure Decision**: Single project (Feature-first Clean Architecture)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
