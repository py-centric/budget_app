# Data Model: Show red color for negative balances in projection graphs

## Entities

### ProjectionPoint (Update)
- **isNegative**: `bool` (Helper property: true if balance < 0). Note: UI colors (Red/Green) MUST be resolved in the Presentation layer, not in this domain entity.

## Validation Rules
- **Color Logic Location**: Business rules for color thresholds remain in the domain, but specific `Color` objects and Flutter dependencies are restricted to widgets and utilities in the Presentation layer.
- **Visual Sync**: Both the graph line and the corresponding table row MUST use the same color logic.

## State Transitions
1. **Data Load**: `ProjectionBloc` emits `ProjectionLoaded` with a list of `ProjectionPoint` objects.
2. **Logic Mapping**: The UI components (Charts and Table) iterate through the points.
3. **Rendering**:
    - Table: Balance text color set via `balanceColor`.
    - Graphs: Gradient stops calculated based on the existence of negative values in the point set.
