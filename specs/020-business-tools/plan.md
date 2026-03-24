# Implementation Plan: Business Tools

**Branch**: `020-business-tools` | **Date**: Sunday, 15 March 2026 | **Spec**: [specs/020-business-tools/spec.md]
**Input**: Feature specification from `/specs/020-business-tools/spec.md`

## Summary

Implement a suite of business tools including VAT/exVAT calculators, a multi-profile invoice builder, and PDF generation with persistent storage. The feature will be built using the Clean Architecture pattern, following the project's BLoC state management and SQLite persistence standards.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `pdf`, `printing`, `intl`, `uuid`, `path_provider`  
**Storage**: SQLite (via `sqflite`) for profiles, invoices, items, and payments. Local file system for logos and exported PDFs.  
**Testing**: `flutter_test`, `mocktail` (Unit, Widget, and Integration tests).  
**Target Platform**: Android, iOS, Linux, MacOS, Windows, Web (Flutter multi-platform).
**Project Type**: Mobile/Desktop Application feature.  
**Performance Goals**: Instant calculation updates (<100ms), PDF generation in <2s for 50 items.  
**Constraints**: 100% Offline-first, Material Design 3 compliance.  
**Scale/Scope**: ~10-15 new screens/dialogs, 4 new database tables, 1 new feature module.

**Unknowns (NEEDS CLARIFICATION)**:
- [NEEDS CLARIFICATION: Best Flutter PDF library for reliable multi-platform printing and pagination (evaluating `pdf` vs `syncfusion_flutter_pdf` vs others)?]
- [NEEDS CLARIFICATION: Strategy for handling image/logo storage in an offline-first SQLite-backed app (storing as BLOB or path to local file system)?]
- [NEEDS CLARIFICATION: Standardizing the "VAT Rate" management - global settings vs profile-specific vs item-specific overrides?]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Tech Stack Compliance**: Yes (Flutter, Dart, BLoC, SQLite).
- **Offline-First**: Yes (Local storage only).
- **Clean Architecture**: Yes (Feature-first structure: `lib/features/business_tools`).
- **Material Design 3**: Yes (UI will follow MD3 guidelines).
- **Migrations**: Required (New tables for `company_profiles`, `invoices`, `invoice_items`, `invoice_payments`).

**GATES PASSED**: Yes.

## Project Structure

### Documentation (this feature)

```text
specs/020-business-tools/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Research findings (Phase 0)
├── data-model.md        # Data entities and DB schema (Phase 1)
├── quickstart.md        # Implementation guide (Phase 1)
├── checklists/
│   └── requirements.md
└── tasks.md             # Task breakdown (Phase 2)
```

### Source Code (repository root)

```text
lib/
├── features/
│   └── business_tools/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── shared/
│   └── data/
│       └── local_database.dart (updated for migrations)
```

**Structure Decision**: Standard Feature-first Clean Architecture.

## Complexity Tracking

| Category | Risk | Mitigation |
|----------|------|------------|
| PDF Layout | High | Create reusable PDF component components; test with various item counts early. |
| Persistence | Medium | Use transaction-based writes for invoices and items to ensure atomic data integrity. |

## Constitution Check (Post-Design)

- **Tech Stack Compliance**: Yes.
- **Offline-First**: Yes.
- **Migrations**: 4 new tables added to migration plan.
- **Runtime Check**: Mandatory `flutter run` scheduled for final task.

**GATES PASSED**: Yes.
