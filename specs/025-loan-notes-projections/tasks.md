# Tasks: Loan Notes & Projections

**Feature Branch**: `025-loan-notes-projections`
**Spec**: [specs/025-loan-notes-projections/spec.md](specs/025-loan-notes-projections/spec.md)
**Implementation Plan**: [specs/025-loan-notes-projections/plan.md](specs/025-loan-notes-projections/plan.md)

## Summary
Enhance Loan Management with notes, lent/owed tracking, and financial projections integration.

## Phase 1: Setup (Database Migration)
Goal: Add new fields to existing database schema.

- [X] T001 Increment `AppConstants.databaseVersion` to `17` in `budget_app/lib/core/constants/app_constants.dart`
- [X] T002 Add migration to `LocalDatabase._onUpgrade` and `_onCreate` to add columns: notes, direction, include_in_projections in `budget_app/lib/features/budget/data/datasources/local_database.dart`

## Phase 2: Foundational (Entity & Model Updates)
Goal: Update entity and model with new fields.

- [X] T003 [P] Update `Loan` entity with new fields in `budget_app/lib/features/loans/domain/entities/loan.dart`
- [X] T004 [P] Update `LoanModel` toMap/fromMap with new fields in `budget_app/lib/features/loans/data/models/loan_model.dart`
- [X] T005 Add `getLoansByDirection` method to `LoanRepository` in `budget_app/lib/features/loans/domain/repositories/loan_repository.dart`
- [X] T006 Add `getLoansWithProjectionsEnabled` method to `LoanRepository` in `budget_app/lib/features/loans/domain/repositories/loan_repository.dart`
- [X] T007 Implement new repository methods in `LoanRepositoryImpl` in `budget_app/lib/features/loans/data/repositories/loan_repository_impl.dart`

## Phase 3: [US1] Add Notes to Loans (P1)
Goal: Allow users to add and view notes on loans.

- [X] T008 [US1] Update `AddLoanPage` to include notes field in `budget_app/lib/features/loans/presentation/pages/add_loan_page.dart`
- [X] T009 [US1] Update `LoanDetailPage` to display notes section in `budget_app/lib/features/loans/presentation/pages/loan_detail_page.dart`
- [X] T010 [US1] Handle empty notes display (placeholder "No notes added") in `budget_app/lib/features/loans/presentation/pages/loan_detail_page.dart`

**Story Goal**: Users can add notes when creating loan and view them on detail page.
**Independent Test**: Create loan with notes, verify saved and displayed correctly.

## Phase 4: [US2] Track Loans Made To Me (P1)
Goal: Add lent/owed toggle and separate summary totals.

- [X] T011 [US2] Refactor `LoansPage` to use `DefaultTabController` with "Lent" and "Owed" tabs in `budget_app/lib/features/loans/presentation/pages/loans_page.dart`
- [X] T012 [US2] Add direction toggle to `AddLoanPage` in `budget_app/lib/features/loans/presentation/pages/add_loan_page.dart`
- [X] T013 [US2] Update summary card to show separate totals for Lent and Owed in `budget_app/lib/features/loans/presentation/pages/loans_page.dart`
- [X] T014 [US2] Update `LoanBloc` to filter by direction in `budget_app/lib/features/loans/presentation/bloc/loan_bloc.dart`

**Story Goal**: Users can toggle between lent and owed loans, see separate totals.
**Independent Test**: Create loans in both directions, verify they appear in correct tab.

## Phase 5: [US3] Include in Financial Projections (P2)
Goal: Integrate loan data with financial projections.

- [X] T015 [US3] Add "Include in Projections" toggle to `AddLoanPage` in `budget_app/lib/features/loans/presentation/pages/add_loan_page.dart`
- [X] T016 [US3] Add "Include in Projections" toggle to `LoanDetailPage` in `budget_app/lib/features/loans/presentation/pages/loan_detail_page.dart`
- [ ] T017 [US3] Update `LoanBloc` with toggle event in `budget_app/lib/features/loans/presentation/bloc/loan_bloc.dart`
- [ ] T018 [US3] Update `ProjectionBloc` to query loans for projections in `budget_app/lib/features/budget/presentation/bloc/projection_bloc.dart`
- [ ] T019 [US3] Handle zero balance edge case (exclude from projections) in projection calculation

**Story Goal**: Enabled loans affect financial projections.
**Independent Test**: Enable projection on loan, verify impact on Projection page.

## Final Phase: Polish & Cross-Cutting Concerns
Goal: Ensure consistency and edge case handling.

- [ ] T020 Handle edge case: direction toggle on existing loans in edit mode
- [ ] T021 Ensure currency formatting consistent across all loan views
- [ ] T022 Run flutter analyze and flutter format

## Dependency Graph & Parallel Execution
- Phase 1 (T001-T002) -> Phase 2 (T003-T007)
- Phase 2 must complete before Phase 3-5
- T003, T004 [P] can run in parallel
- US1, US2, US3 have dependencies on Phase 2

## Implementation Strategy
Start with **Phase 1 & 2** to enable data structure. Deliver **US1** for notes. Implement **US2** for lent/owed. Finish with **US3** for projections.