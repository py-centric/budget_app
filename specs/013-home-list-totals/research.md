# Research: Home List Totals and Potential Balances

## Dec-01: Header Implementation in HomePage
- **Decision**: Update the `title` property of `ExpansionTile` in `home_page.dart` to use a `Row` containing the label and the calculated totals.
- **Rationale**: `ExpansionTile` allows a widget for the title. A `Row` with `MainAxisAlignment.spaceBetween` will keep the label on the left and the totals on the right, providing a professional look.
- **Alternatives considered**:
    - Adding totals as leading/trailing widgets: Rejected because `trailing` is often used for the expansion arrow, and `leading` is already occupied by the arrow/icon.

## Dec-02: BudgetSummary Extension
- **Decision**: Add `totalActualIncome`, `totalPotentialIncome`, `totalActualExpense`, and `totalPotentialExpense` fields to the `BudgetSummary` class.
- **Rationale**: Centralizing these calculations in the domain layer (Use Case) ensures UI logic remains simple and testable.
- **Alternatives considered**:
    - Calculating totals in the BLoC or UI: Rejected to maintain Clean Architecture principles and avoid logic duplication.

## Dec-03: Styling for Potential Totals
- **Decision**: Display potential totals in a secondary color (e.g., `Colors.blue` or `grey`) or with a specific label like "Incl. Potential: $X" when they differ from actuals.
- **Rationale**: Provides clear visual distinction between guaranteed money and hypothetical money.
- **Alternatives considered**:
    - Only showing the higher number: Rejected as it hides the "guaranteed" state from the user.
