# Tasks: GitHub Actions CI/CD Pipeline

**Feature**: GitHub Actions CI/CD Pipeline  
**Branch**: `029-github-actions-ci`  
**Generated**: 2026-03-24

## Overview

| Metric | Value |
|--------|-------|
| Total Tasks | 8 |
| User Stories | 3 |
| Parallel Tasks | 2 |
| Estimated Duration | 30-60 minutes |

## Task Phases

### Phase 1: Setup

- [X] T001 Create `.github/workflows/` directory structure in budget_app/budget_app/

### Phase 2: Foundational

- [X] T002 [P] Create CI workflow template `ci.yml` in budget_app/budget_app/.github/workflows/
- [X] T003 [P] Create release workflow template `release.yml` in budget_app/budget_app/.github/workflows/

### Phase 3: User Story 1 - Automated Test Run on Main Branch

**Story Goal**: Tests run automatically on main branch push  
**Independent Test**: Push a commit to main and verify workflow triggers  
**Priority**: P1

- [X] T004 [P] [US1] Configure CI workflow triggers for main branch in budget_app/budget_app/.github/workflows/ci.yml
- [X] T005 [US1] Add Flutter test command (unit, widget, integration), configure pinned Flutter version, and add timeout (15 min) to CI workflow in budget_app/budget_app/.github/workflows/ci.yml

### Phase 4: User Story 2 - Automated APK Build on Release Branches

**Story Goal**: APK builds automatically on release branch push  
**Independent Test**: Create release branch and verify APK artifact is generated  
**Priority**: P1

- [X] T006 [P] [US2] Configure release workflow triggers for release/* branches in budget_app/budget_app/.github/workflows/release.yml
- [X] T007 [US2] Add Flutter build command (APK), artifact upload, and timeout (20 min) to release workflow in budget_app/budget_app/.github/workflows/release.yml

### Phase 5: User Story 3 - Consistent CI Environment

**Story Goal**: Use pinned Flutter version for reproducible builds  
**Independent Test**: Verify workflow uses specified Flutter version  
**Priority**: P2

*Note: This is handled within the CI and Release workflows - no additional tasks needed*

### Phase 6: Polish & Cross-Cutting

- [X] T008 [P] Add workflow badge documentation to budget_app/budget_app/README.md

## Dependency Graph

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational) ──────► Phase 3 (US1) ──────► Phase 6 (Polish)
    │                              │
    │                              │
    └──────────────────────────────┘
              │
              ▼
        Phase 4 (US2)
```

## Parallel Execution

| Task IDs | Reason |
|----------|--------|
| T002, T003 | Different workflow files, no dependencies |
| T004, T006 | Different workflows, can be created in parallel |
| T005, T007 | Sequential within each workflow |

## Independent Test Criteria

### User Story 1 - Automated Tests
- Push any commit to main branch
- Verify GitHub Actions workflow triggers
- Verify tests complete (success or failure reported)

### User Story 2 - APK Build
- Create release branch (e.g., release/v1.0.0)
- Verify GitHub Actions workflow triggers
- Verify APK artifact is available for download

### User Story 3 - Consistent Environment
- Check workflow logs
- Verify Flutter version matches specified version

## Implementation Strategy

**MVP Scope**: User Story 1 (T001-T005)
- Creates basic CI pipeline
- Tests run on main branch push
- Provides immediate value

**Incremental Delivery**:
1. MVP: CI workflow (T001-T005)
2. Add Release workflow (T006-T007)
3. Polish and documentation (T008)

## Notes

- Tests are NOT generated for this feature - the GitHub Actions workflows themselves serve as the verification mechanism
- Workflow files follow GitHub Actions best practices
- Flutter SDK version should be pinned to a stable release (e.g., 3.24.0)
- FR-005 (fail workflow on errors) is handled by default GitHub Actions behavior - non-zero exit codes from flutter test/build commands cause workflow to fail
- SC-003 (catch all failures) is covered by T005 which runs flutter test - any test failure causes workflow failure
