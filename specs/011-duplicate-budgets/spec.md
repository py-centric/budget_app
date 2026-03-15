# Feature Specification: Duplicate Budgets

**Feature Branch**: `011-duplicate-budgets`  
**Created**: 2026-03-12  
**Status**: Draft  
**Input**: User description: "I want to be able to duplicate budgets"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Duplicate to New Budget (Priority: P1)

As a user, I want to create a new budget entry for a specific month by duplicating an existing one so that I can maintain multiple versions or distinct plans within the same period without losing previous data.

**Why this priority**: Foundational value. This allows users to experiment with different scenarios (e.g., "Conservative Plan" vs "Aggressive Savings") or simply start a new month based on an old one.

**Independent Test**: Can be fully tested by selecting a source budget, duplicating it to either the same month or a different month, and verifying that a new, distinct budget entry is created.

**Acceptance Scenarios**:

1. **Given** I am initiating a duplication, **When** I choose a target month, **Then** the system should create a NEW distinct budget entry for that month rather than overwriting existing data.
2. **Given** multiple budgets exist for the same month, **When** I navigate to that month, **Then** I should be able to select which budget version I want to view/edit.

---

### User Story 2 - Full Duplication by Default (Priority: P1)

As a user, I want the duplication process to copy everything (categories, goals, and transactions) by default so that my starting point for a new plan is a complete mirror of the source.

**Why this priority**: Matches user expectations for a "duplicate" action. It provides the most comprehensive starting point for planning.

**Independent Test**: Perform a default duplication and verify that all categories, planned amounts, and individual transaction entries (with adjusted dates) are present in the new budget.

**Acceptance Scenarios**:

1. **Given** the duplication prompt, **When** I confirm, **Then** the system should copy all structural data AND all transaction entries by default.
2. **Given** a full duplication, **When** I view the new budget, **Then** all individual entries should be present with dates shifted to the target month.

---

### Edge Cases

- **Duplicate to past months**: System MUST allow duplicating to past periods for historical backfilling or record keeping.
- **Date overflow**: Duplicating a transaction from Jan 31st to February (should shift to Feb 28th/29th).
- **Naming conflicts**: If multiple budgets exist in a month, the system should provide a way to distinguish them (e.g., "March 2026 - Copy", "March 2026 - Version 2").

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a UI to select a source budget.
- **FR-002**: System MUST allow selecting any target budget period (past, present, or future).
- **FR-003**: System MUST create a NEW budget record for the target month even if data already exists, allowing multiple distinct budgets per month.
- **FR-004**: System MUST copy all categories, planned amounts, and transactions by default.
- **FR-005**: System MUST automatically shift transaction dates to the corresponding day-of-month in the target month.
- **FR-006**: System MUST adjust dates for month-end mismatch (e.g., 31st becomes 30th or 28th).
- **FR-007**: System MUST allow the user to provide a name or label for the new budget. If omitted, the system MUST default to "{Source Name} - Copy".

### Key Entities *(include if feature involves data)*

- **Budget**: Now includes a `name` or `label` and a reference to a `BudgetPeriod`.
- **Budget Entry**: Individual line items (categories/transactions) linked to a specific `Budget` ID.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Budget duplication (standard 50-entry budget) completes in under 1.5 seconds (allowing for multiple budget creation logic).
- **SC-002**: 100% accuracy in data preservation across all copied fields.
- **SC-003**: Users can successfully view and switch between multiple budgets within a single month view.
- **SC-004**: Zero data loss or corruption in the source budget during the copy operation.
