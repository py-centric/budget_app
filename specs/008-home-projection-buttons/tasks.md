# Tasks: Home Page Projection and Enhanced Action Buttons

**Input**: Design documents from `/specs/008-home-projection-buttons/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Verify project dependencies and environment in `budget_app/pubspec.yaml`
- [X] T002 [P] Create initial widget files for new components in `budget_app/lib/features/budget/presentation/widgets/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure and critical bug fixes that MUST be complete before ANY user story can be implemented

- [X] T003 Audit and fix "Add Expense" submission logic in `budget_app/lib/features/budget/presentation/pages/home_page.dart`
- [X] T004 Ensure `ExpenseForm` in `budget_app/lib/features/budget/presentation/widgets/expense_form.dart` correctly triggers `AddExpenseEvent`
- [X] T005 [P] Create `HomeProjectionState` UI model in `budget_app/lib/features/budget/presentation/models/home_projection_state.dart`

**Checkpoint**: Foundation ready - "Add Expense" works and models are defined.

---

## Phase 3: User Story 2 - Direct Add Transaction Buttons (Priority: P1) 🎯 MVP

**Goal**: Implement direct-access "Add Income" and "Add Expense" buttons on the Home page.

**Independent Test**: Open the Home page; verify two large, prominent buttons for "Add Income" and "Add Expense" are visible below the summary. Tapping them should open the entry dialog.

### Implementation for User Story 2

- [X] T006 [US2] Implement side-by-side transaction buttons in `budget_app/lib/features/budget/presentation/pages/home_page.dart`
- [X] T007 [US2] Design buttons with high-contrast Material 3 colors (Green for Income, Red for Expense)
- [X] T008 [US2] Integrate buttons to open transaction entry dialogs
- [X] T009 [US2] Remove any previous FAB or menu-based transaction triggers

**Checkpoint**: User Story 2 functional - prominent, direct transaction entry is available.

---

## Phase 4: User Story 1 - Home Page Projection Overview (Priority: P1)

**Goal**: Show a swipeable mini-chart at the top of the Home page.

**Independent Test**: Open Home page; verify mini-chart is at the top. Swipe horizontally to see different horizons (Month, 7-day, 30-day).

### Implementation for User Story 1

- [X] T010 [P] [US1] Create `HomeProjectionOverview` widget with `PageView` in `budget_app/lib/features/budget/presentation/widgets/home_projection_overview.dart`
- [X] T011 [US1] Implement simplified `LineChart` using `fl_chart` in `budget_app/lib/features/budget/presentation/widgets/home_projection_overview.dart`
- [X] T012 [US1] Wire `HomeProjectionOverview` to existing `ProjectionBloc` in `budget_app/lib/features/budget/presentation/pages/home_page.dart`
- [X] T013 [US1] Implement navigation from `HomeProjectionOverview` to full projection page in `budget_app/lib/features/budget/presentation/widgets/home_projection_overview.dart`
- [X] T014 [US1] Adjust `HomePage` layout to place `HomeProjectionOverview` at the top of the content area in `budget_app/lib/features/budget/presentation/pages/home_page.dart`

**Checkpoint**: User Story 1 functional - financial trends are visible on the Home page.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and optimization.

- [X] T015 Verify responsive layout and scaling on different screen sizes
- [X] T017 [P] Add widget tests for `HomeProjectionOverview` in `budget_app/test/widget/features/budget/presentation/widgets/home_projection_overview_test.dart`
- [X] T018 Run final manual validation against `quickstart.md` success checklist


---

## Dependencies & Execution Order

### Story Completion Order
1. **Foundation (Phase 2)**: Fixes existing bugs and sets up models.
2. **User Story 2 (P1)**: Delivers improved transaction entry (high priority UX).
3. **User Story 1 (P1)**: Delivers financial trend awareness.

### Parallel Opportunities
- T006 (FAB implementation) and T010 (Mini-chart implementation) can be developed in parallel as they are independent widgets.
- T016 and T017 (Testing) can run in parallel.

---

## Implementation Strategy

### MVP First (User Story 2)
1. Complete Setup and Foundational fixes.
2. Implement the FAB Speed Dial (Story 2).
3. **STOP and VALIDATE**: Ensure "Add Expense" fix and new entry UI are 100% functional.

### Incremental Delivery
1. Foundation -> Stable baseline.
2. Story 2 -> Enhanced entry visibility.
3. Story 1 -> Immediate trend visibility.
4. Polish -> Multi-screen consistency.
