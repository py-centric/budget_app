# Tasks: Daily Budget Planning and Projections

**Input**: Design documents from `/specs/007-daily-budget-planning/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Add `fl_chart` dependency to `budget_app/pubspec.yaml`
- [X] T002 Run `flutter pub get` in `budget_app/`
- [X] T003 [P] Create directory structure for new feature in `budget_app/lib/features/budget/` (presentation/widgets, presentation/bloc)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T004 Update `LocalDatabase` in `budget_app/lib/features/budget/data/datasources/local_database.dart` to include `date` column in `income_entries` and add an index.
- [X] T005 Update `IncomeEntry` entity in `budget_app/lib/features/budget/domain/entities/income_entry.dart` and its mapper to support the `date` field.
- [X] T006 Update `BudgetRepository` and its implementation to support date-range queries.
- [X] T007 Create `ProjectionPoint` entity in `budget_app/lib/features/budget/domain/entities/projection_point.dart`.
- [X] T008 [P] Create `UserSettings` model for `weekStartDay` and `projectionHorizon` in `budget_app/lib/features/budget/data/models/user_settings.dart`.

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Daily Income/Expense Entry (Priority: P1) 🎯 MVP

**Goal**: Allow users to assign specific dates to income entries.

**Independent Test**: Add an income with a custom date; verify it persists in the database and defaults correctly if omitted.

### Implementation for User Story 1

- [X] T009 [US1] Update `IncomeForm` in `budget_app/lib/features/budget/presentation/widgets/income_form.dart` to include a DatePicker.
- [X] T010 [US1] Implement default date logic (1st of month) in `IncomeForm` or `AddIncome` use case.
- [X] T011 [US1] Update `AddIncome` use case in `budget_app/lib/features/budget/domain/usecases/add_income.dart` to pass the date to the repository.

**Checkpoint**: User Story 1 functional - daily transaction entry is now possible.

---

## Phase 4: User Story 2 - Tabular Financial Projection (Priority: P1)

**Goal**: Show a table with projected daily/weekly balances.

**Independent Test**: View the projection table; verify running balances match incomes/expenses on their dates.

### Implementation for User Story 2

- [X] T012 [US2] Implement `CalculateProjection` use case in `budget_app/lib/features/budget/domain/usecases/calculate_projection.dart` (including logic to filter/include actuals based on FR-007).
- [X] T013 [US2] Implement weekly bucketing logic in a utility class `budget_app/lib/core/utils/date_grouping_utils.dart`.
- [X] T014 [US2] Create `ProjectionBloc` in `budget_app/lib/features/budget/presentation/bloc/projection_bloc.dart`.
- [X] T015 [US2] Create `ProjectionTable` widget in `budget_app/lib/features/budget/presentation/widgets/projection_table.dart`.
- [X] T016 [US2] Create `ProjectionPage` in `budget_app/lib/features/budget/presentation/pages/projection_page.dart` (table only).

**Checkpoint**: User Story 2 functional - users can see their future balance in a table.

---

## Phase 5: User Story 3 - Graphical Financial Projection (Priority: P2)

**Goal**: Show a visual chart of the projected balance.

**Independent Test**: View the chart; verify it reflects the same data points as the table.

### Implementation for User Story 3

- [X] T017 [US3] Create `ProjectionChart` widget using `fl_chart` in `budget_app/lib/features/budget/presentation/widgets/projection_chart.dart`.
- [X] T018 [US3] Add "Daily/Weekly" toggle to `ProjectionPage`.
- [X] T019 [US3] Add "Projection Horizon" selector to `ProjectionPage`.
- [X] T020 [US3] Add "Show Actuals" toggle to `ProjectionPage`.
- [X] T021 [US3] Integrate `ProjectionChart` into `ProjectionPage`.

**Checkpoint**: All user stories complete - full daily planning and projection feature delivered.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T022 [P] Add unit tests for `CalculateProjection` use case in `budget_app/test/unit/features/budget/domain/usecases/calculate_projection_test.dart`.
- [X] T023 [P] Add widget tests for `ProjectionChart` in `budget_app/test/widget/features/budget/presentation/widgets/projection_chart_test.dart`.
- [X] T024 Perform final manual validation against `quickstart.md`.
- [X] T025 [P] Verify performance metrics: Benchmark projection calculation (SC-002) and view switching (SC-004).

---

## Implementation Strategy

### MVP First (User Story 1 & 2)

1. Complete Setup and Foundational phases.
2. Implement Story 1 (Dating income) and Story 2 (Tabular projection).
3. This provides the core value: accurate daily balance planning.

### Incremental Delivery

1. Foundation -> Core data support.
2. Story 1 -> Precise data entry.
3. Story 2 -> Data visibility (Table).
4. Story 3 -> Data visualization (Graph).
