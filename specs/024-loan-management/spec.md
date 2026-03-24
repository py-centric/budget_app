# Feature Specification: Loan Management

**Feature Branch**: `024-loan-management`  
**Created**: 2026-03-24  
**Status**: Draft  
**Input**: User description: "create a page to manage loans sent out to friends and colleagues, this must provide the ability to add partial payments which must be tallied up, or a full payment, which then settles the account"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Record New Loan (Priority: P1)

As a user, I want to record money I've lent to a friend or colleague so that I can track who owes me money.

**Why this priority**: Core functionality - without this, nothing else matters.

**Independent Test**: Navigate to the Loans screen, click "Add Loan", fill in borrower name, amount, and date. Verify the loan appears in the list with "Outstanding" status.

**Acceptance Scenarios**:

1. **Given** I am on the Loans screen, **When** I click "Add Loan" and enter borrower name, amount, and date, **Then** the loan is saved and appears in the list.
2. **Given** I am adding a loan, **When** I enter a borrower name and amount, **Then** the system validates that the amount is positive.

---

### User Story 2 - Add Partial Payment (Priority: P1)

As a user, I want to record partial payments on a loan so that I can track progress toward full repayment.

**Why this priority**: Core requirement - users need to record partial payments that tally up.

**Independent Test**: Open an outstanding loan, add a partial payment (e.g., $50 of $200). Verify the remaining balance updates correctly and the loan status remains "Partial" until fully paid.

**Acceptance Scenarios**:

1. **Given** I have a loan for $200 outstanding, **When** I record a partial payment of $50, **Then** the remaining balance shows $150 and payment history shows $50 paid.
2. **Given** I have multiple partial payments totaling $200, **When** I record the final payment that equals the remaining balance, **Then** the loan status changes to "Settled".
3. **Given** I am viewing a loan with partial payments, **When** I look at the payment history, **Then** I see a running total of all payments made.

---

### User Story 3 - Full Payment / Settle Account (Priority: P1)

As a user, I want to record a full payment that settles the account so that the loan is marked as complete.

**Why this priority**: Core requirement - full payments should settle the account automatically.

**Independent Test**: Open an outstanding loan, record a payment equal to the remaining balance. Verify the loan status changes to "Settled" and no further payments are required.

**Acceptance Scenarios**:

1. **Given** I have a loan for $100 outstanding, **When** I record a payment of $100, **Then** the loan status changes to "Settled" and remaining balance shows $0.
2. **Given** I have a loan with partial payments making $50 remaining, **When** I record a payment of $50, **Then** the loan is marked "Settled".

---

### User Story 4 - View Loan Summary (Priority: P2)

As a user, I want to see a summary of all my outstanding loans so that I know my total outstanding balance.

**Why this priority**: Provides quick overview of money owed to user.

**Independent Test**: Open the Loans screen and verify the total outstanding amount is displayed at the top.

**Acceptance Scenarios**:

1. **Given** I have multiple loans, **When** I view the Loans screen, **Then** I see the total amount owed to me across all outstanding loans.
2. **Given** I have loans in different statuses (Outstanding, Partial, Settled), **When** I view the summary, **Then** I see breakdown by status.

---

### User Story 5 - Edit/Delete Loan (Priority: P3)

As a user, I want to edit or delete a loan so that I can correct mistakes or remove test data.

**Why this priority**: Data management capability for user control.

**Independent Test**: Long-press or swipe a loan to access edit/delete options. Verify changes persist.

**Acceptance Scenarios**:

1. **Given** I have a loan, **When** I edit the borrower name or amount, **Then** the changes are saved.
2. **Given** I have a loan, **When** I delete it, **Then** it is removed from the list (with confirmation dialog).

---

### Edge Cases

- **Zero Amount**: System should prevent saving a loan with zero or negative amount.
- **Duplicate Payments**: System should allow recording payments that exceed remaining balance (overpayment) and mark as settled.
- **No Loans**: Show empty state with prompt to add first loan.
- **Settled Loans**: Once settled, loan should remain visible but marked as complete (read-only or with option to reopen).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a "Loans" screen accessible from the app navigation.
- **FR-002**: System MUST allow users to create a new loan with borrower name, loan amount, and loan date.
- **FR-003**: System MUST display the list of all loans with their current status (Outstanding, Partial, Settled).
- **FR-004**: System MUST allow users to record partial payments on any outstanding loan.
- **FR-005**: System MUST automatically tally partial payments and display running total.
- **FR-006**: System MUST automatically mark loan as "Settled" when total payments equal or exceed the loan amount.
- **FR-007**: System MUST display total outstanding balance across all active loans.
- **FR-008**: System MUST allow users to edit loan details (borrower name, amount, date).
- **FR-009**: System MUST allow users to delete a loan with confirmation.
- **FR-010**: System MUST show payment history for each loan with dates and amounts.

### Key Entities

- **Loan**: Represents money lent to a person. Fields: ID, BorrowerName, LoanAmount, LoanDate, Status (Outstanding, Partial, Settled), RemainingBalance, CreatedAt, UpdatedAt.
- **LoanPayment**: Represents a payment made toward a loan. Fields: ID, LoanId, Amount, PaymentDate, CreatedAt.

## Success Criteria *(mandatable)*

### Measurable Outcomes

- **SC-001**: Users can create a new loan in under 30 seconds.
- **SC-002**: Partial payments are correctly tallied within 200ms of recording.
- **SC-003**: Full payment automatically marks loan as Settled (100% of the time).
- **SC-004**: Total outstanding balance is accurately calculated and displayed.
- **SC-005**: Payment history accurately shows all payments with running total.
