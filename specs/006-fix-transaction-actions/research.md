# Research: Fix and Complete Transaction Slide Actions

## Decisions

### Decision 1: Handle Deletion in BudgetBloc and HomePage
- **What was chosen**: Update `BudgetBloc` to emit an `EntryDeleted` state, and have `HomePage` listener handle this state by triggering a `LoadSummaryEvent`.
- **Rationale**: `BudgetInitial` is too generic and is used during initial loading. A specific `EntryDeleted` state allows for precise side effects, like showing a SnackBar confirmation or automatically refreshing data.
- **Alternatives considered**:
    - Reusing `LoadSummaryEvent` directly in `BudgetBloc`: Not recommended by BLoC best practices as one event handler shouldn't directly call another; instead, it should emit a state that the UI responds to.
    - Adding `LoadSummaryEvent` in `HomePage` listener for `BudgetInitial`: Would work but is less clear than a dedicated `EntryDeleted` state.

### Decision 2: Implement Transaction Edit Dialog
- **What was chosen**: Create a `TransactionEditDialog` widget instead of using a full-page `EditEntryPage`.
- **Rationale**: Direct user request ("the edit, must just bring a pop up with the fields"). Provides a faster, smoother editing experience without full page transitions.
- **Alternatives considered**:
    - Completing `EditEntryPage`: Rejected as per user's preference for a popup.

### Decision 3: Fix Navigation after Deletion
- **What was chosen**: If a delete is triggered from a sub-view (if any existed), ensure the system pops back to the Home view. In `HomePage`, simply refreshing the list is sufficient.
- **Rationale**: Matches user expectation ("take you back to the home page").

## Findings

1. **Hanging Bug**: The current `BudgetBloc` emits `BudgetInitial()` on deletion. `HomePage` displays a loading indicator for `BudgetInitial`. However, `BudgetInitial` does not trigger a reload in the `BlocListener` or `BlocConsumer`, leading to a permanent loading state.
2. **Incomplete Edit**: `EditEntryPage` is currently a stub that doesn't pre-fill data or handle updates.

## Best Practices

### Flutter Slidable
- Use `ValueKey` for list items to ensure correct state management when items are removed.
- Use `ActionPane` with `ScrollMotion` for a standard Material look.

### Modal Dialogs
- Use `showDialog` with a `Dialog` or `AlertDialog` that contains a `Form` with a `GlobalKey` for validation.
- Pre-fill `TextEditingController` values from the entity being edited.
