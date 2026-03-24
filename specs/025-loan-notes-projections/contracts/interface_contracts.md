# Contracts: Loan Notes & Projections

## 1. LoanRepository Extensions

### New Methods
```dart
Future<List<Loan>> getLoansByDirection(LoanDirection direction);
Future<List<Loan>> getLoansWithProjectionsEnabled();
```

### Updated Save Method
```dart
Future<void> saveLoan(Loan loan); // Now accepts loan with notes, direction, includeInProjections
```

## 2. LoanBloc Updates

### New Events
- `UpdateLoanNotes(String loanId, String notes)`
- `UpdateLoanDirection(String loanId, LoanDirection direction)`
- `ToggleIncludeInProjections(String loanId)`

### State (unchanged)
- Existing LoanLoaded state includes all loan fields

## 3. ProjectionBloc Integration

### New Query
- Query LoanRepository.getLoansWithProjectionsEnabled() when calculating projections
- Lent loans: subtract from projected balance
- Owed loans: add to projected income

## 4. UI Component Interface

### LoansPage Updates
- **Input**: Current tab selection (lent/owed)
- **Output**: Filtered loan list based on direction

### AddLoanPage Updates
- **New**: Notes TextFormField
- **New**: Direction toggle (default: Lent)
- **New**: IncludeInProjections Switch

### LoanDetailPage Updates
- **New**: Notes display section
- **New**: IncludeInProjections toggle
