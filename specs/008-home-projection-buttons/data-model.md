# Data Model: Home Page Projection and Enhanced Action Buttons

## Entities

### HomeProjectionState (UI State)
- **points**: `List<ProjectionPoint>` (Lightweight trend data)
- **currentHorizon**: `String` (One of "MONTH", "7_DAYS", "30_DAYS")
- **isExpanded**: `bool` (FAB expansion state)

## Relationships
- **HomeProjectionState** is managed within the `HomePage` or a dedicated `HomeBloc`.
- **ProjectionPoints** are sourced from the existing `ProjectionUseCase`.

## Validation Rules
- **Horizon Switch**: Must trigger a lightweight recalculation or filter of cached projection data.
- **FAB State**: Must close when a transaction form is opened or the background is tapped.

## State Transitions
1. **Initial**: Home page loads, default "MONTH" projection requested.
2. **Swipe**: User swipes widget, `currentHorizon` updates, new points rendered.
3. **Expand**: User taps main FAB, `isExpanded` becomes true, background dims.
4. **Action**: User taps "Add Income", `isExpanded` becomes false, form opens.
