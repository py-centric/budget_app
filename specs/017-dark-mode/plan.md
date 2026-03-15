# Implementation Plan: Dark Mode Support

**Branch**: `017-dark-mode` | **Date**: 2026-03-13 | **Spec**: [specs/017-dark-mode/spec.md](spec.md)
**Input**: Feature specification from `/specs/017-dark-mode/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

This feature adds support for Light, Dark, and System themes. Users can manually switch themes in settings, and the preference will be persisted using `HydratedBloc`. The `MaterialApp` in `main.dart` will be updated to reactively change the `themeMode` based on the current settings.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `hydrated_bloc`  
**Storage**: `hydrated_bloc` (persistent JSON storage)  
**Testing**: `flutter_test`  
**Target Platform**: Android/iOS  
**Project Type**: Mobile App  
**Performance Goals**: < 200ms theme transition  
**Constraints**: Offline-capable, persistent preferences  
**Scale/Scope**: Update `UserSettings`, `SettingsBloc`, `main.dart`, and `SettingsPage`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Tech Stack: Uses existing Flutter/Bloc/HydratedBloc architecture.
- [x] Offline-First: Settings stored locally.
- [x] Architecture: Follows Clean Architecture (Domain -> Data -> Presentation).
- [x] Accessibility: Ensuring WCAG contrast standards in Dark mode.

## Project Structure

### Documentation (this feature)

```text
specs/017-dark-mode/
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
│   ├── budget/
│   │   └── data/
│   │       └── models/
│   │           └── user_settings.dart  # Add themeMode
│   └── settings/
│       └── presentation/
│           ├── bloc/
│           │   └── settings_bloc.dart  # Handle theme changes
│           └── pages/
│               └── settings_page.dart  # Add theme selector
└── main.dart                           # React to theme changes
```

**Structure Decision**: Single project (Feature-first Clean Architecture)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
