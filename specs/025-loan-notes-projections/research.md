# Research: Loan Notes & Projections Feature

## Decisions & Rationale

### 1. Database Schema Enhancement
- **Decision**: Add new columns to existing `loans` table via migration
- **Rationale**: Existing loans feature (024) already uses loans table. Add columns: `notes` (TEXT), `direction` (TEXT - 'lent'/'owed'), `include_in_projections` (INTEGER 0/1)
- **Migration**: Increment database version to 17

### 2. Projection Integration Approach
- **Decision**: Extend ProjectionBloc to query LoanRepository for enabled loans
- **Rationale**: Follows existing pattern - ProjectionBloc already aggregates from multiple data sources (Budget, EmergencyFund). LoanRepository provides getLoansWithProjectionsEnabled() method.

### 3. UI Structure - Lent/Owed Tabs
- **Decision**: Use DefaultTabController with two tabs on LoansPage
- **Rationale**: Matches existing InvoicesPage pattern (Outgoing/Received tabs). Consistent UX within the app.

### 4. Notes Field Implementation
- **Decision**: Simple TextFormField, up to 1000 characters
- **Rationale**: No need for rich text. Plain text is sufficient for loan notes.

## Best Practices Applied

1. **Database Migrations**: Add ALTER TABLE for new columns in _onUpgrade
2. **Clean Architecture**: Repository pattern isolates data access
3. **State Management**: Extend existing LoanBloc with new events
4. **Backward Compatibility**: Existing loans default to 'lent' direction, include_in_projections = 0

## Technology Stack Summary

| Component | Technology | Notes |
|-----------|------------|-------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State Management | flutter_bloc | ^8.x (existing) |
| Database | sqflite | ^2.x (existing) |
| Testing | flutter_test, mocktail | (existing) |
