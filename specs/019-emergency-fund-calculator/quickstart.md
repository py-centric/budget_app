# Quickstart: Emergency Fund Calculator

## Overview
Implement a calculator that helps users define their emergency fund goal.

## Project Structure
- `lib/features/emergency_fund/`:
  - `data/`: `EmergencyFundRepository`, `EmergencyExpenseModel`
  - `domain/`: `EmergencyExpense` entity, `CalculateLivingExpensesUseCase`
  - `presentation/`: `EmergencyFundBloc`, `EmergencyCalculatorScreen`
  - `widgets/`: `ExpenseItemTile`, `LivingExpensesCalculator`

## Development Steps
1. **Database Migration**: Add the `emergency_expenses` table in `LocalDatabase._onUpgrade`.
2. **Repository Implementation**: Create `EmergencyFundRepository` with methods for fetching all, updating, adding custom, and deleting.
3. **Living Expenses Logic**: Implement the "average of last 3 months" logic in the repository.
4. **BLoC State Management**:
   - `EmergencyFundState`: `List<EmergencyExpense>`, `double totalTarget`, `double calculatedLivingExpenses`.
   - `EmergencyFundEvent`: `LoadExpenses`, `UpdateExpenseAmount`, `AddCustomExpense`, `DeleteCustomExpense`.
5. **UI Construction**:
   - Build a scrollable list of expenses.
   - Add a separate section or modal for the "Living Expenses" calculator.
   - Display the grand total prominently.

## Verification
- Run unit tests for the Living Expenses algorithm.
- Verify that data persists after app restarts.
- Ensure the total updates in real-time as amounts are changed.
