# Tasks: Home List Totals and Potential Balances

**Input**: Design documents from `/specs/013-home-list-totals/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup

**Purpose**: Project initialization

- [X] T001 Verify project structure per implementation plan

## Phase 2: Foundational

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T002 Update `BudgetSummary` entity in `lib/features/budget/domain/usecases/calculate_summary.dart` to include `totalPotentialIncome` and `totalPotentialExpenses`
- [X] T003 Update `CalculateSummary` use case in `lib/features/budget/domain/usecases/calculate_summary.dart` to calculate actual and potential totals

**Checkpoint**: Foundation ready - domain layer provides required totals for both actual and potential scenarios.

---

## Phase 3: User Story 1 - Visible List Summaries (Priority: P1) 🎯 MVP

**Goal**: Display actual income and expense totals in headers.

**Independent Test**: Add an income item; verify the "Income" header shows the updated actual total.

### Implementation for User Story 1

- [X] T004 [US1] Create `ListHeaderTotal` widget in `lib/features/budget/presentation/widgets/list_header_total.dart`
- [X] T005 [US1] Update "Income" `ExpansionTile` header in `lib/features/budget/presentation/pages/home_page.dart` to use `ListHeaderTotal` for actual total
- [X] T006 [US1] Update "Expenses" `ExpansionTile` header in `lib/features/budget/presentation/pages/home_page.dart` to use `ListHeaderTotal` for actual total

**Checkpoint**: User Story 1 functional - actual totals are visible in list headers.

---

## Phase 4: User Story 2 - Potential Balance Visibility (Priority: P1)

**Goal**: Display potential totals alongside actuals when relevant.

**Independent Test**: Add a potential income item; verify the "Income" header shows both actual and potential totals.

### Implementation for User Story 2

- [X] T007 [US2] Update `ListHeaderTotal` in `lib/features/budget/presentation/widgets/list_header_total.dart` to show potential totals conditionally
- [X] T008 [US2] Add visual styling/coloring for potential totals in `lib/features/budget/presentation/widgets/list_header_total.dart` per research Dec-03

**Checkpoint**: User Story 2 functional - potential totals are visible and visually distinct.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup and final verification.

- [X] T009 [P] Verify UI responsiveness and layout on different screen sizes in `lib/features/budget/presentation/pages/home_page.dart`
- [X] T010 Perform final manual validation against `quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Prerequisites for everything else.
- **Foundational (Phase 2)**: Prerequisites for all user story implementation.
- **User Stories (Phase 3+)**:
  - US1 (Actual Totals) must be implemented first as it builds the UI structure.
  - US2 (Potential Totals) extends US1.

### Story Completion Order
1. **Foundation**: Entity and Use Case updates.
2. **User Story 1 (P1)**: Actual total visibility (MVP).
3. **User Story 2 (P1)**: Potential total visibility.

---

## Implementation Strategy

### MVP First (User Story 1)
1. Complete Foundational phase.
2. Implement Story 1 to show actual totals.
3. This provides immediate value by summarizing the lists without expansion.

### Incremental Delivery
1. Foundation -> Calculated totals available in `BudgetSummary`.
2. US1 -> Headers show actual totals.
3. US2 -> Headers show potential totals if items exist.
4. Polish -> UI refinements and final validation.
