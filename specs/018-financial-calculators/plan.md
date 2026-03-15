# Implementation Plan: Financial Calculators

**Branch**: `018-financial-calculators` | **Date**: 2026-03-13 | **Spec**: [specs/018-financial-calculators/spec.md](spec.md)
**Input**: Feature specification from `/specs/018-financial-calculators/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

This feature introduces a suite of financial tools including calculators for Net Worth, Loan Repayment/Amortization, and Savings with Compound Interest. It involves creating a central tools hub, individual calculator screens with real-time feedback, and a persistence layer for explicitly "saved" or "pinned" calculations.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `hydrated_bloc`, `sqflite`, `intl` (for currency formatting), `fl_chart` (for amortization charts)  
**Storage**: SQLite (for pinned calculations) and `hydrated_bloc` (for UI state/scratchpad)  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Android/iOS  
**Project Type**: Mobile App feature  
**Performance Goals**: UI rendering of 360-month amortization in < 300ms, real-time calculation updates.  
**Constraints**: Fully offline-capable, must respect global currency settings (from feature 016).  
**Scale/Scope**: ~1 hub screen, 3 calculator screens, 1 persistence entity.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Tech Stack: Uses Flutter/Bloc/SQLite as mandated.
- [x] Offline-First: All calculations and persistence occur locally.
- [x] Architecture: Follows Clean Architecture (Domain -> Data -> Presentation).
- [x] Migrations: Will require a new SQLite table for "SavedCalculations". Database version will bump to 9.

## Project Structure

### Documentation (this feature)

```text
specs/018-financial-calculators/
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
│   └── financial_tools/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       │       ├── calculate_net_worth.dart
│       │       ├── calculate_amortization.dart
│       │       └── calculate_compound_interest.dart
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           │   ├── tools_hub_page.dart
│           │   ├── net_worth_calculator_page.dart
│           │   ├── loan_calculator_page.dart
│           │   └── savings_calculator_page.dart
│           └── widgets/
```

**Structure Decision**: New feature module `financial_tools` following standard feature-first Clean Architecture.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
