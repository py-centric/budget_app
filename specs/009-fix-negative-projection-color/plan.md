# Implementation Plan: Show red color for negative balances in projection graphs

**Branch**: `009-fix-negative-projection-color` | **Date**: 2026-03-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/009-fix-negative-projection-color/spec.md`

## Summary

This feature addresses a visual inconsistency where negative balances in the projection graphs and tables were displayed using the standard positive color (green). We will implement conditional styling for the `ProjectionTable` and use linear gradients with calculated stops for the `fl_chart` components to ensure a sharp transition to red when the balance drops below zero.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `fl_chart`, `flutter_bloc`  
**Storage**: N/A (UI logic change only)  
**Testing**: `flutter_test` (Widget tests for color verification)  
**Target Platform**: Android, iOS, Linux, Windows, macOS  
**Performance Goals**: Zero impact on chart rendering latency (<16ms frame target).  
**Constraints**: Sharp transition at exactly zero balance.  
**Scale/Scope**: Affects all projection-related widgets.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack**: Uses existing Flutter and `fl_chart` stack. (PASS)
2. **Offline-First**: Purely local UI logic. (PASS)
3. **Clean Architecture**: Domain entity `ProjectionPoint` will provide the business rule for coloring, while Presentation layer handles rendering. (PASS)
4. **UX/Accessibility**: Improves financial safety by providing immediate visual risk alerts. Uses high-contrast red/green. (PASS)
5. **License Compliance**: No new dependencies introduced. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/009-fix-negative-projection-color/
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
│   └── entities/ (projection_point.dart)
└── presentation/
    └── widgets/
        ├── projection_table.dart
        ├── projection_chart.dart
        └── home_projection_overview.dart
```

**Structure Decision**: Feature-first Clean Architecture as defined in the Constitution.

## Complexity Tracking

*(No violations)*
