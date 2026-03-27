# Feature Specification: Multiple Bank/Savings Accounts

**Feature Branch**: `032-multi-bank-accounts`  
**Created**: 2026-03-27  
**Status**: Draft  
**Input**: User description: "create an ability to have multiple bank/savings account"

## User Scenarios & Testing

### User Story 1 - Add New Bank Account (Priority: P1)

As a user, I want to add multiple bank or savings accounts so that I can track my money across different institutions.

**Why this priority**: This is the core functionality that enables the entire feature. Without adding accounts, nothing else works.

**Independent Test**: Can be tested by adding a new account and verifying it appears in the account list.

**Acceptance Scenarios**:

1. **Given** the user is on the accounts screen, **When** they tap "Add Account", **Then** they should see a form to enter account details
2. **Given** the user enters valid account details, **When** they save, **Then** the account should appear in their account list
3. **Given** the user has multiple accounts, **When** they view the accounts list, **Then** each account should display its name, type, and current balance

---

### User Story 2 - View Account Balances (Priority: P1)

As a user, I want to see all my account balances in one place so that I know my total financial position.

**Why this priority**: Users need to quickly see their total money across all accounts without navigating between them.

**Independent Test**: Can be tested by viewing the accounts list and verifying total balance is displayed.

**Acceptance Scenarios**:

1. **Given** the user has multiple accounts, **When** they view the accounts screen, **Then** they should see individual balances for each account
2. **Given** the user has multiple accounts, **When** they view the accounts screen, **Then** they should see a total balance across all accounts

---

### User Story 3 - Edit/Delete Accounts (Priority: P2)

As a user, I want to edit or delete my accounts so that I can keep my financial information accurate.

**Why this priority**: Users may need to correct mistakes or remove accounts that are no longer relevant.

**Independent Test**: Can be tested by editing an account name and verifying the change, or deleting an account and verifying it's removed.

**Acceptance Scenarios**:

1. **Given** an account exists, **When** the user selects edit, **Then** they should be able to modify account details
2. **Given** an account exists, **When** the user deletes it, **Then** it should be removed from the list with confirmation

---

### User Story 4 - Transfer Between Accounts (Priority: P3)

As a user, I want to transfer money between my accounts so that I can move funds as needed.

**Why this priority**: Users commonly move money between savings and checking accounts.

**Independent Test**: Can be tested by creating a transfer and verifying both account balances update correctly.

**Acceptance Scenarios**:

1. **Given** the user has multiple accounts with balances, **When** they create a transfer, **Then** the source account decreases and destination account increases by the transfer amount

---

### Edge Cases

- **Delete account with transfers**: Transfers are cascade deleted via foreign key constraint (ON DELETE CASCADE)
- **Zero-balance accounts**: Allowed - users may have accounts with $0 balance
- **Transfer exceeds balance**: System MUST prevent transfer and show error message

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow users to create new bank or savings accounts with a name and type
- **FR-002**: System MUST allow users to view a list of all their accounts with individual balances
- **FR-003**: System MUST display a total balance across all accounts
- **FR-004**: System MUST allow users to edit existing account details
- **FR-005**: System MUST allow users to delete accounts after confirmation
- **FR-006**: System MUST allow users to transfer money between accounts
- **FR-007**: System MUST persist all account data locally
- **FR-008**: System MUST validate that account names are not empty

### Key Entities

- **Account**: Represents a bank or savings account with a name, type (checking/savings/other), and current balance
- **AccountType**: Enum of account types (checking, savings, investment, other)
- **Transfer**: Represents a money transfer between two accounts with amount, date, and reference

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can add a new account in under 30 seconds
- **SC-002**: Users can view their total balance across all accounts instantly
- **SC-003**: Users can complete a transfer between accounts in under 1 minute
- **SC-004**: 100% of created accounts persist after app restart
