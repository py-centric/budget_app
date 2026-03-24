# Research: Loan Management Feature

## Decisions & Rationale

### 1. Database Schema Design
- **Decision**: Create new `loans` and `loan_payments` tables.
- **Rationale**: Follows the same pattern as ReceivedInvoices for consistency. Need separate tables because Loan has distinct business logic (automatic settlement on full payment) different from invoices.
- **Migration**: Increment database version to 16.

### 2. State Management
- **Decision**: Use flutter_bloc (same as existing features).
- **Rationale**: Consistent with the rest of the codebase. Provides clear event/state separation for loan CRUD and payment operations.

### 3. Payment Settlement Logic
- **Decision**: Automatic settlement when total payments >= remaining balance.
- **Rationale**: Matches user requirement "full payment, which then settles the account". The system automatically marks as "settled" without requiring manual status change.

### 4. UI Structure
- **Decision**: Single "Loans" screen with list and FAB for adding new loans.
- **Rationale**: Simple, focused interface. Loan detail page for viewing payments and adding new payments.

## Best Practices Applied

1. **Offline-First**: All operations local, no network calls
2. **Clean Architecture**: Separate domain (entities, use cases), data (repositories, datasources), presentation (BLoC, widgets)
3. **Data Integrity**: Use transactions for payment operations to ensure balance updates atomically
4. **Performance**: Lazy loading for payment history, dashboard calculations under 200ms

## Technology Stack Summary

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State Management | flutter_bloc | ^8.x |
| Database | sqflite | ^2.x |
| Testing | flutter_test, mocktail | latest |
