# Tasks: Fix and Complete Transaction Slide Actions

**Input**: Design documents from `/specs/006-fix-transaction-actions/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Widget and Unit tests are included to verify the fix for the hanging bug and the new edit dialog functionality.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 [P] Ensure `flutter_slidable` dependency is correctly configured in `budget_app/pubspec.yaml`
- [X] T002 [P] Create directory for new widget tests in `budget_app/test/widget/budget/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure and state updates that MUST be complete before ANY user story can be implemented

- [X] T003 Update `BudgetState` to include `EntryDeleted` and `EntryUpdated` states in `budget_app/lib/features/budget/presentation/budget_state.dart`
- [X] T004 [P] Update `BudgetEvent` to include `UpdateIncomeEvent` and `UpdateExpenseEvent` (if missing) in `budget_app/lib/features/budget/presentation/budget_event.dart`
- [X] T005 Update `BudgetBloc` to emit `EntryDeleted` instead of `BudgetInitial` in `_onDeleteEntry` handler in `budget_app/lib/features/budget/presentation/budget_bloc.dart`
- [X] T006 Update `BudgetBloc` to emit `EntryUpdated` after successful income/expense updates in `_onUpdateIncome` and `_onUpdateExpense` in `budget_app/lib/features/budget/presentation/budget_bloc.dart`

**Checkpoint**: Foundation ready - state management now supports explicit success signals for deletion and updates.

---

## Phase 3: User Story 2 - Delete Transaction via Slide (Priority: P1) 🎯 MVP

**Goal**: Fix the hanging bug and complete the delete functionality.

**Independent Test**: Perform a "Delete" action on a transaction; verify the item is removed, a SnackBar appears, and the app remains responsive without manual refresh.

### Tests for User Story 2

- [X] T007 [P] [US2] Create unit test for `BudgetBloc` deletion state transition in `budget_app/test/unit/budget/budget_bloc_test.dart`
- [X] T008 [P] [US2] Create widget test for `SlidableTransactionItem` delete trigger in `budget_app/test/widget/budget/slidable_transaction_item_test.dart`

### Implementation for User Story 2

- [X] T009 [US2] Update `HomePage` `BlocConsumer` listener to handle `EntryDeleted` by showing a SnackBar and adding `LoadSummaryEvent` in `budget_app/lib/features/budget/presentation/pages/home_page.dart`
- [X] T010 [US2] Ensure `SlidableTransactionItem` correctly passes the delete callback to `SlidableAction` in `budget_app/lib/features/budget/presentation/widgets/slidable_transaction_item.dart`
- [X] T011 [US2] Verify `IncomeList` and `ExpenseList` provide unique `ValueKey`s to `SlidableTransactionItem` in `budget_app/lib/features/budget/presentation/widgets/income_list.dart` and `expense_list.dart`

**Checkpoint**: User Story 2 (Critical Bug Fix) is now functional and testable.

---

## Phase 4: User Story 1 - Edit Transaction via Slide (Priority: P1)

**Goal**: Implement the edit popup as requested.

**Independent Test**: Perform an "Edit" action; verify a modal dialog opens with pre-filled data, and saving updates the list.

### Tests for User Story 1

- [X] T012 [P] [US1] Create widget test for `TransactionEditDialog` pre-filling and submission in `budget_app/test/widget/budget/transaction_edit_dialog_test.dart`

### Implementation for User Story 1

- [X] T013 [US1] Create `TransactionEditDialog` widget with a Form and pre-filled controllers in `budget_app/lib/features/budget/presentation/widgets/transaction_edit_dialog.dart`
- [X] T014 [US1] Update `HomePage` `onEdit` callbacks to show `TransactionEditDialog` instead of navigating to `EditEntryPage` in `budget_app/lib/features/budget/presentation/pages/home_page.dart`
- [X] T015 [US1] Update `HomePage` `BlocConsumer` listener to handle `EntryUpdated` by showing a SnackBar and adding `LoadSummaryEvent` in `budget_app/lib/features/budget/presentation/pages/home_page.dart`

**Checkpoint**: User Story 1 is functional, providing the requested popup edit experience.

---

## Phase 5: User Story 3 - Return to Home / Refresh (Priority: P2)

**Goal**: Ensure consistent navigation and view refresh.

**Independent Test**: Verify that after any deletion or edit, the user remains on (or is returned to) the Home Page with an updated summary.

### Implementation for User Story 3

- [X] T016 [US3] Add navigation pop logic in `HomePage` listener if `EntryDeleted` or `EntryUpdated` occurs while a dialog is open in `budget_app/lib/features/budget/presentation/pages/home_page.dart`
- [X] T017 [US3] Ensure `SummaryCard` is updated by verifying `LoadSummaryEvent` is always called after changes in `budget_app/lib/features/budget/presentation/pages/home_page.dart`

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup and final validation.

- [X] T018 [P] Remove the obsolete `EditEntryPage` in `budget_app/lib/features/budget/presentation/pages/edit_entry_page.dart`
- [X] T019 [P] Update `README.md` or `GEMINI.md` to reflect the completed slide actions feature.
- [X] T020 Run all tests and perform manual validation of the "hanging" fix and "popup edit" feature.
- [X] T021 [P] Verify performance targets: <1s for edit popup appearance (SC-002) and <500ms for UI refresh (SC-003).

---

## Dependencies & Execution Order

### Phase Dependencies

1. **Setup (Phase 1)** & **Foundational (Phase 2)**: MUST be completed first.
2. **User Story 2 (Delete Fix)**: Priority P1, depends on Phase 2.
3. **User Story 1 (Edit Popup)**: Priority P1, depends on Phase 2.
4. **User Story 3 (Navigation)**: Priority P2, depends on US1/US2.
5. **Polish (Phase 6)**: Final step.

### Parallel Opportunities

- T001, T002 (Setup)
- T004 (Foundational)
- T007, T008 (US2 Tests)
- T012 (US1 Test)
- T018, T019 (Polish)

---

## Implementation Strategy

### MVP First (User Story 2 Only)

The primary goal is to fix the hanging bug. Completing Phase 2 and Phase 3 delivers the critical fix.

### Incremental Delivery

1.  **Bug Fix**: Deliver `EntryDeleted` state and `HomePage` refresh logic.
2.  **Feature Completion**: Deliver `TransactionEditDialog` and popup logic.
3.  **Cleanup**: Remove dead code (`EditEntryPage`).
