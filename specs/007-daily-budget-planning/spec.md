# Feature Specification: Daily Budget Planning and Projections

**Feature Branch**: `007-daily-budget-planning`  
**Created**: 2026-03-12  
**Status**: Draft  
**Input**: User description: "new feature, we want to be able to plan the budget per day, so for example I might have income coming on the 2nd and the 15th and the 20th, and expenses on different days, the app should allow me to set the date for the income, if no date is provided it must just assume the start of the month, the app should also show a projection of finances, in tabular and graph from, with an option to view it on a daily basis or weekly basis"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Daily Income/Expense Entry (Priority: P1)

As a user, I want to assign specific dates to my income and expense entries so I can accurately plan my cash flow throughout the month.

**Why this priority**: This is the foundational capability. Without the ability to specify dates for all transaction types (including income), accurate daily projections are impossible.

**Independent Test**: Can be tested by creating an income entry with a specific date and verifying it is saved correctly.

**Acceptance Scenarios**:

1. **Given** I am adding a new income entry, **When** I select a specific day of the month, **Then** the income should be recorded for that specific date.
2. **Given** I am adding a new income entry, **When** I leave the date field empty, **Then** the system should automatically assign the entry to the 1st of the current/selected month.

---

### User Story 2 - Tabular Financial Projection (Priority: P1)

As a user, I want to see a table showing my projected balance for each day or week so I can see exactly when I might run out of money or have a surplus.

**Why this priority**: Provides the raw data needed for financial planning in a clear, readable format.

**Independent Test**: Can be tested by viewing the projection table and verifying that the running balance correctly accounts for incomes and expenses on their respective dates.

**Acceptance Scenarios**:

1. **Given** I have multiple incomes and expenses on different dates, **When** I view the projection table in "Daily" mode, **Then** I should see a row for every day with the projected balance at the end of that day.
2. **Given** the projection table, **When** I toggle to "Weekly" mode, **Then** the table should aggregate the data into weekly buckets showing the balance at the end of each week based on my preferred week start day.

---

### User Story 3 - Graphical Financial Projection (Priority: P2)

As a user, I want to see a visual chart of my projected balance over time so I can quickly identify trends and "danger zones" where my balance dips low.

**Why this priority**: Visual representation makes it easier to spot patterns and potential issues compared to reading a table of numbers.

**Independent Test**: Can be tested by opening the projection view and verifying a chart is rendered that reflects the same data as the tabular view.

**Acceptance Scenarios**:

1. **Given** the projection view, **When** I view the graph, **Then** I should be able to select between "Current Month", "Rolling 30 Days", and "Next 3 Months" as the projection horizon.
2. **Given** the graph is visible, **When** I toggle the "Show Actuals" setting, **Then** the projection should either show only future planned items or include all actual transactions from the past in the current period.
3. **Given** the graph is visible, **When** I switch between Daily and Weekly granularity, **Then** the graph's X-axis and data points should update to reflect the selected granularity.

---

### Edge Cases

- **Multiple entries on the same day**: The system should sum all incomes and subtract all expenses for that day to calculate the net change and final balance.
- **Negative Balance**: If projected expenses exceed projected income, the balance should be shown clearly (e.g., in red or as a negative number).
- **Date outside the current month**: If the user selects a date outside the current budget period, the system should handle it gracefully (either by restricting selection or updating the projection to include that date).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to select a specific date for any income entry.
- **FR-002**: System MUST default the income date to the 1st of the current month if no date is provided.
- **FR-003**: System MUST calculate a running balance for each interval (day/week) based on starting balance and dated entries.
- **FR-004**: System MUST provide a "Projection View" containing both a table and a graph.
- **FR-005**: System MUST allow users to toggle between "Daily" and "Weekly" views for the projection.
  - Weekly views MUST respect the user-defined `weekStartDay` setting (e.g., Monday vs Friday).
- **FR-006**: System MUST allow users to select the projection horizon: "Current Month", "Rolling 30 Days", or "Next 3 Months".
- **FR-007**: System MUST provide a toggle to switch between "Planned Items Only" and "Actual + Planned" for the projection.
  - *Definition*: "Actual" transactions are those with a date ≤ current system date. "Planned" transactions are those with a date > current system date.
- **FR-008**: System MUST allow users to define the starting day of the week for weekly groupings (e.g., Monday, Friday, etc.).

### Key Entities *(include if feature involves data)*

- **Transaction (Income/Expense)**: Now includes a mandatory `date` attribute (with a default for income).
- **Projection**: A calculated view representing a series of balance points over time.
- **User Settings**: Includes the preferred `weekStartDay` and default `projectionHorizon`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of income entries without a user-specified date are correctly assigned to the 1st of the month.
- **SC-002**: Projection calculation for a standard month (31 days) completes in under 200ms.
- **SC-003**: Tabular and Graphical views are synchronized and show identical balance data for any given date.
- **SC-004**: Users can switch between Daily and Weekly views in a single tap/click with zero noticeable lag (<100ms).
- **SC-005**: 100% accuracy in running balance calculations compared to manual ledger verification.
