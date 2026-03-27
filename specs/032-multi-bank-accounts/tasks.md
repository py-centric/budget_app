# Tasks: Multiple Bank/Savings Accounts

**Feature**: 032-multi-bank-accounts | **Generated**: 2026-03-27

## Summary

Enable users to manage multiple bank/savings accounts with CRUD operations and transfers.

**Total Tasks**: 33

**User Stories**:
- US1: Add New Bank Account (P1) - Core functionality
- US2: View Account Balances (P1) - Total balance display
- US3: Edit/Delete Accounts (P2) - Account management
- US4: Transfer Between Accounts (P3) - Move funds

## Phase 1: Setup

- [ ] T001 Examine existing database structure in lib/core/database/local_database.dart to understand migration patterns

## Phase 2: Foundational

- [ ] T002 Add accounts table to LocalDatabase._onCreate in lib/core/database/local_database.dart
- [ ] T003 Add transfers table to LocalDatabase._onCreate in lib/core/database/local_database.dart
- [ ] T004 Create database migration in LocalDatabase._onUpgrade (increment AppConstants.databaseVersion)

## Phase 3: User Story 1 - Add New Bank Account (P1)

**Independent Test**: Add a new account and verify it appears in the account list

- [ ] T005 [P] [US1] Create Account entity in lib/features/accounts/domain/entities/account.dart
- [ ] T006 [P] [US1] Create AccountType enum in lib/features/accounts/domain/entities/account.dart
- [ ] T007 [P] [US1] Create AccountModel in lib/features/accounts/data/models/account_model.dart
- [ ] T008 [US1] Create Account repository interface in lib/features/accounts/domain/repositories/account_repository.dart
- [ ] T009 [US1] Implement AccountRepositoryImpl in lib/features/accounts/data/repositories/account_repository_impl.dart
- [ ] T010 [US1] Create AccountBloc in lib/features/accounts/presentation/bloc/account_bloc.dart
- [ ] T011 [US1] Create AccountState in lib/features/accounts/presentation/bloc/account_state.dart
- [ ] T012 [US1] Create AccountEvent in lib/features/accounts/presentation/bloc/account_event.dart
- [ ] T013 [US1] Create AccountsPage in lib/features/accounts/presentation/pages/accounts_page.dart
- [ ] T014 [US1] Create AccountFormWidget in lib/features/accounts/presentation/widgets/account_form.dart
- [ ] T015 [US1] Add accounts route to navigation in main.dart

## Phase 4: User Story 2 - View Account Balances (P1)

**Independent Test**: View accounts list and verify total balance is displayed

- [ ] T016 [P] [US2] Add total balance calculation to AccountBloc
- [ ] T017 [US2] Display total balance card in AccountsPage

## Phase 5: User Story 3 - Edit/Delete Accounts (P2)

**Independent Test**: Edit account name and verify change; delete account and verify removal

- [ ] T018 [P] [US3] Add updateAccount method to AccountBloc
- [ ] T019 [US3] Add deleteAccount method to AccountBloc with confirmation
- [ ] T019b [US3] Handle account deletion with transfers: cascade delete transfers or show warning in lib/features/accounts/presentation/bloc/account_bloc.dart
- [ ] T020 [US3] Create edit form in AccountFormWidget (reusable for add/edit)
- [ ] T021 [US3] Add swipe-to-delete or delete button in AccountsPage

## Phase 6: User Story 4 - Transfer Between Accounts (P3)

**Independent Test**: Create transfer and verify both account balances update correctly

- [ ] T022 [P] [US4] Create Transfer entity in lib/features/accounts/domain/entities/transfer.dart
- [ ] T023 [P] [US4] Create TransferModel in lib/features/accounts/data/models/transfer_model.dart
- [ ] T024 [US4] Add transfer methods to AccountRepository
- [ ] T025 [US4] Add transfer events/states to AccountBloc
- [ ] T026 [US4] Create TransferFormWidget in lib/features/accounts/presentation/widgets/transfer_form.dart
- [ ] T027 [US4] Implement transfer logic that updates both account balances atomically
- [ ] T027b [US4] Add validation: prevent transfer exceeding source account balance in lib/features/accounts/presentation/bloc/account_bloc.dart

## Phase 7: Polish & Cross-Cutting

- [ ] T028 Run flutter analyze to ensure no warnings
- [ ] T029 Verify flutter test passes (if tests exist)
- [ ] T030 Run flutter build apk --debug to verify compilation
- [ ] T030b Run flutter run to verify app launches correctly on target device (constitution §9)
- [ ] T031 Update AGENTS.md with new feature context

## Dependency Graph

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational) ──────┐
    │                         │
    ▼                         │
Phase 3 (US1) ───────────────┼──► All user stories can be tested independently
    │                         │    after Phase 3 is complete
    ▼                         │
Phase 4 (US2) ───────────────┤
    │                         │
    ▼                         │
Phase 5 (US3) ───────────────┘
    │
    ▼
Phase 6 (US4)
    │
    ▼
Phase 7 (Polish)
```

## Parallel Execution Opportunities

- T005, T006, T007 can run in parallel (entity creation)
- T016, T022, T023 can run in parallel (Phase 4-6 setup)
- All phases after Phase 3 can execute independently per user story

## Independent Test Criteria

| Story | Test Criteria |
|-------|--------------|
| US1 | Add account → appears in list with correct name, type, balance |
| US2 | View accounts → total balance equals sum of all account balances |
| US3 | Edit account → changes persist; Delete account → removed from list |
| US4 | Transfer $50 from A to B → A decreases by $50, B increases by $50 |

## Implementation Strategy

**MVP Scope**: User Stories 1 & 2 (Phases 3-4)
- Users can add accounts and view balances
- This delivers immediate value

**Incremental Delivery**:
1. MVP (US1+US2): Core account management
2. US3: Account editing and deletion
3. US4: Fund transfers

All user stories after Phase 3 are independently testable and can be deployed separately.
