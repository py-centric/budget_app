# Implementation Plan: Global Currency Selection

**Branch**: `016-currency-selection` | **Date**: 2026-03-13 | **Spec**: [specs/016-currency-selection/spec.md](spec.md)
**Input**: Feature specification from `/specs/016-currency-selection/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

This feature implements a global currency selection mechanism. It involves:
1.  **Domain Layer**: Updating `UserSettings` entity and creating a `CurrencyFormatter` utility.
2.  **Data Layer**: Persisting the selected currency using `HydratedBloc`.
3.  **Presentation Layer**: Creating a `SettingsPage` with a currency selector and updating all monetary widgets to use the centralized formatter.
4.  **Onboarding**: Implementing automatic locale detection on first launch.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `hydrated_bloc`, `intl` (using built-in `PlatformDispatcher` for locale detection)  
**Storage**: `hydrated_bloc` (persistent JSON storage for user preferences)  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Mobile (Android/iOS)  
**Project Type**: Mobile App  
**Performance Goals**: UI updates all currency symbols < 300ms  
**Constraints**: Must be offline-capable, no currency conversion logic required  
**Scale/Scope**: 1 new settings page, ~10 widgets updated for global formatting  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Tech Stack: Uses existing Flutter/Bloc/HydratedBloc architecture.
- [x] Offline-First: All settings stored locally via HydratedBloc.
- [x] Architecture: Follows UI -> Domain -> Data layers.
- [x] UX: Improves accessibility and localization.

## Project Structure

### Documentation (this feature)

```text
specs/016-currency-selection/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── utils/
│       └── currency_formatter.dart  # Centralized utility
├── features/
│   └── settings/
│       ├── presentation/
│       │   ├── bloc/
│       │   │   └── settings_bloc.dart # Manages currency state
│       │   └── pages/
│       │       └── settings_page.dart # Selection UI
└── shared/
    └── widgets/
        └── monetary_text.dart       # Reusable formatted text widget
```

**Structure Decision**: Single project (Feature-first Clean Architecture)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
