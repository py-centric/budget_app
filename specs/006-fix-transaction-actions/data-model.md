# Data Model: Transaction & UI State

## Entities

### IncomeEntry / ExpenseEntry (Domain)
*   **Fields**:
    *   `id`: `String` (UUID)
    *   `amount`: `double`
    *   `categoryId`: `String`
    *   `description`: `String?`
    *   `date`: `DateTime`

### BudgetState (Presentation)
*   `BudgetInitial`: Starting state.
*   `BudgetLoading`: Data fetch in progress.
*   `SummaryLoaded`: Contains `BudgetSummary` (list of income, expenses, and totals).
*   `CategoriesLoaded`: Contains a list of `Category` entities.
*   `EntryAdded`: Emitted after `AddIncome` or `AddExpense`.
*   `EntryDeleted`: (**NEW**) Emitted after `DeleteEntry`.
*   `EntryUpdated`: (**NEW**) Emitted after `UpdateIncome` or `UpdateExpense`.
*   `BudgetError`: Contains an error message.

## State Transitions

### Deletion
1.  User slides and clicks "Delete".
2.  `DeleteEntryEvent` dispatched to `BudgetBloc`.
3.  `BudgetBloc` executes `DeleteEntry` use case asynchronously.
4.  On success, `BudgetBloc` emits `EntryDeleted`.
5.  `HomePage` listener catches `EntryDeleted`, shows a SnackBar, and dispatches `LoadSummaryEvent`.
6.  `BudgetBloc` executes `CalculateSummary` and emits `SummaryLoaded`.

### Editing
1.  User slides and clicks "Edit".
2.  `HomePage` opens `TransactionEditDialog` with the item's data.
3.  User saves changes.
4.  `UpdateIncomeEvent` or `UpdateExpenseEvent` dispatched to `BudgetBloc`.
5.  `BudgetBloc` executes `UpdateEntry` use case.
6.  On success, `BudgetBloc` emits `EntryUpdated`.
7.  `HomePage` listener catches `EntryUpdated`, closes the dialog, and dispatches `LoadSummaryEvent`.
