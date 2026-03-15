# Implementation Plan: Home Page Projection and Enhanced Action Buttons

**Branch**: `008-home-projection-buttons` | **Date**: 2026-03-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/008-home-projection-buttons/spec.md`

## Summary

Enhance the Home page with a swipeable Projection Overview mini-chart and replace existing transaction entry buttons with a prominent, expanded Floating Action Button (FAB) group featuring background dimming. This plan also prioritizes fixing the underlying logic for the currently broken "Add Expense" functionality.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `fl_chart`, `sqflite`  
**Storage**: SQLite  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Mobile (Android/iOS)  
**Performance Goals**: Mini-chart rendering < 16ms (60fps); FAB animation < 300ms.  
**Constraints**: Must work fully offline; Material Design 3.  
**Scale/Scope**: UI/UX enhancement with critical bug fix.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack**: Uses Flutter, BLoC, and fl_chart as mandated. (PASS)
2. **Offline-First**: All data for mini-chart sourced from local SQLite. (PASS)
3. **Clean Architecture**: Mini-chart logic stays in BLoC; widget is presentation only. (PASS)
4. **UX/Accessibility**: Focuses on prominent touch targets and clear visual hierarchy (background dimming). (PASS)
5. **License Compliance**: Dependencies are OSI-approved. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/008-home-projection-buttons/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by speckit.tasks)
```

### Source Code (repository root)

```text
budget_app/lib/features/budget/presentation/
├── widgets/
│   ├── home_projection_overview.dart  # New
│   ├── transaction_speed_dial.dart    # New
│   └── expense_form.dart              # Updated (Fix)
└── pages/
    └── home_page.dart                 # Updated (Layout)
```

**Structure Decision**: Feature-first Clean Architecture as defined in the Constitution.

## Complexity Tracking

*(No violations)*
