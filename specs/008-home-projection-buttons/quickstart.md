# Quickstart: Home Page Projection and Enhanced Action Buttons

## Implementation Order

### 1. Fix "Add Expense" Button
- Audit `HomePage`'s `_HomePageState` logic for toggling `_showIncomeForm`.
- Ensure `AddExpenseEvent` is being correctly added to `BudgetBloc`.
- Verify the `ExpenseForm` widget is properly receiving its category list.

### 2. UI - Expanded FAB (Speed Dial)
- Create `TransactionSpeedDial` widget in `lib/features/budget/presentation/widgets/`.
- Implement background dimming using `Stack` and `AnimatedOpacity`.
- Replace existing text buttons in `HomePage` with the new FAB.

### 3. UI - Projection Overview
- Create `HomeProjectionOverview` widget in `lib/features/budget/presentation/widgets/`.
- Implement `PageView` or `GestureDetector` for horizontal swiping.
- Integrate a simplified `LineChart` from `fl_chart`.

### 4. Integration
- Wire the `HomeProjectionOverview` to the `ProjectionBloc` (or share existing state).
- Ensure the widget sits at the top of the `HomePage` content area.

## Success Checklist
- [ ] "Add Expense" button successfully submits data to SQLite.
- [ ] FAB expands/collapses with a background dim effect.
- [ ] Swiping the projection widget changes the time horizon.
- [ ] Tapping the projection widget navigates to `/projections`.
- [ ] No UI overflows on small screens.
