# Tasks: Duplicate Budgets

**Input**: Design documents from `/specs/011-duplicate-budgets/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and core model updates

- [X] T001 Update `AppConstants.databaseVersion` to 6 in `budget_app/lib/core/constants/app_constants.dart`
- [X] T002 Update `LocalDatabase` schema in `budget_app/lib/features/budget/data/datasources/local_database.dart` to add `budgets` table and `budget_id` columns to entry tables
- [X] T003 Implement migration logic in `LocalDatabase._onUpgrade` to backfill existing data into default budgets
- [X] T004 Create `Budget` entity in `budget_app/lib/features/budget/domain/entities/budget.dart`
- [X] T005 Create `BudgetModel` in `budget_app/lib/features/budget/data/models/budget_model.dart`

---

## Phase 2: Foundational (Repository & BLoC Updates)

**Purpose**: Update existing infrastructure to support budget IDs

- [X] T006 Update `BudgetRepository` and its implementation in `budget_app/lib/features/budget/data/repositories/budget_repository_impl.dart` to support budget-based queries
- [X] T007 Update `NavigationState` in `budget_app/lib/features/budget/presentation/bloc/navigation_state.dart` to include `activeBudget`
- [X] T008 Update `NavigationBloc` in `budget_app/lib/features/budget/presentation/bloc/navigation_bloc.dart` to handle budget selection and default loading

**Checkpoint**: Foundation ready - application now operates on specific Budget IDs rather than implicit periods.

---

## Phase 3: User Story 1 - Duplicate to New Budget (Priority: P1) 🎯 MVP

**Goal**: Implement the core duplication logic and UI trigger.

**Independent Test**: Select a budget, trigger duplication to a new month, and verify a new budget record is created with identical structural data.

### Implementation for User Story 1

- [X] T009 [US1] Create `DuplicateBudget` use case in `budget_app/lib/features/budget/domain/usecases/duplicate_budget.dart`
- [X] T010 [US1] Implement "Duplicate Budget" dialog in `budget_app/lib/features/budget/presentation/widgets/duplication_dialog.dart`
- [X] T011 [US1] Add duplication trigger to `HomePage` or `BudgetSummary` actions
- [X] T012 [US1] Update `BudgetBloc` to handle duplication events and state refresh

**Checkpoint**: User Story 1 functional - basic duplication of budget structure is working.

---

## Phase 4: User Story 2 - Full Duplication by Default (Priority: P1)

**Goal**: Ensure individual transactions are copied and dated correctly in the new budget.

**Independent Test**: Duplicate a budget containing transactions and verify they appear in the target month with correct relative dates.

### Implementation for User Story 2

- [X] T013 [US2] Update `DuplicateBudget` use case to include transaction copying logic with date shifting
- [X] T014 [US2] Implement date shifting utility in `budget_app/lib/core/utils/date_utils.dart` to handle month-end clamping
- [X] T015 [US2] Ensure duplication scope (Full vs Structure) is respected in the UI and Use Case

**Checkpoint**: User Story 2 functional - complete budget mirrors can be created across periods.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: UI refinement and multi-budget navigation.

- [X] T016 Create `BudgetSelector` widget and update `NavigationDrawerWidget` to indicate and allow selection between multiple budgets within a single period.
- [X] T017 [P] Add unit tests for `DuplicateBudget` use case in `budget_app/test/unit/features/budget/domain/usecases/duplicate_budget_test.dart`
- [X] T018 [P] Add widget tests for `BudgetSelector` in `budget_app/test/widget/features/budget/presentation/widgets/budget_selector_test.dart`
- [X] T019 Perform final manual validation against `quickstart.md` success checklist, including verification of < 1.5s duplication time (SC-001).

---

## Dependencies & Execution Order

### Story Completion Order
1. **Foundation (Phases 1 & 2)**: Non-negotiable prerequisite.
2. **User Story 1 (US1)**: Core duplication infrastructure.
3. **User Story 2 (US2)**: Extension of duplication to transactional data.

### Parallel Opportunities
- T004, T005 (Model/Entity creation)
- T017, T018 (Testing tasks in Phase 5)

---

## Implementation Strategy

### MVP First (User Story 1)
1. Complete the database migration and NavigationBloc updates.
2. Deliver the ability to duplicate the *structure* of a budget.
3. This provides immediate value by allowing users to skip manual category setup.

### Incremental Delivery
1. Foundation -> Budget-centric architecture.
2. Story 1 -> Structural duplication.
3. Story 2 -> Full data replication.
4. Polish -> Multi-version navigation.
