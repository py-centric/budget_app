# Feature Specification: Loan Notes & Projections

**Feature Branch**: `025-loan-notes-projections`  
**Created**: 2026-03-24  
**Status**: Draft  
**Input**: User description: "as a user I want to also be able to add notes to loans, I also want to be able to track loans made to me, and be able to optionally include these into the financial projections"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add Notes to Loans (Priority: P1)

As a user, I want to add notes to my loans so that I can remember important details about the loan agreement.

**Why this priority**: Core enhancement to existing loan feature - allows users to record additional context.

**Independent Test**: Create a loan, add a note (e.g., "Lent for car repair, repayment expected in 3 months"). Verify the note is saved and displayed on the loan detail page.

**Acceptance Scenarios**:

1. **Given** I am creating a new loan, **When** I enter text in a notes field, **Then** the note is saved with the loan.
2. **Given** I have an existing loan with a note, **When** I view the loan details, **Then** I can see the note displayed.
3. **Given** I have an existing loan, **When** I edit the loan, **Then** I can add or modify the note.

---

### User Story 2 - Track Loans Made To Me (Priority: P1)

As a user, I want to track money that others have lent to me so that I can manage my debts alongside money owed to me.

**Why this priority**: Complete the loan picture - users may also owe money to others.

**Independent Test**: Navigate to Loans, switch to "Money Owed to Me" tab (loans made to user). Create a loan representing money owed to another person. Verify it appears in the correct category.

**Acceptance Scenarios**:

1. **Given** I am on the Loans screen, **When** I toggle between "Lent by Me" and "Owed to Me", **Then** I see only loans in that category.
2. **Given** I am adding a loan, **When** I select "Owed to Me", **Then** the loan is marked as money I owe (negative impact on projections).
3. **Given** I have loans in both categories, **When** I view the summary, **Then** I see separate totals for money lent and money owed.

---

### User Story 3 - Include in Financial Projections (Priority: P2)

As a user, I want to optionally include my loans in financial projections so that I can see how outstanding loans affect my future financial position.

**Why this priority**: Integrates loan tracking with broader financial planning.

**Independent Test**: Enable "Include in Projections" for a loan. View the Projection page. Verify the loan balance affects the projected balance.

**Acceptance Scenarios**:

1. **Given** I have a loan marked as "Owed to Me", **When** I enable "Include in Projections", **Then** the amount is added to projected income.
2. **Given** I have a loan marked as "Lent by Me", **When** I enable "Include in Projections", **Then** the amount is subtracted from projected balance.
3. **Given** I have multiple loans, **When** I view projections, **Then** only loans with "Include in Projections" enabled affect the projection.

---

### Edge Cases

- **Empty Notes**: Display placeholder text "No notes added" rather than empty field.
- **Both Directions**: A loan can be either "Lent by Me" or "Owed to Me" - not both.
- **Projection Toggle**: Default to disabled for privacy; user must actively opt-in.
- **Zero Balance**: Loans with zero remaining balance should not affect projections even if enabled.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to add and edit notes on any loan.
- **FR-002**: System MUST display notes on the loan detail page.
- **FR-003**: System MUST provide a toggle or tabs to switch between "Lent by Me" (receivables) and "Owed to Me" (payables).
- **FR-004**: System MUST allow users to mark a loan as "Owed to Me" during creation or editing.
- **FR-005**: System MUST display separate summary totals for Lent and Owed categories.
- **FR-006**: System MUST provide an "Include in Projections" toggle on each loan.
- **FR-007**: When enabled, "Owed to Me" loans MUST increase projected income.
- **FR-008**: When enabled, "Lent by Me" loans MUST decrease projected balance.
- **FR-009**: System MUST persist the "Include in Projections" setting across sessions.

### Key Entities

- **Loan (Enhanced)**: Extends existing Loan entity. New fields: Notes (text), Direction (lent/owed), IncludeInProjections (boolean).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can add notes to a loan in under 10 seconds.
- **SC-002**: Switching between Lent/Owed views responds within 200ms.
- **SC-003**: Projections correctly reflect enabled loans (100% accuracy).
- **SC-004**: 100% of users can identify their net loan position (lent minus owed) within 3 seconds.

## Assumptions

- Default loan direction is "Lent by Me" (existing behavior preserved).
- Include in Projections defaults to disabled.
- Notes field accepts plain text up to 1000 characters.
