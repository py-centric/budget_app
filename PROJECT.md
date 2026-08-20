# Project: Budget App Codebase Remediation & Constitutional Alignment

## Architecture
- **Workspace Root**: `/home/v/Projects/budget_app`
- **Application Directory**: `/home/v/Projects/budget_app/budget_app`
- **Core Architecture**: Clean Architecture (Presentation [BLoC + Material Design 3] -> Domain [Entities + Use Cases] -> Data [Repositories + DAOs + SQLite / HydratedBloc])
- **Database Architecture**: SQLite v28 orchestrated by `LocalDatabase` facade delegating to domain-specific Data Access Objects (DAOs) under `lib/core/database/daos/` with centralized `DatabaseSchema` (DDL) and `DatabaseMigrations` (v1 -> v28).
- **Task Runner**: `Taskfile.yml` using `go-task` with `mvdan/sh` supporting `task lint`, `task test`, `task test:coverage`, `task analyze`, `task dev`, `task docs`.
- **Documentation**: Sphinx with `myst_parser` and `sphinxcontrib.mermaid`, PyCentric copyright attribution, and inline Mermaid diagrams.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Canonical Task Runner (`Taskfile.yml`) | Standardized cross-platform Taskfile with lint, test, coverage, analyze, dev, docs | M1 | ORIGINAL_REQUEST §R4 |
| 2 | Sphinx Documentation & Mermaid Integration | Sphinx `docs/conf.py` update with `sphinxcontrib.mermaid` and PyCentric copyright | M1 | ORIGINAL_REQUEST §R6 |
| 3 | Mermaid Architecture Diagrams | Inline Mermaid diagrams for DAO layout, BLoC state orchestration, Schema v28 ER | M1 | ORIGINAL_REQUEST §R6 |
| 4 | Zero Static Analysis Issues | Resolve all 116 `flutter analyze` issues (consts, underscores, braces, deprecated members) | M2 | ORIGINAL_REQUEST §R1 |
| 5 | Typography Dash Normalization | Eliminate all em-dashes (`—`) and en-dashes (`–`) across repository | M2 | ORIGINAL_REQUEST §R1 |
| 6 | Database Schema & Migration Extraction | Extract DDL and 28 migration steps into dedicated files under 400 lines each | M3 | ORIGINAL_REQUEST §R2 |
| 7 | Modular DAO Decomposition | Decompose `LocalDatabase` into 15 focused DAOs (<400 lines each) and facade | M3 | ORIGINAL_REQUEST §R2 |
| 8 | High Contrast Theme Mode (WCAG 2.1 AA) | Implement high contrast theme with >=4.5:1 text and >=3:1 UI contrast tokens | M4 | ORIGINAL_REQUEST §R3 |
| 9 | High Contrast Settings & Persistence | Support 'high_contrast' in UserSettings, SettingsBloc, and SettingsPage | M4 | ORIGINAL_REQUEST §R3 |
| 10 | Touch Target & Semantics Remediation | Ensure 48x48dp minimum bounding boxes and Semantics accessibility labels | M4 | ORIGINAL_REQUEST §R3 |
| 11 | Test Suite Verification & Expansion | Verify 1,216+ existing tests pass with 0 regressions; add theme/DAO tests | M5 | ORIGINAL_REQUEST §R5 |
| 12 | Final Validation Gate | Comprehensive verification of all static analysis, test, task, and doc gates | M5 | ORIGINAL_REQUEST §Acceptance Criteria |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Task Runner & Documentation Infrastructure | `Taskfile.yml`, `docs/conf.py`, `docs/architecture.rst`, Mermaid diagrams | none | DONE |
| M2 | Static Analysis & Typography Remediation | Fix 116 `flutter analyze` issues and 8 em/en dash occurrences | none | DONE |
| M3 | Database DAO Decomposition & Schema Fix | Decompose `LocalDatabase` into DAOs (<400 lines), fix v28 table onCreate | none | DONE |
| M4 | Accessibility & High Contrast Theme | `AppTheme.highContrastTheme`, settings persistence, 48x48dp touch targets | M2 | DONE |
| M5 | Test Integrity, Expansion & Final Gate | Verify 1,216+ tests, add tests, execute task runner and docs builds | M1, M2, M3, M4 | DONE |

## Code Layout
- `Taskfile.yml` (workspace root)
- `budget_app/lib/core/database/`
  - `database_schema.dart` (<400 lines, centralized DDL for 35 tables)
  - `database_migrations.dart` (<400 lines, migrations v1 -> v28)
  - `daos/`
    - `budget_dao.dart`, `transaction_dao.dart`, `category_dao.dart`, `account_dao.dart`
    - `invoice_dao.dart`, `loan_dao.dart`, `savings_dao.dart`, `reminder_dao.dart`
    - `net_worth_dao.dart`, `credit_card_dao.dart`, `investment_dao.dart`, `tag_dao.dart`
    - `attachment_dao.dart`, `budget_template_dao.dart`, `emergency_fund_dao.dart`, `financial_tools_dao.dart`
- `budget_app/lib/features/budget/data/datasources/local_database.dart` (facade delegating to DAOs, <200 lines)
- `budget_app/lib/core/theme/app_theme.dart` (light, dark, OLED, and high contrast themes)
- `budget_app/docs/conf.py`, `budget_app/docs/architecture.rst` (Sphinx config & diagrams)

## Interface Contracts
### LocalDatabase Facade ↔ Feature Repositories
- `LocalDatabase` instance exposes:
  - `Future<Database> get database`
  - `static void setTestDatabase(Database db)`
  - `static void resetForTesting()`
  - Domain DAO properties: `budgetDao`, `transactionDao`, `categoryDao`, `accountDao`, `invoiceDao`, `loanDao`, `savingsDao`, `reminderDao`, `netWorthDao`, `creditCardDao`, `investmentDao`, `tagDao`, `attachmentDao`, `templateDao`, `emergencyFundDao`, `financialToolsDao`
  - Legacy convenience forwarding methods to avoid breaking existing callers.

### Theme & Settings ↔ UI Layer
- `UserSettings.themeMode`: `'system' | 'light' | 'dark' | 'oled' | 'high_contrast'`
- `AppTheme.highContrastTheme`: `ThemeData` with WCAG 2.1 AA compliant tokens.
