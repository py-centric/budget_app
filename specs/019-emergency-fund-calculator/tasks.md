# Tasks: Emergency Fund Calculator

**Input**: Design documents from `/specs/019-emergency-fund-calculator/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create feature directory structure in lib/features/emergency_fund/
- [x] T002 [P] Create data, domain, and presentation subdirectories in lib/features/emergency_fund/
- [x] T003 [P] Add necessary barrel files (index/exports) for the new feature directories

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T004 Implement database migration for `emergency_expenses` table in lib/shared/data/local_database.dart
- [x] T005 Increment `AppConstants.databaseVersion` in lib/core/constants/app_constants.dart (Constitution compliance)
- [x] T006 [P] Create EmergencyExpenseModel in lib/features/emergency_fund/data/models/emergency_expense_model.dart
- [x] T007 [P] Create EmergencyExpense entity in lib/features/emergency_fund/domain/entities/emergency_expense.dart
- [x] T008 Implement EmergencyFundRepository interface in lib/features/emergency_fund/domain/repositories/emergency_fund_repository.dart
- [x] T009 Implement EmergencyFundRepositoryImpl in lib/features/emergency_fund/data/repositories/emergency_fund_repository_impl.dart
- [x] T010 [P] Create initial EmergencyFundBloc in lib/features/emergency_fund/presentation/bloc/emergency_fund_bloc.dart
- [x] T011 [P] Define EmergencyFundEvent and EmergencyFundState in lib/features/emergency_fund/presentation/bloc/emergency_fund_event.dart and lib/features/emergency_fund/presentation/bloc/emergency_fund_state.dart

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Basic Emergency Fund Calculation (Priority: P1) 🎯 MVP

**Goal**: Suggest common emergency expenses and calculate the total.

**Independent Test**: Open the emergency calculator, see suggestions (Insurance, Tyres), enter amounts, and see the total update.

### Implementation for User Story 1

- [x] T012 [US1] Implement default suggestions logic in EmergencyFundRepository (Insurance, Car Tyres)
- [x] T013 [US1] Implement `LoadExpenses` event handler in EmergencyFundBloc to fetch suggestions
- [x] T014 [US1] Create basic EmergencyCalculatorScreen in lib/features/emergency_fund/presentation/pages/emergency_calculator_screen.dart
- [x] T015 [US1] Create ExpenseItemTile widget in lib/features/emergency_fund/presentation/widgets/expense_item_tile.dart
- [x] T016 [US1] Implement `UpdateExpenseAmount` event in EmergencyFundBloc to handle amount changes
- [x] T017 [US1] Display grand total of all expenses on the EmergencyCalculatorScreen

**Checkpoint**: User Story 1 (MVP) is functional.

---

## Phase 4: User Story 2 - Custom Emergency Expenses (Priority: P1)

**Goal**: Allow users to add and name their own emergency expenses.

**Independent Test**: Add a custom entry "Pet Emergency" with an amount and verify it appears in the list and the total.

### Implementation for User Story 2

- [x] T018 [US2] Implement `AddCustomExpense` method in EmergencyFundRepository
- [x] T019 [US2] Implement `AddCustomExpense` event handler in EmergencyFundBloc
- [x] T020 [US2] Add "Add Custom Expense" button and dialog to EmergencyCalculatorScreen
- [x] T021 [US2] Update the UI to distinguish between suggestions and custom entries (if needed)

---

## Phase 5: User Story 3 - Persistence Across Sessions (Priority: P1)

**Goal**: Ensure all data is saved to SQLite and loaded on app start.

**Independent Test**: Enter data, restart app, and verify all entries (suggestions and custom) are restored.

### Implementation for User Story 3

- [x] T022 [US3] Ensure all repository update/add/delete operations persist to the SQLite table
- [x] T023 [US3] Implement global target persistence (saving the total sum) in a preferences table or metadata
- [x] T024 [US3] Verify EmergencyFundBloc loads data from the repository on initialization

---

## Phase 6: User Story 4 - Managing Entries (Priority: P2)

**Goal**: Allow editing and deleting of expenses.

**Independent Test**: Delete a custom entry and verify it's removed and the total decreases.

### Implementation for User Story 4

- [x] T025 [US4] Implement `DeleteCustomExpense` method in EmergencyFundRepository
- [x] T026 [US4] Implement `DeleteCustomExpense` event handler in EmergencyFundBloc
- [x] T027 [US4] Add delete action (e.g., swipe to delete or trailing icon) to custom expense tiles in the UI
- [x] T028 [US4] Implement "Reset to Zero" for suggested items in the UI

---

## Phase 7: Living Expenses & Insurance (FR-008, FR-009)

**Goal**: Advanced calculation tools for living expenses and insurance.

### Implementation for Phase 7

- [x] T029 [US1] Implement `CalculateLivingExpensesUseCase` in lib/features/emergency_fund/domain/usecases/calculate_living_expenses_usecase.dart (3-month average)
- [x] T030 [US1] Create LivingExpensesCalculator widget with automatic/manual toggle in lib/features/emergency_fund/presentation/widgets/living_expenses_calculator.dart
- [x] T031 [US1] Implement dynamic "Insurance" section in the UI (FR-009) allowing multiple sub-items

---

## Phase 8: Global Target Integration (FR-010)

**Goal**: Expose the calculated total to the rest of the app.

### Implementation for Phase 8

- [x] T032 Implement a stream in EmergencyFundRepository that emits the total target
- [x] T033 Update other features (e.g., Projections) to consume the emergency fund target via the repository

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T034 [P] Add input validation for currency fields (preventing negatives, handling large numbers)
- [x] T035 [P] Apply Material Design 3 styling and animations to the calculator list
- [x] T036 [P] Add accessibility labels to all interactive elements
- [x] T037 Run quickstart.md validation to ensure all steps are covered
- [x] T038 Run `flutter run` to verify project compiles and executes correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 - BLOCKS all user stories.
- **User Stories (Phases 3-6)**: Depend on Phase 2 completion.
  - US1 (MVP) is the highest priority.
- **Advanced Features (Phase 7-8)**: Depend on basic calculator functionality.
- **Polish (Phase 9)**: Final step.

### Parallel Opportunities

- T002, T003 (Setup)
- T006, T007, T010, T011 (Foundation)
- Once Phase 2 is complete, US1, US2, US3, and US4 can be developed in parallel if needed, though sequential order is recommended for MVP.
- T034, T035, T036 (Polish)

---

## Implementation Strategy

### MVP First (User Story 1 & 3)

1. Complete Setup & Foundational work.
2. Implement basic suggestions and calculation (US1).
3. Ensure basic persistence (US3).
4. **STOP and VALIDATE**: Verify a basic emergency fund can be calculated and saved.

### Incremental Delivery

1. Add custom entries (US2).
2. Add deletion/management (US4).
3. Add Living Expenses calculator (Phase 7).
4. Integrate globally (Phase 8).
