# Tasks: Global Currency Selection

**Input**: Design documents from `/specs/016-currency-selection/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup

**Purpose**: Project initialization

- [X] T001 Create directory structure for settings feature: `lib/features/settings/presentation/bloc/` and `lib/features/settings/presentation/pages/`

## Phase 2: Foundational

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T002 Update `CurrencyFormatter` in `lib/core/utils/currency_formatter.dart` to support dynamic currency codes using `intl`
- [X] T003 Update `UserSettings` model in `lib/features/budget/data/models/user_settings.dart` to include `currencyCode` with `fromMap`/`toMap` support
- [X] T004 Create `SettingsState` and `SettingsEvent` in `lib/features/settings/presentation/bloc/settings_bloc.dart`
- [X] T005 Implement `SettingsBloc` (using `HydratedBloc`) in `lib/features/settings/presentation/bloc/settings_bloc.dart` to manage and persist `currencyCode`
- [X] T006 Register `SettingsBloc` at the root of the app in `lib/main.dart`

**Checkpoint**: Foundation ready - state management for currency selection is in place and persists.

---

## Phase 3: User Story 1 - Select Preferred Currency (Priority: P1) 🎯 MVP

**Goal**: Allow users to manually change and view their chosen currency.

**Independent Test**: Change currency in settings and verify the Home page summary card updates its symbol immediately.

### Implementation for User Story 1

- [X] T007 [US1] Create `SettingsPage` skeleton in `lib/features/settings/presentation/pages/settings_page.dart`
- [X] T008 [US1] Implement currency selection dropdown in `SettingsPage` with supported ISO 4217 codes
- [X] T009 [US1] Update `NavigationDrawerWidget` in `lib/features/budget/presentation/widgets/navigation_drawer_widget.dart` to include a navigation link to the Settings page
- [X] T010 [P] [US1] Update `SummaryCard` in `lib/features/budget/presentation/widgets/summary_card.dart` to respect the selected currency from `SettingsBloc`
- [X] T011 [P] [US1] Update `IncomeList` and `ExpenseList` items to use the dynamic `CurrencyFormatter`
- [X] T012 [P] [US1] Update `ListHeaderTotal` in `lib/features/budget/presentation/widgets/list_header_total.dart` to use the dynamic `CurrencyFormatter`
- [X] T013 [P] [US1] Update `ProjectionTable` in `lib/features/budget/presentation/widgets/projection_table.dart` to use the dynamic `CurrencyFormatter`
- [X] T014 [P] [US1] Update `ProjectionChart` in `lib/features/budget/presentation/widgets/projection_chart.dart` tooltips to use the dynamic `CurrencyFormatter`

**Checkpoint**: User Story 1 functional - manual currency selection is fully operational across the app.

---

## Phase 4: User Story 2 - Automated Locale Detection (Priority: P2)

**Goal**: Automatically set initial currency based on device settings.

**Independent Test**: Reset app data and verify the default currency matches the system locale (e.g., EUR for Germany).

### Implementation for User Story 2

- [X] T015 [US2] Implement locale detection logic in `SettingsBloc`'s initial state or first-run check using `PlatformDispatcher`
- [X] T016 [US2] Map detected locales to corresponding currency codes (ISO 4217) using a lookup map or `intl` utility

**Checkpoint**: User Story 2 functional - first-run experience is localized.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup and final verification.

- [X] T017 Verify UI responsiveness and potential overflow with longer currency symbols (e.g., "zł")
- [X] T018 [P] Add unit tests for `CurrencyFormatter` in `test/unit/core/utils/currency_formatter_test.dart`
- [X] T019 Perform final manual validation against `quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Prerequisites for everything else.
- **Foundational (Phase 2)**: MUST complete before UI updates.
- **User Story 1 (Phase 3)**: MVP implementation.
- **User Story 2 (Phase 4)**: Enhancement for onboarding.

### Story Completion Order
1. **Foundation**: State management and formatter.
2. **User Story 1 (P1)**: Manual selection and global UI updates (MVP).
3. **User Story 2 (P2)**: Automated detection.

---

## Implementation Strategy

### MVP First (User Story 1)
1. Complete Foundational phase.
2. Implement Story 1 to allow manual change.
3. This provides immediate global usability.

### Incremental Delivery
1. Foundation -> State exists and persists.
2. US1 -> User can change currency and see it everywhere.
3. US2 -> Onboarding becomes smarter.
4. Polish -> Test coverage and layout audits.
