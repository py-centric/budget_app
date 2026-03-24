# Contracts: Loan Management

## 1. LoanRepository Interface

### Loan Operations
```dart
Future<List<Loan>> getLoans();
Future<Loan?> getLoanById(String id);
Future<void> saveLoan(Loan loan);
Future<void> deleteLoan(String id);
Future<LoanSummary> getLoanSummary();
```

### Payment Operations
```dart
Future<List<LoanPayment>> getPaymentsForLoan(String loanId);
Future<void> savePayment(LoanPayment payment);
Future<void> deletePayment(String id);
```

## 2. LoanBloc Updates

### Events
- `LoadLoans`: Fetch all loans
- `AddLoan(Loan loan)`: Create new loan
- `UpdateLoan(Loan loan)`: Update existing loan
- `DeleteLoan(String id)`: Delete loan
- `AddPayment(LoanPayment payment)`: Record payment
- `LoadLoanSummary`: Fetch dashboard summary

### State
- `List<Loan> loans`: Current list of loans
- `LoanSummary? summary`: Dashboard summary data
- `bool isLoading`: Loading state
- `String? error`: Error message

## 3. UI Component Interface

### `LoansPage` Widget
- **Displays**: List of loans with status badges
- **Actions**: FAB to add loan, tap to view details

### `LoanDetailPage` Widget  
- **Displays**: Loan details, payment history, running total
- **Actions**: Add payment button, edit loan, delete loan

### `AddPaymentDialog` Widget
- **Input**: Payment amount
- **Output**: Saves payment, auto-calculates remaining balance
- **Logic**: If payment >= remaining balance, marks loan as settled
