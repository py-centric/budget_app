# Feature Specification: Recurring Transactions

**Feature Branch**: `010-recurring-transactions`  
**Created**: 2026-03-12  
**Status**: Draft  
**Input**: User description: "new feature, I want to be able to set recurring income and expenses, such payday, debit orders, etc. these must also be highlighted in the projections, for example the table must include a note/summary of recurring transactions active on that day, the user must be able to specify the start and end date of the entry, as well as the frequency"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Recurring Transaction (Priority: P1)

As a user, I want to set up recurring income and expenses with flexible frequencies so that I can model complex payment cycles (e.g., every 2 weeks).

**Why this priority**: Core functionality that enables automated long-term budget planning.

**Independent Test**: User can create a bi-weekly recurring income (Interval: 2, Unit: Weeks) and verify it is saved correctly.

**Acceptance Scenarios**:

1. **Given** I am on the transaction entry screen, **When** I toggle the "Recurring" option and provide a flexible frequency (e.g., "Every 2 Weeks"), **Then** the transaction should be saved as a recurring template.
2. **Given** a recurring transaction is created, **When** I view my transaction list, **Then** it should be clearly marked as recurring with its specific frequency visible.

---

### User Story 2 - Recurring Items in Projections (Priority: P1)

As a user, I want my recurring transactions to be automatically included in my financial projections so that I can see my future balance accurately.

**Why this priority**: Essential for the value proposition of financial projections.

**Independent Test**: Create a recurring income of $1000 every 15th of the month. Verify that the projection graph shows a jump of $1000 on the 15th of future months.

**Acceptance Scenarios**:

1. **Given** I have active recurring transactions, **When** I view the Projections page, **Then** the balance calculation must include all recurring instances within the projection horizon.
2. **Given** the Projections table, **When** a recurring transaction occurs on a specific day, **Then** that row must include a summary or indicator of the recurring items active on that day.

---

### User Story 3 - Manage Recurring Overrides (Priority: P2)

As a user, I want to override a specific instance of a recurring transaction (e.g., a higher utility bill this month) without changing the overall template.

**Why this priority**: Real-world financial planning requires the ability to handle deviations from a standard plan.

**Independent Test**: Create a monthly recurring expense of $50. Edit the occurrence for next month to be $75. Verify the projection shows $50 for all months except next month ($75).

**Acceptance Scenarios**:

1. **Given** an upcoming occurrence of a recurring transaction, **When** I edit only that specific instance, **Then** the system should store an override for that date while leaving the main recurring template unchanged.
2. **Given** a recurring transaction with an override, **When** I view the projections, **Then** the override value should be used for the calculation instead of the template value.

---

### Edge Cases

- **Frequency on non-existent days**: If a monthly transaction is set for the 31st, it should occur on the last day of the month for shorter months.
- **Overlapping occurrences**: If multiple recurring items fall on the same day, the summary must aggregate them.
- **Deleting the template vs. instance**: Users should be prompted whether to delete "this instance only" or "the entire series" when managing recurring items.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to designate a transaction as "Recurring".
- **FR-002**: System MUST support fully flexible recurring frequencies by allowing users to specify an **Interval** (integer) and a **Unit** (Days, Weeks, Months, Years).
- **FR-003**: System MUST allow users to specify a Start Date for the recurrence.
- **FR-004**: System MUST allow an optional End Date for the recurrence.
- **FR-005**: Projections MUST calculate and display the impact of all active recurring transactions and their overrides.
- **FR-006**: The Projection Table MUST include a "Notes" or "Summary" column/indicator for days with recurring transactions.
- **FR-007**: System MUST allow users to override the amount or date of a specific instance of a recurring transaction.
- **FR-008**: System MUST provide a way to list and manage (edit/delete) recurring transaction templates.

### Key Entities *(include if feature involves data)*

- **RecurringTransaction**:
    - `id`: Unique identifier
    - `type`: Income or Expense
    - `amount`: Monetary value
    - `categoryId`: Reference to category
    - `description`: Text label
    - `startDate`: DateTime
    - `endDate`: DateTime (nullable)
    - `interval`: Integer (e.g., 1, 2, 3)
    - `unit`: Enum (Days, Weeks, Months, Years)
- **RecurringOverride**:
    - `id`: Unique identifier
    - `recurringTransactionId`: Reference to parent template
    - `targetDate`: The original date being overridden
    - `newAmount`: Updated monetary value (nullable)
    - `newDate`: Updated occurrence date (nullable)
    - `isDeleted`: Boolean (if this specific instance was cancelled)
- **ProjectionPoint**: Updated to include a list of recurring transaction descriptions/summaries for that point.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can set up a recurring transaction in under 30 seconds.
- **SC-002**: 100% accuracy in projection calculations involving recurring items and overrides.
- **SC-003**: Projection table renders summaries for recurring items within 200ms of loading.
- **SC-004**: Users can filter the recurring transaction list by type (Income/Expense).
