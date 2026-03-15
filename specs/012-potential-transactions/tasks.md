# Tasks: Potential Transactions Tracking

**Input**: Design documents from `/specs/012-potential-transactions/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and database migration

- [X] T001 Update `AppConstants.databaseVersion` to 8 in `lib/core/constants/app_constants.dart`
- [X] T002 Update `LocalDatabase` in `lib/features/budget/data/datasources/local_database.dart` to add `is_potential` column to `income_entries` and `expense_entries` tables (Update `_onCreate` and `_onUpgrade`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T003 [P] Update `IncomeEntry` entity in `lib/features/budget/domain/entities/income_entry.dart` with `isPotential` field and `fromMap`/`toMap` updates
- [X] T004 [P] Update `ExpenseEntry` entity in `lib/features/budget/domain/entities/expense_entry.dart` with `isPotential` field and `fromMap`/`toMap` updates
- [X] T005 Update `BudgetRepository` in `lib/features/budget/domain/repositories/budget_repository.dart` to include methods for fetching potential items and updating potential status
- [X] T006 Update `BudgetRepositoryImpl` in `lib/features/budget/data/repositories/budget_repository_impl.dart` to support new entity fields and database status updates

**Checkpoint**: Foundation ready - data access layer supports potential transactions

---

## Phase 3: User Story 1 - Model Potential Scenarios (Priority: P1) 🎯 MVP

**Goal**: Record potential income or expenses without impacting actual balance.

**Independent Test**: Create a potential transaction and verify it exists in DB with `is_potential = 1` but does not affect the main summary balance.

### Implementation for User Story 1

- [ ] T007 [P] [US1] Update `AddIncome` use case in `lib/features/budget/domain/usecases/add_income.dart` to handle `isPotential`
- [ ] T008 [P] [US1] Update `AddExpense` use case in `lib/features/budget/domain/usecases/add_expense.dart` to handle `isPotential`
- [X] T009 [US1] Update `IncomeForm` in `lib/features/budget/presentation/widgets/income_form.dart` to include a "Potential" switch
- [X] T010 [US1] Update `ExpenseForm` in `lib/features/budget/presentation/widgets/expense_form.dart` to include a "Potential" switch
- [X] T011 [US1] Update `BudgetBloc` in `lib/features/budget/presentation/budget_bloc.dart` and related events to support potential transactions

**Checkpoint**: User Story 1 functional - potential transactions can be saved as hypothetical items

---

## Phase 4: User Story 2 - Confirm Potential Transactions (Priority: P1) 🎯 MVP

**Goal**: Convert a potential transaction into a real transaction.

**Independent Test**: Select a potential transaction, "Confirm" it, and verify its `is_potential` flag flips to 0 and the actual balance updates.

### Implementation for User Story 2

- [X] T012 [US2] Create `ConfirmPotentialTransaction` use case in `lib/features/budget/domain/usecases/confirm_potential_transaction.dart`
- [X] T013 [US2] Update `BudgetBloc` in `lib/features/budget/presentation/budget_bloc.dart` to handle `ConfirmPotentialTransactionEvent` and refresh summary
- [X] T014 [US2] Add "Confirm" action to `SlidableTransactionItem` or a dedicated detail dialog

**Checkpoint**: User Story 2 functional - complete workflow from hypothesis to reality

---

## Phase 5: User Story 3 - Visualize Potential vs Actual Projections (Priority: P2)

**Goal**: Compare financial future with and without potential transactions via a dual-line graph.

**Independent Test**: View the projection chart; verify two lines are visible when potential transactions exist in the range.

### Implementation for User Story 3

- [ ] T015 [P] [US3] Update `ProjectionPoint` in `lib/features/budget/domain/entities/projection_point.dart` with `actualBalance` and `potentialBalance` fields
- [X] T016 [US3] Update `CalculateProjection` in `lib/features/budget/domain/usecases/calculate_projection.dart` to compute dual balance series
- [X] T017 [US3] Update `ProjectionChart` in `lib/features/budget/presentation/widgets/projection_chart.dart` to render two lines (solid for Actual, dashed for Potential) using `fl_chart`
- [X] T018 [US3] Implement visibility toggle for the "Potential Balance" series in the UI/Chart (SC-004)
- [X] T019 [US3] Update `ProjectionTable` in `lib/features/budget/presentation/widgets/projection_table.dart` to display potential end-of-day balances

**Checkpoint**: User Story 3 functional - visual projection correctly shows hypothetical impacts

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup and final verification.

- [X] T020 Add logic to highlight/alert for "Missed" potential transactions (past dates without confirmation) per FR-009
- [X] T021 [P] Add integration tests in `test/integration/potential_transactions_test.dart`
- [X] T022 Perform final manual validation against `quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Prerequisites for everything else.
- **Foundational (Phase 2)**: Prerequisites for all user story implementation.
- **User Stories (Phase 3+)**: 
  - US1 (Creation) must come before others.
  - US2 (Confirmation) should be prioritized as P1 after US1.
  - US3 (Visualization) follows as P2.

### Story Completion Order
1. **Foundation**: Database and Repository support.
2. **User Story 1 (P1)**: Ability to add hypothetical data.
3. **User Story 2 (P1)**: Ability to act on hypothetical data (Confirmation).
4. **User Story 3 (P2)**: Ability to see the impact (Visualization).

---

## Implementation Strategy

### MVP First (User Story 1 & 2)
1. Complete Setup and Foundational phases.
2. Implement Story 1 (Adding potential data).
3. Implement Story 2 (Confirming it).
4. This provides the core value of capturing and transitioning planned items.

### Incremental Delivery
1. Foundation -> Stable storage for potential items.
2. US1 -> Create hypotheses.
3. US2 -> Convert to reality.
4. US3 -> Visualize hypotheses and add visibility control.
5. Polish -> Handle missed/past items.
