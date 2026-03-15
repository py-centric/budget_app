# Feature Specification: Potential Transactions Tracking

**Feature Branch**: `012-potential-transactions`  
**Created**: 2026-03-13  
**Status**: Draft  
**Input**: User description: "new feature ability to track potential income along with gauranteed income, e.g. I might get money and I want to see how that would affect my projection, so allow for potential transactions, and then the user can either confirm them or delete them in which case they get removed from the potential projection, the graph must display the actual balance and potential balance, taking into account potential incomes and expenses"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Model Potential Scenarios (Priority: P1)

As a user, I want to record potential income or expenses without impacting my current actual balance, so that I can see how these hypothetical events would affect my future financial state.

**Why this priority**: Core value of the feature. Allows for "what-if" planning.

**Independent Test**: User can create a "Potential Income" of $500 for a future date. The current balance remains unchanged, but the projection for that future date shows a higher "potential balance" than the "actual balance".

**Acceptance Scenarios**:

1. **Given** I am adding a transaction, **When** I mark it as "Potential", **Then** it should not be included in my current actual balance calculation.
2. **Given** a potential transaction exists, **When** I view the projection graph, **Then** I should see a distinct line or area representing the balance inclusive of this potential item.

---

### User Story 2 - Confirm Potential Transactions (Priority: P1)

As a user, I want to convert a potential transaction into a real, guaranteed transaction once it is confirmed (e.g., the money arrives), so that my actual budget and history are updated correctly.

**Why this priority**: Essential workflow for transitioning from planning to execution.

**Independent Test**: User selects a potential transaction and clicks "Confirm". The transaction's status changes to "Actual", and it is now included in the actual balance calculation and the regular transaction list.

**Acceptance Scenarios**:

1. **Given** a potential transaction, **When** I choose to confirm it, **Then** it must be converted to a standard transaction and reflected in the actual balance.
2. **Given** a confirmed transaction, **When** I view the projection, **Then** the "actual" and "potential" lines should converge for that specific item's date.

---

### User Story 3 - Visualize Potential vs Actual Projections (Priority: P2)

As a user, I want to see a visual comparison of my financial future with and without potential transactions, so that I can make informed decisions based on guaranteed vs possible outcomes.

**Why this priority**: High UX value. Provides immediate visual understanding of financial risks/opportunities.

**Independent Test**: View the projection graph. Verify there are two distinct visualizations: one for the "Guaranteed" path and one for the "Potential" path.

**Acceptance Scenarios**:

1. **Given** active potential transactions, **When** I view the projection graph, **Then** both the "Guaranteed Balance" (actuals) and "Potential Balance" (actuals + potentials) must be displayed.
2. **Given** the projection table, **When** a day has potential transactions, **Then** it must show both the actual and potential end-of-day balances.

---

### Edge Cases

- **Deleting Potential Transactions**: When deleted, they must be removed entirely from both the transaction list and the potential projection path.
- **Overlapping Potential Items**: Multiple potential items on the same day must be aggregated correctly in the potential balance.
- **Past Potential Transactions**: If a potential transaction date passes without confirmation, it should be clearly marked as "Missed" or continue to show only in the potential path to alert the user.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to tag any transaction as "Potential".
- **FR-002**: System MUST exclude potential transactions from all "Actual Balance" and "Current Balance" calculations.
- **FR-003**: System MUST provide a projection calculation that includes both guaranteed and potential transactions.
- **FR-004**: The projection graph MUST display two distinct series: "Actual Balance" and "Potential Balance".
- **FR-005**: System MUST allow users to "Confirm" a potential transaction, changing its status to "Actual".
- **FR-006**: System MUST allow users to "Delete" a potential transaction.
- **FR-007**: The projection table MUST include a column or indicator for "Potential Balance" alongside the "Actual Balance".
- **FR-008**: System MUST allow users to toggle the visibility of the "Potential Balance" series on the projection graph.
- **FR-009**: System MUST identify potential transactions with past dates as "Missed" and exclude them from current actual balance until confirmed.

### Key Entities *(include if feature involves data)*

- **PotentialTransaction**:
    - Extends or shares structure with standard Transaction entries.
    - `isPotential`: Boolean flag.
    - `status`: Enum (Potential, Confirmed, Deleted/Cancelled).
- **ProjectionPoint**:
    - Updated to include `actualBalance` and `potentialBalance`.
    - `potentialInstances`: List of potential transaction summaries for that date.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: User can add a potential transaction in under 20 seconds.
- **SC-002**: 100% accuracy in the divergence between "Actual" and "Potential" projection lines.
- **SC-003**: Confirmation of a potential transaction updates the actual balance and graph within 500ms.
- **SC-004**: Users can toggle the visibility of the "Potential Balance" line on the graph.
