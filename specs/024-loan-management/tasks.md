# Tasks: Loan Management

**Feature Branch**: `024-loan-management`
**Spec**: [specs/024-loan-management/spec.md](specs/024-loan-management/spec.md)
**Implementation Plan**: [specs/024-loan-management/plan.md](specs/024-loan-management/plan.md)

## Summary
Create a Loan Management feature to track money lent to friends and colleagues, with partial payment tracking that tallies up, and full payment that automatically settles the account.

## Phase 1: Setup (DB & Infrastructure)
Goal: Prepare database and navigation for the new features.

- [X] T001 Increment `AppConstants.databaseVersion` to `16` in `budget_app/lib/core/constants/app_constants.dart`
- [X] T002 Add `loans` and `loan_payments` table creation to `LocalDatabase._onUpgrade` and `_onCreate` in `budget_app/lib/features/budget/data/datasources/local_database.dart`
- [X] T003 Add "Loans" navigation entry to `NavigationDrawerWidget` in `budget_app/lib/features/budget/presentation/widgets/navigation_drawer_widget.dart`

## Phase 2: Foundational (Data Layer & Business Logic)
Goal: Implement the data models, repository extensions, and business logic.

- [X] T004 [P] Create `Loan` entity in `budget_app/lib/features/loans/domain/entities/loan.dart`
- [X] T005 [P] Create `LoanPayment` entity in `budget_app/lib/features/loans/domain/entities/loan_payment.dart`
- [X] T006 Create `LoanSummary` transient model in `budget_app/lib/features/loans/domain/entities/loan_summary.dart`
- [X] T007 [P] Create `LoanModel` with mapping logic in `budget_app/lib/features/loans/data/models/loan_model.dart`
- [X] T008 [P] Create `LoanPaymentModel` with mapping logic in `budget_app/lib/features/loans/data/models/loan_payment_model.dart`
- [X] T009 Create `LoanRepository` interface in `budget_app/lib/features/loans/domain/repositories/loan_repository.dart`
- [X] T010 Implement `LoanRepositoryImpl` in `budget_app/lib/features/loans/data/repositories/loan_repository_impl.dart`
- [ ] T011 [P] Add unit tests for `LoanRepository` in `budget_app/test/unit/features/loans/data/repositories/loan_repository_test.dart`

## Phase 3: [US1] Record New Loan (P1)
Goal: Allow users to create and view loans.

- [X] T012 [US1] Create `LoansPage` with list view in `budget_app/lib/features/loans/presentation/pages/loans_page.dart`
- [X] T013 [US1] Create `AddLoanDialog` or form for new loans in `budget_app/lib/features/loans/presentation/pages/add_loan_page.dart`
- [X] T014 [US1] Implement `LoanBloc` with load/add/update/delete events in `budget_app/lib/features/loans/presentation/bloc/loan_bloc.dart`
- [X] T015 [US1] Add FAB to navigate to add loan form in `LoansPage`

**Story Goal**: Users can create a loan and see it in the list.
**Independent Test**: Create a loan, verify it appears in the list with "Outstanding" status.

## Phase 4: [US2] Partial Payment Tracking (P1)
Goal: Record partial payments and show running total.

- [X] T016 [US2] Create `LoanDetailPage` showing loan details and payment history in `budget_app/lib/features/loans/presentation/pages/loan_detail_page.dart`
- [X] T017 [US2] Create `AddPaymentDialog` for recording payments in `budget_app/lib/features/loans/presentation/widgets/add_payment_dialog.dart`
- [X] T018 [US2] Implement payment settlement logic: when total payments >= remaining balance, auto-mark as settled in `LoanRepository`
- [X] T019 [US2] Display running total of payments on `LoanDetailPage`

**Story Goal**: Partial payments are recorded and tallied correctly.
**Independent Test**: Add partial payment, verify balance updates and payment appears in history.

## Phase 5: [US3] Full Payment / Settlement (P1)
Goal: Automatic settlement when full payment is recorded.

- [X] T020 [US3] Verify auto-settlement when payment >= remaining balance (covered by T018)
- [X] T021 [US3] Update loan status badge to "Settled" when fully paid

**Story Goal**: Full payments automatically settle the loan.
**Independent Test**: Add payment equal to remaining balance, verify status changes to Settled.

## Phase 6: [US4] View Loan Summary (P2)
Goal: Display total outstanding balance across all loans.

- [X] T022 [US4] Implement `CalculateLoanSummary` use case in `budget_app/lib/features/loans/domain/usecases/calculate_loan_summary.dart`
- [X] T023 [US4] Display summary card at top of `LoansPage` with total outstanding and counts by status

**Story Goal**: Users can see total money owed to them.
**Independent Test**: View Loans page, verify total outstanding amount is displayed.

## Phase 7: [US5] Edit/Delete Loan (P3)
Goal: Allow editing and deleting loans.

- [X] T024 [US5] Add edit functionality to `LoanDetailPage`
- [X] T025 [US5] Add delete with confirmation dialog

## Final Phase: Polish & Cross-Cutting Concerns
Goal: Ensure data integrity and UI consistency.

- [X] T026 Handle empty state (no loans) with prompt to add first loan
- [X] T027 Verify currency formatting consistent across the app
- [X] T028 Run flutter analyze and flutter format

## Dependency Graph & Parallel Execution
- Phase 1 (T001-T003) -> Phase 2 (Foundational logic)
- Phase 2 must complete before Phase 3 (US1)
- US1, US2, US3 share data layer (Phase 2) - can proceed in parallel after Phase 2
- T004, T005, T007, T008 [P] can be developed in parallel

## Implementation Strategy
Start with **Phase 1 & 2** to enable the new data structure. Deliver **US1** to establish basic loan tracking. Implement **US2 & US3** for payment functionality. Add **US4** for summary view. Finish with **US5** for edit/delete capabilities.
