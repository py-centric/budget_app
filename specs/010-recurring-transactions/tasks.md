# Tasks: Recurring Transactions

**Input**: Design documents from `/specs/010-recurring-transactions/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Update `LocalDatabase` in `budget_app/lib/features/budget/data/datasources/local_database.dart` to add `recurring_transactions` and `recurring_overrides` tables with foreign key constraints.
- [X] T002 [P] Create `RecurringTransaction` and `RecurringOverride` entities in `budget_app/lib/features/budget/domain/entities/`.
- [X] T003 [P] Create `RecurringTransactionModel` and `RecurringOverrideModel` in `budget_app/lib/features/budget/data/models/`.

---

## Phase 2: Foundational (Data Layer & Core Utilities)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T004 Implement `RecurringRepository` and its implementation in `budget_app/lib/features/budget/data/repositories/recurring_repository_impl.dart` for CRUD operations.
- [X] T005 Implement `RecurrenceCalculator` utility in `budget_app/lib/core/utils/recurrence_calculator.dart` to calculate occurrence dates based on interval and unit.
- [X] T006 [P] Add unit tests for `RecurrenceCalculator` in `budget_app/test/unit/core/utils/recurrence_calculator_test.dart`.

**Checkpoint**: Foundation ready - data access and recurrence logic are functional.

---

## Phase 3: User Story 1 - Create Recurring Transaction (Priority: P1) 🎯 MVP

**Goal**: Allow users to save transactions as recurring with flexible frequencies.

**Independent Test**: Create a transaction, toggle "Recurring", set frequency to "Every 2 Weeks", and verify it persists in the `recurring_transactions` table.

### Implementation for User Story 1

- [X] T007 [US1] Update `TransactionForm` (Income/Expense dialogs) in `budget_app/lib/features/budget/presentation/pages/home_page.dart` to include a "Recurring" toggle and frequency inputs (Interval/Unit).
- [X] T008 [US1] Create `SaveRecurringTransaction` use case in `budget_app/lib/features/budget/domain/usecases/save_recurring_transaction.dart`.
- [X] T009 [US1] Update `BudgetBloc` in `budget_app/lib/features/budget/presentation/budget_bloc.dart` to handle saving recurring templates.

**Checkpoint**: User Story 1 functional - recurring templates can be created.

---

## Phase 4: User Story 2 - Recurring Items in Projections (Priority: P1)

**Goal**: Automatically include recurring transactions in financial projections.

**Independent Test**: View the Projections page; verify that future balances include calculated recurring instances and that the table shows recurring item summaries.

### Implementation for User Story 2

- [X] T010 [US2] Update `CalculateProjection` use case in `budget_app/lib/features/budget/domain/usecases/calculate_projection.dart` to fetch and inject recurring instances into the daily calculation loop.
- [X] T011 [US2] Update `ProjectionPoint` model in `budget_app/lib/features/budget/domain/entities/projection_point.dart` to include a list of recurring instances active on that date.
- [X] T012 [US2] Update `ProjectionTable` in `budget_app/lib/features/budget/presentation/widgets/projection_table.dart` to display indicators/notes for days with recurring items.

**Checkpoint**: User Story 2 functional - projections accurately reflect recurring plans.

---

## Phase 5: User Story 3 - Manage Recurring Overrides (Priority: P2)

**Goal**: Allow users to modify or delete specific instances of a recurring transaction.

**Independent Test**: In the projection table, edit a recurring instance amount; verify a `RecurringOverride` is created and the projection updates only for that date.

### Implementation for User Story 3

- [X] T013 [US3] Implement "Edit Instance" dialog in `budget_app/lib/features/budget/presentation/widgets/recurring_instance_edit_dialog.dart` triggered from the projection table.
- [X] T014 [US3] Create `ApplyRecurringOverride` use case in `budget_app/lib/features/budget/domain/usecases/apply_recurring_override.dart` (to handle amount/date changes and instance cancellations).
- [X] T015 [US3] Update `CalculateProjection` to prioritize `RecurringOverride` data over template data for specific dates.

**Checkpoint**: User Story 3 functional - specific occurrences can be tailored without changing templates.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup and final verification.

- [X] T016 Create `ManageRecurringPage` in `budget_app/lib/features/budget/presentation/pages/manage_recurring_page.dart` to list, edit templates, and delete templates, including type filtering (SC-004).
- [X] T017 Add navigation link for "Recurring Transactions" in the `NavigationDrawerWidget`.
- [X] T018 [P] Add integration tests for the full recurring flow in `budget_app/test/integration/recurring_transactions_test.dart`.
- [X] T019 Perform final manual validation against `quickstart.md` success checklist.

---

## Dependencies & Execution Order

### Story Completion Order
1. **Foundation (Phase 2)**: Core data and calculator logic must exist.
2. **User Story 1 (US1)**: Required to have data to project.
3. **User Story 2 (US2)**: Core value proposition for projections.
4. **User Story 3 (US3)**: Advanced management features.

---

## Implementation Strategy

### MVP First (User Story 1 & 2)
1. Complete Setup and Foundational phases.
2. Implement Story 1 (Saving templates) and Story 2 (Basic projection integration).
3. This provides the most critical value: automated future balance forecasting.

### Incremental Delivery
1. Foundation -> Stable storage.
2. Story 1 -> Template creation.
3. Story 2 -> Visualization in projections.
4. Story 3 -> Fine-grained control (Overrides).
5. Polish -> Management UI.
