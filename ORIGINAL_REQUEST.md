# Original User Request

## Initial Request — 2026-08-20T00:23:21Z

Execute comprehensive codebase remediation and constitutional alignment for the Budget App project across architecture, code quality, accessibility, test discipline, task runner infrastructure, and code-based documentation.

Working directory: /home/v/Projects/budget_app
Integrity mode: development

## Requirements

### R1. Zero Static Analysis Issues & Typography Enforcement
Resolve all 116 linter and static analysis issues reported by `flutter analyze` across `lib/` and `test/` (including deprecated color member accessors, missing flow control braces, unnecessary string interpolations, unused imports, and missing const declarations). Eliminate all em-dashes (`—`) and en-dashes (`–`) across the entire repository, substituting them with standard hyphens, colons, or parentheses in compliance with the Constitution.

### R2. Architectural Decomposition of LocalDatabase
Refactor the monolithic `lib/features/budget/data/datasources/local_database.dart` (1,950 lines) into modular, single-responsibility Data Access Objects (DAOs) and table delegates (such as `BudgetDao`, `TransactionDao`, `LoanDao`, `InvoiceDao`, `AccountDao`, `CategoryDao`) under `lib/core/database/` or domain features. Ensure no single database file exceeds 400 lines while preserving 100% database schema compatibility and migration integrity.

### R3. Accessibility & High Contrast Theme Support
Implement an explicit, WCAG 2.1 AA compliant High Contrast theme mode in `AppTheme` and settings, alongside existing Light, Dark, and OLED Dark themes. Verify interactive controls meet 48x48dp minimum touch bounding boxes and provide appropriate `Semantics` labels.

### R4. Canonical Task Runner Infrastructure (Taskfile.yml)
Create a cross-platform `Taskfile.yml` utilizing `go-task` with `mvdan/sh` that defines standardized commands: `task lint`, `task test`, `task test:coverage`, `task analyze`, `task dev`, and `task docs`.

### R5. Test Integrity & Regression Prevention
Ensure all 1,216+ existing automated tests pass without regressions across all refactored modules. Expand unit and widget tests where necessary to progress toward constitutional coverage targets (>=90% domain/service, >=80% UI).

### R6. Comprehensive Documentation & Code-Based Diagramming
Update Sphinx documentation configuration (`docs/conf.py`) to enable `sphinxcontrib.mermaid` and set copyright attribution to PyCentric. Embed inline Mermaid architecture diagrams illustrating the refactored DAO database layout, BLoC state orchestration, and entity relationships within Sphinx documentation. Ensure the documentation portal compiles cleanly.

## Acceptance Criteria

### Static Analysis & Linter Gates
- [ ] `flutter analyze` runs cleanly with 0 errors, 0 warnings, and 0 infos across the entire workspace.
- [ ] `grep -r "—" lib/ test/ docs/` and `grep -r "–" lib/ test/ docs/` return 0 matches.

### Architecture & Cohesion
- [ ] `LocalDatabase` is cleanly decomposed into domain-specific DAOs/delegates with zero circular dependencies.
- [ ] All 1,216+ unit and widget tests pass cleanly via `flutter test`.

### Accessibility & Theme System
- [ ] High Contrast theme is selectable in Settings and updates UI elements with accessible high-contrast color schemes.

### Tooling & Automation
- [ ] `Taskfile.yml` executes `task lint`, `task test`, `task analyze`, and `task docs` cleanly from the repository root.

### Documentation & Diagrams
- [ ] `docs/conf.py` includes `sphinxcontrib.mermaid` and attributes copyright to PyCentric.
- [ ] Architecture documentation includes Mermaid code-based diagrams representing the DAO database structure and state data flow.
- [ ] Sphinx documentation compiles to HTML without errors (`make html` or `task docs`).

## Verification Resources
- Test command: `flutter test` (in `budget_app/`)
- Analysis command: `flutter analyze` (in `budget_app/`)
- Docs build command: `sphinx-build -b html docs/ docs/_build/` (in `budget_app/`)
- Existing test suites: `budget_app/test/unit/`, `budget_app/test/widget/`, `budget_app/test/core/`
