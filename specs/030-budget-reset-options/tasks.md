# Tasks: Budget Management Reset Options

**Feature**: Budget Management Reset Options  
**Branch**: `030-budget-reset-options`  
**Generated**: 2026-03-25

## Overview

| Metric | Value |
|--------|-------|
| Total Tasks | 17 |
| User Stories | 3 |
| Parallel Tasks | 4 |
| Estimated Duration | 2-4 hours |

## Task Phases

### Phase 1: Foundational

- [ ] T001 Add deleteBudget method to BudgetRepository in budget_app/budget_app/lib/features/budget/domain/repositories/budget_repository.dart
- [ ] T002 Add clearAllBudgets method to BudgetRepository in budget_app/budget_app/lib/features/budget/domain/repositories/budget_repository.dart
- [ ] T003 Add factoryReset method to BudgetRepository in budget_app/budget_app/lib/features/budget/domain/repositories/budget_repository.dart

### Phase 2: User Story 1 - Delete Budget from Home Page

**Story Goal**: Delete individual budgets from home page with confirmation  
**Independent Test**: Navigate to home page, tap delete, confirm, verify removal  
**Priority**: P1

- [ ] T004 [P] [US1] Implement deleteBudget in BudgetRepositoryImpl in budget_app/budget_app/lib/features/budget/data/repositories/budget_repository_impl.dart
- [ ] T005 [P] [US1] Add DeleteBudget event to BudgetEvent in budget_app/budget_app/lib/features/budget/presentation/budget_event.dart
- [ ] T006 [US1] Add DeleteBudget handler to BudgetBloc in budget_app/budget_app/lib/features/budget/presentation/budget_bloc.dart
- [ ] T007 [US1] Add delete option to budget card/menu in budget_app/budget_app/lib/features/budget/presentation/widgets/summary_card.dart or budget_selector.dart

### Phase 3: User Story 2 - Clear All Budgets from Sidebar

**Story Goal**: Clear all budgets from sidebar with confirmation  
**Independent Test**: Open sidebar, tap clear all, confirm, verify removal  
**Priority**: P1

- [ ] T008 [P] [US2] Implement clearAllBudgets in BudgetRepositoryImpl in budget_app/budget_app/lib/features/budget/data/repositories/budget_repository_impl.dart
- [ ] T009 [P] [US2] Add ClearAllBudgets event to BudgetEvent in budget_app/budget_app/lib/features/budget/presentation/budget_event.dart
- [ ] T010 [US2] Add ClearAllBudgets handler to BudgetBloc in budget_app/budget_app/lib/features/budget/presentation/budget_bloc.dart
- [ ] T011 [US2] Add "Clear All Budgets" menu item to NavigationDrawerWidget in budget_app/budget_app/lib/features/budget/presentation/widgets/navigation_drawer_widget.dart

### Phase 4: User Story 3 - Factory Reset from Settings

**Story Goal**: Factory reset from settings clears all data  
**Independent Test**: Navigate to Settings, tap factory reset, confirm, verify empty state  
**Priority**: P1

- [ ] T012 [P] [US3] Implement factoryReset in BudgetRepositoryImpl in budget_app/budget_app/lib/features/budget/data/repositories/budget_repository_impl.dart
- [ ] T013 [P] [US3] Add FactoryReset event to BudgetEvent in budget_app/budget_app/lib/features/budget/presentation/budget_event.dart
- [ ] T014 [US3] Add FactoryReset handler to BudgetBloc in budget_app/budget_app/lib/features/budget/presentation/budget_bloc.dart

### Phase 5: User Story 3 (continued) - Settings UI

- [ ] T015 [US3] Add "Factory Reset" option to SettingsPage in budget_app/budget_app/lib/features/settings/presentation/pages/settings_page.dart

### Phase 6: Polish & Cross-Cutting

- [ ] T016 Add unit tests for delete/clear/factory reset methods in budget_app/budget_app/test/unit/features/budget/
- [ ] T017 Handle edge cases: empty state messages when no budgets exist for delete/clear actions in budget_app/budget_app/lib/features/budget/presentation/

## Dependency Graph

```
Phase 1 (Foundational)
    │
    ├──► Phase 2 (US1) ──────► Phase 6 (Polish)
    │
    ├──► Phase 3 (US2)
    │
    └──► Phase 4-5 (US3)
```

## Parallel Execution

| Task IDs | Reason |
|----------|--------|
| T001, T002, T003 | Different methods, can be defined in parallel |
| T004, T008, T012 | Different implementations, can be done in parallel |
| T005, T009, T013 | Different events, can be added in parallel |
| T007, T011, T015 | Different UI files, can be done in parallel |

## Independent Test Criteria

### User Story 1 - Delete Budget
- Navigate to home page
- Tap delete option on a budget item
- Confirm deletion in dialog
- Verify budget is removed from list

### User Story 2 - Clear All Budgets
- Open sidebar navigation
- Tap "Clear All Budgets"
- Confirm in warning dialog
- Verify all budgets are removed

### User Story 3 - Factory Reset
- Navigate to Settings
- Tap "Factory Reset"
- Type confirmation text when prompted
- Confirm the reset
- Verify app returns to initial/empty state

## Implementation Strategy

**MVP Scope**: User Story 1 (T001, T004-T007)
- Adds delete budget functionality to home page
- Provides immediate value for budget management

**Incremental Delivery**:
1. MVP: Delete budget (T001, T004-T007)
2. Add Clear All budgets (T002, T008-T011)
3. Add Factory Reset (T003, T012-T015)
4. Polish & tests (T016-T017)

## Notes

- Tests are RECOMMENDED for this feature to ensure destructive actions work correctly
- All destructive actions require confirmation dialogs per requirements (FR-002, FR-004, FR-007)
- Factory reset must clear: budgets, transactions, categories, and preferences (flutter_secure_storage)
- Edge cases to handle: empty budgets, last budget deletion, app lock reset
- T017 addresses edge case handling for empty state messages