# Quickstart: Show red color for negative balances in projection graphs

## Implementation Order

### 1. Model Enhancement
- Update `ProjectionPoint` in `lib/features/budget/domain/entities/projection_point.dart` to include helper methods or properties for determining color based on balance.

### 2. Table Updates
- Update `ProjectionTable` in `lib/features/budget/presentation/widgets/projection_table.dart` to apply conditional styling to the balance column.

### 3. Chart Logic (Utility)
- Create a utility method to calculate `gradient` and `stops` for `fl_chart` based on a list of `ProjectionPoint`s and the zero threshold.

### 4. Chart Updates
- Apply the color logic to `ProjectionChart` in `lib/features/budget/presentation/widgets/projection_chart.dart`.
- Apply the color logic to `HomeProjectionOverview` in `lib/features/budget/presentation/widgets/home_projection_overview.dart`.

## Success Checklist
- [ ] Projection table shows negative balances in red.
- [ ] Full projection chart shows negative line segments in red.
- [ ] Home page mini-chart shows negative line segments in red.
- [ ] Transition between green and red occurs exactly at zero.
- [ ] Area fill (if any) matches the line color logic.
