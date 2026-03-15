# Research: Home Page Projection and Enhanced Action Buttons

## Decisions

### Decision 1: Mini-Chart Implementation
- **What was chosen**: Simplified `LineChart` from `fl_chart` within a `PageView` or `Swipeable` container.
- **Rationale**: Reuses the established `fl_chart` dependency while keeping the UI lightweight for the home page. `PageView` allows for the requested swipeable horizons (Current Month, 7-day, 30-day).
- **Alternatives considered**: 
    - Custom painter: Too time-consuming for a standard trend line.
    - Sparkline library: Extra dependency not worth the small benefit over `fl_chart`.

### Decision 2: Expanded FAB Group (Speed Dial)
- **What was chosen**: Custom implementation using `Stack` and `AnimatedBuilder` (or `flutter_speed_dial` if already present, but prefer custom for minimal overhead and full design control).
- **Rationale**: Allows for the specific "bigger/visible" requirement and background dimming requested in the spec. A custom implementation ensures precise Material 3 alignment.
- **Alternatives considered**:
    - Standard FAB with menu: Too small for the user's "bigger" requirement.
    - Persistent bottom bar: Rejected by user in clarification phase.

### Decision 3: Background Dimming
- **What was chosen**: `ModalBarrier` or a simple `AnimatedContainer` with a semi-transparent color overlaying the home page content when the FAB is expanded.
- **Rationale**: Standard Material Design pattern for Speed Dials. It satisfies the "more visible" requirement by reducing background noise.

## Findings

1. **"Add Expense" Investigation**: Preliminary check of `HomePage` shows that the `ExpenseForm` submission is correctly adding an `AddExpenseEvent` to the `BudgetBloc`. However, the switch between Income and Expense forms might be losing state or failing to rebuild properly if the `BlocConsumer` isn't handling the transition correctly. The "not working" report likely refers to the UI toggle or a validation error blocking submission.
2. **fl_chart Performance**: The mini-chart on the home page should use a reduced number of data points (e.g., one point per day or per week depending on horizon) to ensure 60fps scrolling on the home page.

## Best Practices

### Animation
- Use `Curves.easeInOut` for the FAB expansion for a polished feel.
- Ensure the background dimming animation is synchronized with the FAB expansion.

### UX
- The "Projection Overview" should be a clear tap target for navigation to the full projections page.
- Large FAB labels should be legible and have high contrast against the background dim.
