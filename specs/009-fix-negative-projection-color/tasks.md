# Tasks: Show red color for negative balances in projection graphs

**Input**: Design documents from `/specs/009-fix-negative-projection-color/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and utility creation.

- [X] T001 [P] Create `ChartColorUtils` in `budget_app/lib/core/utils/chart_color_utils.dart` to calculate normalized gradient stops for zero-crossing in `fl_chart`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core model updates that MUST be complete before UI changes.

- [X] T002 Update `ProjectionPoint` in `budget_app/lib/features/budget/domain/entities/projection_point.dart` to include an `isNegative` boolean helper (no UI dependencies).

**Checkpoint**: Foundation ready - UI components can now consume the boolean logic.

---

## Phase 3: User Story 1 - Visual Warning for Negative Balance (Priority: P1) 🎯 MVP

**Goal**: Implement red/green color logic across all projection visualizations.

**Independent Test**: Create a projection that crosses zero; verify the table text turns red for negative balances, and both charts (Full and Mini) show a sharp transition to red for the negative line segments and area fills.

### Implementation for User Story 1

- [X] T003 [US1] Update `ProjectionTable` in `budget_app/lib/features/budget/presentation/widgets/projection_table.dart` to apply conditional styling (red for `isNegative`).
- [X] T004 [US1] Update `ProjectionChart` in `budget_app/lib/features/budget/presentation/widgets/projection_chart.dart` to use `LineChartBarData.gradient` for the line and both `aboveBarData`/`belowBarData` with `cutOffY: 0` for area fills.
- [X] T005 [US1] Update `HomeProjectionOverview` in `budget_app/lib/features/budget/presentation/widgets/home_projection_overview.dart` to apply consistent gradient and `aboveBarData`/`belowBarData` logic.

**Checkpoint**: User Story 1 functional - visual alerts for negative balances are visible across the app.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Validation and automated testing.

- [X] T006 [P] Add widget tests for projection chart color transition in `budget_app/test/widget/features/budget/presentation/widgets/projection_chart_color_test.dart`.
- [X] T007 [P] Add widget tests for projection table color logic in `budget_app/test/widget/features/budget/presentation/widgets/projection_table_color_test.dart`.
- [X] T008 Perform final manual validation against the `quickstart.md` success checklist.

---

## Dependencies & Execution Order

### Story Completion Order
1. **Foundation (Phase 2)**: Standardizes the color logic in the domain layer.
2. **User Story 1 (Phase 3)**: Implements the visual changes in the presentation layer.

### Parallel Opportunities
- T001 (Utility creation) can be done in parallel with any other task before T004/T005.
- T006 and T007 (Testing) can be done in parallel.

---

## Implementation Strategy

### MVP First (User Story 1)
1. Complete Setup and Foundational phases.
2. Implement the color changes in the Table and Charts (Story 1).
3. This delivers the core value of immediate visual risk identification.

### Incremental Delivery
1. Foundation -> Unified color business rules.
2. Story 1 -> Visual implementation across all charts.
3. Polish -> Automated verification.
