# Quickstart: Loan Notes & Projections

## Developer Setup

### 1. Database Migration
- Increment `AppConstants.databaseVersion` to `17`.
- Update `LocalDatabase._onUpgrade` to add new columns:
  - ALTER TABLE loans ADD COLUMN notes TEXT
  - ALTER TABLE loans ADD COLUMN direction TEXT DEFAULT 'lent'
  - ALTER TABLE loans ADD COLUMN include_in_projections INTEGER DEFAULT 0

### 2. Update Existing Code
- Add `notes`, `direction`, `includeInProjections` to Loan entity
- Update LoanModel with new field mappings
- Update LoanRepository with new query methods
- Update LoanBloc with new events

## Verification Steps

### 1. Notes Feature
- Create a loan with notes
- View loan details - notes should be visible
- Edit loan - notes should be editable

### 2. Lent/Owed Toggle
- Navigate to Loans page
- Switch between "Lent" and "Owed" tabs
- Create a loan marked as "Owed to Me"
- Verify it appears in the correct tab

### 3. Projections Integration
- Enable "Include in Projections" on a loan
- Navigate to Projections page
- Verify loan amount affects projection

## Critical Flows

- `LoansPage` -> Toggle Lent/Owed tabs -> Filter loans
- `AddLoanPage` -> Add notes, set direction, toggle projections
- `LoanDetailPage` -> Edit notes, toggle projections
- `ProjectionPage` -> See loan impact on balance
