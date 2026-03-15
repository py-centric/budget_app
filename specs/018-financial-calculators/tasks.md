# Tasks: Financial Calculators

**Input**: Design documents from `/specs/018-financial-calculators/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup

**Purpose**: Project initialization

- [X] T001 [P] Create directory structure for `lib/features/financial_tools/` (data, domain, presentation)

## Phase 2: Foundational

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T002 Update `AppConstants.databaseVersion` to 9 in `lib/core/constants/app_constants.dart`
- [X] T003 Update `LocalDatabase` in `lib/features/budget/data/datasources/local_database.dart` to add `saved_calculations` table in `_onCreate` and `_onUpgrade`
- [X] T004 [P] Create `SavedCalculation` entity in `lib/features/financial_tools/domain/entities/saved_calculation.dart`
- [X] T005 [P] Create `AmortizationPoint` domain entity in `lib/features/financial_tools/domain/entities/amortization_point.dart`
- [X] T006 Create `FinancialRepository` interface in `lib/features/financial_tools/domain/repositories/financial_repository.dart`
- [X] T007 Implement `FinancialRepositoryImpl` in `lib/features/financial_tools/data/repositories/financial_repository_impl.dart`

**Checkpoint**: Foundation ready - persistence and data access layer support saved calculations.

---

## Phase 3: User Story 1 - Net Worth Calculator (Priority: P1) 🎯 MVP

**Goal**: List assets and liabilities to calculate and save total net worth snapshots.

**Independent Test**: Navigate to Net Worth tool, enter values, verify total, and save snapshot. Verify snapshot persists after app restart.

### Implementation for User Story 1

- [X] T008 [US1] Create `CalculateNetWorth` use case in `lib/features/financial_tools/domain/usecases/calculate_net_worth.dart`
- [X] T009 [US1] Implement `FinancialBloc` in `lib/features/financial_tools/presentation/bloc/financial_bloc.dart` to manage Net Worth inputs and state
- [X] T010 [US1] Create `NetWorthCalculatorPage` in `lib/features/financial_tools/presentation/pages/net_worth_calculator_page.dart`
- [X] T011 [US1] Implement "Save Snapshot" functionality in `FinancialBloc` using `FinancialRepository`

**Checkpoint**: User Story 1 functional - Net Worth calculation and explicit saving is operational.

---

## Phase 4: User Story 2 - Loan Repayment & Amortization (Priority: P1) 🎯 MVP

**Goal**: Calculate monthly payments and view amortization schedules with charts.

**Independent Test**: Enter loan terms, verify monthly payment accuracy, and toggle the schedule view to see the breakdown.

### Implementation for User Story 2

- [X] T012 [US2] Create `CalculateAmortization` use case in `lib/features/financial_tools/domain/usecases/calculate_amortization.dart`
- [X] T027 [US2] Update `CalculateAmortization` to support simple interest model
- [X] T013 [US2] Update `FinancialBloc` to manage loan calculation inputs and state
- [X] T028 [US2] Update `FinancialBloc` and `LoanCalculatorPage` to include "Interest Type" toggle
- [X] T014 [US2] Create `LoanCalculatorPage` in `lib/features/financial_tools/presentation/pages/loan_calculator_page.dart`
- [X] T015 [US2] Implement `AmortizationChart` using `fl_chart` in `lib/features/financial_tools/presentation/widgets/amortization_chart.dart`
- [X] T016 [US2] Implement `AmortizationScheduleTable` in `lib/features/financial_tools/presentation/widgets/amortization_schedule_table.dart`
- [X] T017 [US2] Implement "Save Loan" functionality in `FinancialBloc` using `FinancialRepository` (FR-008)

**Checkpoint**: User Story 2 functional - cost of debt visualization and saving is operational.

---

## Phase 5: User Story 3 - Savings & Compound Interest (Priority: P2)

**Goal**: Project future savings value based on contributions and returns.

**Independent Test**: Enter savings plan, verify future value, and view the growth chart.

### Implementation for User Story 3

- [X] T018 [US3] Create `CalculateCompoundInterest` use case in `lib/features/financial_tools/domain/usecases/calculate_compound_interest.dart`
- [X] T019 [US3] Update `FinancialBloc` to manage savings calculation inputs and state
- [X] T020 [US3] Create `SavingsCalculatorPage` in `lib/features/financial_tools/presentation/pages/savings_calculator_page.dart`
- [X] T021 [US3] Implement `SavingsChart` using `fl_chart` in `lib/features/financial_tools/presentation/widgets/savings_chart.dart`
- [X] T022 [US3] Implement "Save Savings Plan" functionality in `FinancialBloc` using `FinancialRepository` (FR-008)

**Checkpoint**: User Story 3 functional - long-term savings projections and saving is operational.

---

## Phase 6: User Story 4 - Rate Converter & Interest Solver (Priority: P2)

**Goal**: Solve for missing interest rates and convert between models.

**Independent Test**: Enter principal, term, and monthly payment; verify the solved interest rate matches expected values.

### Implementation for User Story 4

- [X] T029 [US4] Create `InterestRateSolver` use case in `lib/features/financial_tools/domain/usecases/solve_interest_rate.dart`
- [X] T030 [US4] Create `RateConverter` use case in `lib/features/financial_tools/domain/usecases/convert_rate.dart`
- [X] T031 [US4] Create `RateConverterPage` in `lib/features/financial_tools/presentation/pages/rate_converter_page.dart`
- [X] T032 [US4] Update `ToolsHubPage` to include "Rate Converter / Solver" link

**Checkpoint**: User Story 4 functional - advanced interest rate analysis is operational.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Navigation, global consistency, and final verification.

- [X] T023 Create central `ToolsHubPage` in `lib/features/financial_tools/presentation/pages/tools_hub_page.dart`
- [X] T024 Update `NavigationDrawerWidget` in `lib/features/budget/presentation/widgets/navigation_drawer_widget.dart` to include "Financial Tools" link
- [X] T025 [US1, US2, US3] Implement "Saved Calculations" list screen in `lib/features/financial_tools/presentation/pages/saved_calculations_page.dart`
- [X] T026 Perform final manual validation against `quickstart.md`, including performance check for amortization rendering (SC-003)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Prerequisite for all implementation.
- **Foundational (Phase 2)**: Prerequisite for all user story data persistence.
- **User Stories (Phases 3-6)**: 
  - US1 and US2 are independent P1 priorities.
  - US3 and US4 are P2 priorities.
- **Polish (Final Phase)**: Integrates all stories into the main app navigation.

### Story Completion Order
1. **Foundation**: Database and Repository.
2. **User Story 1 (P1)**: Net Worth (MVP).
3. **User Story 2 (P1)**: Loans (MVP).
4. **User Story 3 (P2)**: Savings.
5. **User Story 4 (P2)**: Rate Conversion/Solving.
6. **Integration**: Hub and Navigation.

---

## Implementation Strategy

### MVP First (User Story 1 & 2)
1. Complete Setup and Foundational phases.
2. Implement US1 (Net Worth) to establish the calculator UI pattern.
3. Implement US2 (Loans) to introduce complex schedules and charts.
4. This delivers the most critical calculators.

### Incremental Delivery
1. Foundation -> Persistent storage for snapshots.
2. US1 -> Static Net Worth modeling.
3. US2 -> Dynamic Loan scheduling.
4. US3 -> Future value projections.
5. US4 -> Advanced rate analysis.
6. Polish -> Unified hub and drawer integration.
