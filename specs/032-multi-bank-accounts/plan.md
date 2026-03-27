# Implementation Plan: Multiple Bank/Savings Accounts

**Branch**: `032-multi-bank-accounts` | **Date**: 2026-03-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/032-multi-bank-accounts/spec.md`

## Summary

Enable users to create, manage, and track multiple bank and savings accounts with transfer capabilities. Users can add accounts, view individual and total balances, edit/delete accounts, and transfer money between accounts. Data persists locally using SQLite.

## Technical Context

**Language/Version**: Dart 3.x  
**Primary Dependencies**: flutter_bloc, sqflite, equatable, path_provider  
**Storage**: SQLite (sqflite) - local database  
**Testing**: flutter_test, mocktail, bloc_test  
**Target Platform**: Android/iOS (Flutter mobile app)  
**Performance Goals**: 60fps UI, instant balance calculations (<100ms)  
**Constraints**: Offline-first, local storage only  
**Scale/Scope**: Single user, up to 50 accounts expected  

## Constitution Check

**GATE 1: Tech Stack Compliance** - PASS
- Flutter 3.x: Required by constitution
- flutter_bloc: Required by constitution
- sqflite: Required by constitution
- Clean Architecture: Required by constitution

**GATE 2: Offline-First** - PASS
- All data stored locally via SQLite
- No external APIs required
- Export/backup via local file system

**GATE 3: Database Migrations** - PASS
- Will include migration in LocalDatabase._onUpgrade
- Will increment AppConstants.databaseVersion

**GATE 4: License Compliance** - PASS
- All existing dependencies use MIT/Apache 2.0/BSD licenses

## Project Structure

### Documentation (this feature)

```
specs/032-multi-bank-accounts/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (if needed)
└── tasks.md            # Phase 2 output
```

### Source Code (repository root)

```
budget_app/
lib/
├── core/                           # Shared utilities
│   ├── database/                   # LocalDatabase class
│   └── constants/                 # AppConstants
├── features/
│   ├── accounts/                  # NEW - Bank accounts feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── budget/
│   ├── transactions/
│   └── [other existing features]
└── main.dart
```

**Structure Decision**: Feature-first Clean Architecture following existing patterns in `lib/features/`. New `accounts` feature will mirror the structure of existing features like `budget` and `loans`.

## Complexity Tracking

No violations - all gates pass.
