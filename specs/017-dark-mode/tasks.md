# Tasks: Dark Mode Support

**Input**: Design documents from `/specs/017-dark-mode/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup

**Purpose**: Project initialization

- [X] T001 Verify existing directory structure for settings feature

## Phase 2: Foundational

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T002 Update `UserSettings` model in `lib/features/budget/data/models/user_settings.dart` to include `themeMode` string field with default "system"
- [X] T003 Update `SettingsEvent` and `SettingsState` in `lib/features/settings/presentation/bloc/settings_bloc.dart` to support theme mode changes
- [X] T004 Update `SettingsBloc` in `lib/features/settings/presentation/bloc/settings_bloc.dart` to handle `UpdateThemeEvent` and persist the value using `HydratedBloc`

**Checkpoint**: Foundation ready - data model and state management support theme persistence.

---

## Phase 3: User Story 1 & 3 - Manual Selection & Persistence (Priority: P1) 🎯 MVP

**Goal**: Allow users to manually change and persist their theme choice.

**Independent Test**: Change theme to "Dark" in settings, restart app, and verify it remains in Dark mode.

### Implementation for User Story 1 & 3

- [X] T005 [US1] Implement theme mode selection dropdown in `lib/features/settings/presentation/pages/settings_page.dart`
- [X] T006 [US1] Update `MaterialApp` in `lib/main.dart` to consume `SettingsBloc` state and set its `themeMode` property
- [X] T007 [P] [US1] Add `ThemeMode` helper logic to map string values ("light", "dark", "system") to Flutter's `ThemeMode` enum

**Checkpoint**: MVP functional - user can manually toggle and persist themes.

---

## Phase 4: User Story 2 - System Theme Synchronization (Priority: P2)

**Goal**: App follows OS theme settings automatically.

**Independent Test**: Set setting to "System Default", change OS theme, and verify app UI updates.

### Implementation for User Story 2

- [X] T008 [US2] Update `SettingsPage` dropdown to include the "System Default" option
- [X] T009 [US2] Ensure `SettingsBloc` initializes with "system" if no previous state is found (handled in foundational phase, but verified here)

**Checkpoint**: User Story 2 functional - app correctly synchronizes with OS theme settings.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Accessibility, chart consistency, and final verification.

- [X] T010 [P] Audit `lib/features/budget/presentation/widgets/projection_chart.dart` to ensure colors are distinguishable in Dark mode
- [X] T011 [P] Verify contrast ratios for primary and secondary text across all screens using Flutter's `Accessibility Guideline` tests or DevTools Color Contrast tool
- [X] T012 Perform final manual validation against `quickstart.md`, including verification of perceived transition latency (< 200ms) and system sync responsiveness (< 500ms)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Prerequisites for everything else.
- **Foundational (Phase 2)**: MUST complete before UI updates.
- **User Story 1 & 3 (Phase 3)**: Core MVP implementation.
- **User Story 2 (Phase 4)**: Extension of core functionality.

### Story Completion Order
1. **Foundation**: State exists and persists.
2. **User Story 1 & 3 (P1)**: User can manually change and persist themes.
3. **User Story 2 (P2)**: App follows system settings.

---

## Implementation Strategy

### MVP First (User Story 1 & 3)
1. Complete Foundational phase.
2. Implement Story 1 & 3 together since they both rely on persistence.
3. This provides immediate value and control to the user.

### Incremental Delivery
1. Foundation -> `UserSettings` updated and Bloc ready.
2. US1 & 3 -> Selection UI and persistence working.
3. US2 -> System default option added.
4. Polish -> Visual consistency and accessibility checks.
