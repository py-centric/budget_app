# Implementation Plan: Invoice Styling & Branding Enhancements

**Branch**: `021-invoice-styling-enhancements` | **Date**: 2026-03-15 | **Spec**: [specs/021-invoice-styling-enhancements/spec.md](specs/021-invoice-styling-enhancements/spec.md)
**Input**: Feature specification from `/specs/021-invoice-styling-enhancements/spec.md`

## Summary

The goal is to enhance the business invoicing feature by adding customizable branding (logo, colors, fonts), detailed banking information, and tax compliance via a VAT summary matrix. We will also improve the UX by ensuring the PDF preview opens immediately upon creation and by refining the creation form's layout.

## Technical Context

**Language/Version**: Dart 3.11+ / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `pdf`, `printing`, `path_provider`  
**Storage**: SQLite (via `sqflite`) for profiles and invoice data; Local file system for logo images.  
**Testing**: `flutter_test`, `bloc_test`, `mocktail`  
**Target Platform**: Android, iOS, Linux, MacOS, Windows  
**Project Type**: mobile-app  
**Performance Goals**: Instant transition to PDF preview (<1s)  
**Constraints**: Offline-capable (local storage only)  
**Scale/Scope**: ~10 screens (part of business tools feature)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack Compliance**: Uses Flutter/Dart + Bloc + SQLite. (PASS)
2. **Offline-First**: All data stored locally, no external APIs. (PASS)
3. **Local Storage**: Migrations required for `CompanyProfile` and `Invoice` tables. (PASS)
4. **UX & Accessibility**: Material Design 3 guidelines. (PASS)
5. **License Compliance**: `pdf` and `printing` packages use BSD-3-Clause/MIT. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/021-invoice-styling-enhancements/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
budget_app/
├── lib/
│   ├── features/
│   │   ├── business_tools/
│   │   │   ├── data/
│   │   │   │   ├── models/        # Updated DB models
│   │   │   │   └── repositories/  # Updated repository logic
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # Updated Invoice/CompanyProfile entities
│   │   │   │   └── usecases/      # PDF generation usecase
│   │   │   └── presentation/
│   │   │       ├── bloc/          # Updated BLoCs for creation/preview
│   │   │       ├── pages/         # Updated creation/preview pages
│   │   │       └── widgets/       # Spacing-improved form widgets
```

**Structure Decision**: Single project following feature-first Clean Architecture (standard for this repository).

## Complexity Tracking

*No violations identified.*
