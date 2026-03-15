# Feature Specification: Home List Totals and Potential Balances

**Feature Branch**: `013-home-list-totals`  
**Created**: 2026-03-13  
**Status**: Draft  
**Input**: User description: "new feature on the home page, under the drop down for expenses and income, also include the totals there, and the potential balances"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visible List Summaries (Priority: P1)

As a user, I want to see the total amount of income and expenses directly in their respective section headers on the home page, so that I can understand my financial scale without having to expand every list.

**Why this priority**: High UX value. Reduces cognitive load and clicks required to see high-level numbers for the current period.

**Independent Test**: View the home page. The "Income" and "Expenses" dropdown headers should show the total amount of all actual items within that section.

**Acceptance Scenarios**:

1. **Given** I am on the home page, **When** I have $2000 in income, **Then** the "Income" header must display "$2,000.00" (or equivalent local currency).
2. **Given** I am on the home page, **When** I have $1500 in expenses, **Then** the "Expenses" header must display "$1,500.00".

---

### User Story 2 - Potential Balance Visibility (Priority: P1)

As a user, I want to see the "Potential Total" alongside the "Actual Total" in the list headers when I have potential transactions, so that I can see the impact of hypothetical items at a glance.

**Why this priority**: Essential for the value proposition of potential transactions. Users need to see the "what-if" totals in context.

**Independent Test**: Add a potential income item. Verify the "Income" header now shows both the actual total and the potential total (actual + potential).

**Acceptance Scenarios**:

1. **Given** $1000 actual income and $500 potential income, **When** I view the home page, **Then** the Income header must show both totals (e.g., "Actual: $1,000.00 | Potential: $1,500.00").
2. **Given** no potential items in a section, **When** I view the home page, **Then** only the actual total should be displayed to keep the UI clean.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST calculate the sum of all "Actual" income entries for the active budget/period.
- **FR-002**: System MUST calculate the sum of all "Potential" income entries for the active budget/period.
- **FR-003**: System MUST calculate the sum of all "Actual" expense entries for the active budget/period.
- **FR-004**: System MUST calculate the sum of all "Potential" expense entries for the active budget/period.
- **FR-005**: The "Income" list header MUST display the Actual Total.
- **FR-006**: The "Expenses" list header MUST display the Actual Total.
- **FR-007**: If potential entries exist in a section, the header MUST also display the Potential Total (sum of actual + potential).
- **FR-008**: Totals MUST update immediately when a transaction is added, edited, deleted, or confirmed.

### Key Entities *(include if feature involves data)*

- **BudgetSummary**: (Updated) Should now explicitly provide `totalPotentialIncome` and `totalPotentialExpenses` in addition to actuals.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Totals in headers are 100% accurate relative to the items in the list.
- **SC-002**: Header totals update within 300ms of any underlying data change.
- **SC-003**: UI layout remains clean and readable even when potential totals are displayed.
- **SC-004**: 100% consistency between header totals and the main Summary Card balance calculation.
