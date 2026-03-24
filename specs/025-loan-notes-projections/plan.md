# Implementation Plan: [FEATURE]

**Branch**: `025-loan-notes-projections` | **Date**: 2026-03-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/025-loan-notes-projections/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

**Primary Requirement**: Enhance Loan Management feature with ability to add notes, track loans made to user (Owed to Me), and optionally include in financial projections.

**Technical Approach**: Extend existing Loan entity with new fields (notes, direction, includeInProjections). Add database migration. Update UI with tabs for Lent/Owed. Integrate with ProjectionBloc for financial planning.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart 3.x (Flutter 3.x)  
**Primary Dependencies**: flutter_bloc, sqflite (existing project dependencies)  
**Storage**: SQLite via sqflite (existing), add migration for new loan fields  
**Testing**: flutter_test, mocktail (existing)  
**Target Platform**: iOS 15+, Android  
**Project Type**: Mobile-app (Flutter)  
**Performance Goals**: UI at 60fps, view switching under 200ms  
**Constraints**: Offline-only, no cloud sync  
**Scale/Scope**: Extends existing loan feature (024)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Use Flutter/Dart | ✅ PASS | Feature uses Dart with Flutter framework per constitution |
| Offline-First Architecture | ✅ PASS | All data stored locally via SQLite; no external APIs |
| SQLite Storage | ✅ PASS | Using sqflite for local database per constitution |
| Clean Architecture | ✅ PASS | Feature follows existing loan module structure |
| License Compliance | ✅ PASS | Uses existing approved dependencies |
| Migrations | ✅ PASS | Will add database migration per constitution Section 3 |

**Constitution Alignment**: All gates pass. No violations detected.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── constants/
├── features/
│   ├── budget/
│   │   └── data/datasources/    # local_database.dart
│   └── loans/                   # This feature (extends 024)
│       ├── data/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   └── repositories/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
└── shared/
    └── widgets/

test/
├── unit/
└── widget/
```

**Structure Decision**: Extends existing loans feature in `lib/features/loans/`. Reuses existing database infrastructure.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
