# Implementation Plan: Emergency Fund Calculator

**Branch**: `019-emergency-fund-calculator` | **Date**: Sunday, 15 March 2026 | **Spec**: [specs/019-emergency-fund-calculator/spec.md]
**Input**: Feature specification from `/specs/019-emergency-fund-calculator/spec.md`

## Summary

Implement a new "Emergency Fund Calculator" within the Financial Tools section. The tool will suggest common emergency expenses (insurance excess, car tyres, etc.) while allowing custom entries. It includes a "Living Expenses" calculator that can automatically derive 3-12 month targets from existing budget data. The final target is persisted globally to be used by other features like projections.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `intl`  
**Storage**: SQLite (sqflite) for persistence of entries and global target  
**Testing**: `flutter_test`, `mocktail` (unit and widget tests)  
**Target Platform**: Android, iOS, Linux, Web (Cross-platform Flutter)
**Project Type**: Mobile/Desktop Application feature  
**Performance Goals**: Instant calculation updates (<100ms), smooth scrolling list  
**Constraints**: Offline-first (no external APIs), Material Design 3  
**Scale/Scope**: 1 new screen, 1 new BLoC, 1 new database table

**Unknowns (NEEDS CLARIFICATION)**:
- [NEEDS CLARIFICATION: exact algorithm for "automatic calculation" of living expenses (average of all time, last 3 months, or current month's budget?)]
- [NEEDS CLARIFICATION: how to best expose the "global target" to other Blocs (e.g., via a dedicated SettingsRepository or a shared EmergencyFundRepository?)]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Tech Stack Compliance**: Yes (Dart/Flutter, BLoC, SQLite).
- **Offline-First**: Yes (Local SQLite storage).
- **Clean Architecture**: Yes (Feature-first structure: `lib/features/emergency_fund`).
- **Material Design 3**: Yes.
- **Migrations**: Required (New table for emergency expenses).

**GATES PASSED**: Yes.

## Project Structure

### Documentation (this feature)

```text
specs/019-emergency-fund-calculator/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Research findings (Phase 0)
├── data-model.md        # Data entities and DB schema (Phase 1)
├── quickstart.md        # Implementation guide (Phase 1)
├── checklists/          # Validation checklists
│   └── requirements.md
└── tasks.md             # Task breakdown (Phase 2)
```

### Source Code (repository root)

```text
lib/
├── features/
│   └── emergency_fund/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── shared/
│   └── data/
│       └── local_database.dart (updated for migrations)
```

**Structure Decision**: Feature-first Clean Architecture as mandated by the Constitution. The `emergency_fund` feature is isolated in `lib/features/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
