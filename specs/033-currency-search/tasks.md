# Tasks: Currency Search

**Feature**: 033-currency-search | **Generated**: 2026-03-27

## Summary

Add searchable currency selector widget and update existing currency fields to use it.

**Total Tasks**: 9

**User Stories**:
- US1: Search Currency by Code (P1) - Filter by currency code
- US2: Search Currency by Name (P1) - Filter by currency name
- US3: Select Currency from Results (P1) - Choose and save

## Phase 1: Setup

- [ ] T001 Define shared currency list with code and name in lib/core/constants/app_constants.dart or create lib/shared/currencies.dart

## Phase 2: Foundational

- [ ] T002 [P] Create reusable CurrencySelector widget in lib/shared/widgets/currency_selector.dart

## Phase 3: User Story 1 - Search Currency by Code (P1)

**Independent Test**: Type "USD" in search box and verify USD appears in results

- [ ] T003 [US1] Implement search filtering by currency code in CurrencySelector
- [ ] T004 [US1] Make search case-insensitive for code matching

## Phase 4: User Story 2 - Search Currency by Name (P1)

**Independent Test**: Type "Dollar" and verify USD, CAD, AUD appear

- [ ] T005 [US2] Add currency name to searchable fields in CurrencySelector

## Phase 5: User Story 3 - Select Currency from Results (P1)

**Independent Test**: Search, select currency, verify it's saved

- [ ] T006 [US3] Implement currency selection and callback in CurrencySelector
- [ ] T007 [US3] Handle "No results" empty state

## Phase 6: Integration

- [ ] T008 Update account_form.dart to use CurrencySelector
- [ ] T009 Update duplication_dialog.dart to use CurrencySelector

## Phase 7: Polish

- [ ] T010 Run flutter analyze to verify no warnings

## Dependency Graph

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational) ──────┐
    │                         │
    ▼                         │
Phase 3 (US1) ───────────────┼──► All user stories can be tested
    │                         │    after Phase 3-5 complete
    ▼                         │
Phase 4 (US2) ───────────────┤
    │                         │
    ▼                         │
Phase 5 (US3) ───────────────┘
    │
    ▼
Phase 6 (Integration)
    │
    ▼
Phase 7 (Polish)
```

## Independent Test Criteria

| Story | Test Criteria |
|-------|--------------|
| US1 | Type "USD" → USD appears in results |
| US2 | Type "Dollar" → USD, CAD, AUD appear |
| US3 | Tap currency → selected, dialog closes |

## Implementation Strategy

**MVP Scope**: User Stories 1-3 (Phases 3-5)
- Complete currency selector widget with all search functionality

**Incremental Delivery**:
1. Create widget with code search (US1)
2. Add name search (US2)
3. Add selection (US3)
4. Integrate into forms (Phase 6)
