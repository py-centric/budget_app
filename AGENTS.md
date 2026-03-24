# budget_app Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-24

## Active Technologies
- Dart 3.x (Flutter 3.x) + flutter_bloc, sqflite (reusing existing Invoice Dashboard dependencies) (024-loan-management)
- SQLite via sqflite package (offline-first, local only) (024-loan-management)
- Dart 3.x (Flutter 3.x) + flutter_bloc, sqflite (existing project dependencies) (025-loan-notes-projections)
- SQLite via sqflite (existing), add migration for new loan fields (025-loan-notes-projections)
- Dart 3.x (Flutter 3.x) + flutter_secure_storage (existing), local_auth (new - biometrics) (026-app-lock)
- flutter_secure_storage for PIN, existing settings storage for preferences (026-app-lock)
- Dart 3.x (Flutter 3.x) + csv (new), excel (new), pdf (existing), path_provider (existing), share_plus (new) (027-budget-export)
- Local file system (export to device storage) (027-budget-export)

- Dart 3.x (Flutter 3.x) + flutter_bloc, sqflite, flutter_secure_storage, fl_chart (for pie charts) (023-invoice-dashboard-and-payables)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Dart 3.x (Flutter 3.x)

## Code Style

Dart 3.x (Flutter 3.x): Follow standard conventions

## Recent Changes
- 027-budget-export: Added Dart 3.x (Flutter 3.x) + csv (new), excel (new), pdf (existing), path_provider (existing), share_plus (new)
- 026-app-lock: Added Dart 3.x (Flutter 3.x) + flutter_secure_storage (existing), local_auth (new - biometrics)
- 025-loan-notes-projections: Added Dart 3.x (Flutter 3.x) + flutter_bloc, sqflite (existing project dependencies)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
