# Quickstart: Daily Budget Planning and Projections

## Implementation Order

### 1. Data Layer
- Update `IncomeEntry` and `ExpenseEntry` models to include the `date` field.
- Update `LocalDatabase` to handle the `date` column and optional index.
- Update `BudgetRepository` to support querying by date ranges.

### 2. Domain Layer
- Create a `ProjectionUseCase` to calculate `ProjectionPoint` series.
- Implement the "Daily" vs "Weekly" grouping logic using `weekStartDay` from user settings.

### 3. Presentation Layer (BLoC)
- Add `ProjectionEvent` and `ProjectionState` to manage the calculation process.
- Implement the projection horizon and "Show Actuals" logic in the BLoC.

### 4. UI Widgets
- Add a "Date" picker to the income form (defaulting to the 1st of the month).
- Integrate `fl_chart` to render the balance graph.
- Create a `ProjectionTable` to show daily/weekly balances.
- Add toggle controls for "Daily/Weekly", "Projection Horizon", and "Show Actuals".

## Success Checklist
- [ ] Users can set a date on an income entry.
- [ ] Users can see a chart showing balance over time.
- [ ] Users can see a table showing balance over time.
- [ ] Toggling "Weekly" aggregates data correctly.
- [ ] Changing the horizon updates both table and chart.
- [ ] Calculation completes in <200ms.
