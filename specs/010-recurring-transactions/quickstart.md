# Quickstart: Recurring Transactions

## Implementation Order

### 1. Data Layer
- Add `recurring_transactions` and `recurring_overrides` tables to SQLite schema.
- Create `RecurringRepository` to handle CRUD for both new tables.
- Update `BudgetRepository` if needed to expose recurring data.

### 2. Domain Layer
- Implement `RecurrenceCalculator` utility to generate occurrence dates for a given timeframe.
- Update `CalculateProjection` use case to fetch active recurring templates and apply overrides during the projection loop.

### 3. Presentation Layer
- Update `TransactionForm` (Income/Expense) to include the "Recurring" toggle and frequency settings.
- Update `ProjectionPage` and `ProjectionTable` to display recurring instance indicators.
- Create a `ManageRecurringPage` to list and edit templates.

### 4. Integration
- Ensure that adding a new recurring item triggers a projection reload on the Home page and Projections page.

## Success Checklist
- [ ] User can save a recurring transaction with "Every 2 Weeks" frequency.
- [ ] Projections show the recurring amount on the correct future dates.
- [ ] Editing one instance in the projection table correctly creates an override.
- [ ] Deleting a template removes all future occurrences from projections.
