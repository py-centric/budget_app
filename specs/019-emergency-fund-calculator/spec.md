# Feature Specification: Emergency Fund Calculator

**Feature Branch**: `019-emergency-fund-calculator`  
**Created**: Sunday, 15 March 2026  
**Status**: Draft  
**Input**: User description: "new feature a screen where you can calculate how much of an emergency you actually need by taking into consideration things like insurance excess, car tyres, and other emergency/unforeseen expenses, give the user some suggestions, but also allow them to manually write the name of the entry, this nust be persisted across race starts"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Basic Emergency Fund Calculation (Priority: P1)

As a user, I want to see a list of common emergency expenses so that I can quickly estimate my safety net requirements without forgetting important categories.

**Why this priority**: Core functionality that provides immediate value by suggesting categories the user might overlook.

**Independent Test**: Can be fully tested by opening the emergency calculator screen and verifying that suggested items (insurance excess, car tyres) are present and can have amounts assigned to them.

**Acceptance Scenarios**:

1. **Given** the user is on the Emergency Fund Calculator screen, **When** they view the list, **Then** they see suggested categories like "Insurance Excess" and "Car Tyres".
2. **Given** a suggested category is displayed, **When** the user enters an amount for it, **Then** the total required fund is updated.

---

### User Story 2 - Custom Emergency Expenses (Priority: P1)

As a user, I want to add my own specific unforeseen expenses that aren't in the suggested list so that my emergency fund target is tailored to my unique life situation.

**Why this priority**: Essential for flexibility and accuracy of the financial plan.

**Independent Test**: Can be tested by adding a new entry with a custom name and amount, and verifying it is included in the total.

**Acceptance Scenarios**:

1. **Given** the user is on the calculator screen, **When** they add a new entry with a custom name "Pet Emergency" and amount 500, **Then** the item appears in the list and the total increases by 500.

---

### User Story 3 - Persistence Across Sessions (Priority: P1)

As a user, I want my emergency fund entries to be saved automatically so that I don't have to re-enter all my data every time I open the app.

**Why this priority**: Fundamental requirement for any planning tool to be useful over time.

**Independent Test**: Enter data, close the app, restart, and verify the data is still present.

**Acceptance Scenarios**:

1. **Given** the user has entered several expense items, **When** the app is closed and restarted, **Then** all previously entered items and amounts are displayed exactly as they were.

---

### User Story 4 - Managing Entries (Priority: P2)

As a user, I want to be able to edit or remove expenses as my situation changes so that my emergency fund target remains accurate over time.

**Why this priority**: Necessary for long-term maintenance of the plan.

**Independent Test**: Modify an existing amount and delete a custom entry, verifying the total updates correctly.

**Acceptance Scenarios**:

1. **Given** an existing custom entry, **When** the user deletes it, **Then** it is removed from the list and the total is recalculated.
2. **Given** an existing entry, **When** the user changes the amount, **Then** the new amount is saved and the total is updated.

### Edge Cases

- **Zero or Negative Values**: What happens when a user enters 0 or a negative number for an expense? (Requirement: System should treat 0 as valid but ignore negatives or reset to 0).
- **Extremely Large Numbers**: How does the UI handle very large currency values? (Requirement: Use auto-scaling font size for the total display and enable horizontal scrolling/ellipses for individual list items to prevent layout breakage).
- **Duplicate Custom Names**: What if a user adds two items with the same name? (Requirement: System should allow duplicates or append a number to ensure they are distinct).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a set of default suggested emergency expense categories (e.g., Car Tyres, Insurance Excess).
- **FR-002**: System MUST allow users to input and edit monetary amounts for any suggested or custom category.
- **FR-003**: System MUST allow users to add custom categories by providing a name and an amount.
- **FR-004**: System MUST calculate and display the grand total of all active emergency expenses.
- **FR-005**: System MUST persist all user-entered data locally so it remains available after app restarts.
- **FR-006**: System MUST allow users to delete custom categories they have created.
- **FR-007**: System MUST provide a way to reset or clear a suggested category's amount.
- FR-008: System MUST provide a "Living Expenses" calculator that allows users to either automatically calculate 3-12 months of expenses based on existing budget data or manually input an average monthly cost with a month-count selector (3, 6, 12 months). If less than 3 months of data exists, the system MUST use the average of all available complete months.
- FR-009: System MUST provide an "Insurance" section allowing users to dynamically add common insurance types (Car, Home, Health, etc.) with their respective excess amounts.
- FR-010: System MUST persist the calculated emergency fund total as a global target accessible by other features (e.g., Projections) while keeping the primary calculator UI within the "Financial Tools" section.

### Key Entities *(include if feature involves data)*

- **EmergencyExpense**: Represents a single line item in the calculator.
  - Attributes: `id`, `name`, `amount`, `is_suggestion` (boolean), `category_type` (optional).
- **EmergencyFundPlan**: The collection of all expenses and the calculated total.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can create a complete emergency fund plan with at least 5 items in under 60 seconds.
- **SC-002**: 100% of data entered by the user is successfully retrieved after a full application restart.
- **SC-003**: The total calculation is verified to be accurate to two decimal places for all entries.
- **SC-004**: Users report that the "suggestions" helped them identify at least one expense they wouldn't have thought of otherwise.
