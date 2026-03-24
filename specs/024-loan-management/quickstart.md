# Quickstart: Loan Management

## Developer Setup

### 1. Database Migration
- Increment `AppConstants.databaseVersion` to `16`.
- Update `LocalDatabase._onUpgrade` to create the `loans` and `loan_payments` tables.

### 2. Add Navigation Entry
- Add "Loans" to the NavigationDrawerWidget.
- Route to `LoansPage` in `lib/features/loans/presentation/pages/`.

## Verification Steps

### 1. Create New Loan
- Navigate to **Loans**.
- Tap **FAB** (+) to add a new loan.
- Enter borrower name, amount, and date.
- Verify loan appears in list with status "Outstanding".

### 2. Record Partial Payment
- Tap on an outstanding loan.
- Tap **Add Payment**.
- Enter partial amount (less than remaining balance).
- Verify payment appears in history with running total.
- Verify loan status changes to "Partial".

### 3. Full Payment / Settlement
- On a loan with partial payments, add payment equal to remaining balance.
- Verify loan status changes to "Settled".
- Verify remaining balance is $0.00.

### 4. View Summary
- On Loans list, verify total outstanding amount displayed.
- Verify counts for Outstanding/Partial/Settled.

## Critical Flows

- `Add Loan` -> `View Loan` -> `Add Partial Payment` -> `View Updated Balance`
- `Add Loan` -> `Add Full Payment` -> `Auto-Settle`
- `View Summary` -> `Filter by Status`
