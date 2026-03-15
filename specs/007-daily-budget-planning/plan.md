# Implementation Plan: Daily Budget Planning and Projections

**Branch**: `007-daily-budget-planning` | **Date**: 2026-03-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/007-daily-budget-planning/spec.md`

## Summary

Implement daily and weekly budget planning by allowing specific dates for all transaction types (including income) and providing a visual financial projection (tabular and graphical). This feature introduces the `fl_chart` library for data visualization and a new `ProjectionUseCase` for calculating running balances over flexible horizons.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `fl_chart`, `intl`  
**Storage**: SQLite (via `sqflite`)  
**Testing**: `flutter_test`, `mockito`  
**Target Platform**: Mobile (Android/iOS) and Desktop (Linux/Windows/macOS)  
**Performance Goals**: <200ms for projection calculation on up to 90 days of data.  
**Constraints**: Offline-first (Local storage only); Material Design 3.  
**Scale/Scope**: Extension of the core budget management feature.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack**: Uses Flutter, BLoC, and SQLite as mandated. `fl_chart` is MIT licensed (OSI-approved). (PASS)
2. **Offline-First**: Operates purely on local SQLite. No external APIs used. (PASS)
3. **Clean Architecture**: Design follows UI → Domain → Data layering. (PASS)
4. **UX/Accessibility**: Includes high-priority Material 3 visual projections and configurable settings for pay cycles. (PASS)
5. **License Compliance**: `fl_chart` is permissively licensed. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/007-daily-budget-planning/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
budget_app/lib/features/budget/
├── domain/
│   ├── entities/ (projection_point.dart)
│   └── usecases/ (calculate_projection.dart)
├── data/
│   ├── repositories/ (budget_repository_impl.dart - updated)
│   └── datasources/ (local_database.dart - updated)
└── presentation/
    ├── bloc/ (projection_bloc.dart)
    ├── widgets/ (projection_chart.dart, projection_table.dart)
    └── pages/ (projection_page.dart)
```

**Structure Decision**: Feature-first Clean Architecture as defined in the Constitution.

## Complexity Tracking

*(No violations)*
