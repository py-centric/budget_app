# Research: Show red color for negative balances in projection graphs

## Decisions

### Decision 1: Chart Line Coloring
- **What was chosen**: Split the `LineChartBarData` into multiple segments or use `LineChartBarData.gradient` with `stops`.
- **Rationale**: `fl_chart` does not natively support a single line changing color abruptly at a specific Y-value threshold without shaders or gradients. Using a linear gradient with sharp stops at the zero intersection point is the most performant and standard approach in Flutter.
- **Alternatives considered**: 
    - Splitting the data into two separate `LineChartBarData` objects: Complex to manage the intersection point accurately.
    - Custom painter overlay: High overhead for a simple color change.

### Decision 2: Area Fill Coloring
- **What was chosen**: Use `belowBarData` and `aboveBarData` with different colors.
- **Rationale**: `fl_chart` provides built-in support for filling areas above and below the line. We can use this to fill negative areas with transparent red and positive areas with transparent green.
- **Alternatives considered**: 
    - Single `belowBarData` with gradient: Harder to control the exact split at zero.

### Decision 3: Table Text Coloring
- **What was chosen**: Conditional `TextStyle` based on the balance value.
- **Rationale**: Standard Flutter approach for `DataTable` or `Text` widgets. Extremely simple and performant.
- **Alternatives considered**: None (this is the idiomatic way).

## Findings

1. **fl_chart Gradient**: To achieve a sharp color transition, the `gradient` stops must be very close together at the zero crossing point. We will need a utility to calculate the normalized Y-position of 0.0 relative to the chart's `minY` and `maxY`.
2. **Mini-Chart**: The `HomeProjectionOverview` widget uses a very simplified `LineChart`. The same logic applied to the full chart can be applied here.
3. **Synchronization**: The color logic should be centralized in a utility or within the `ProjectionPoint` model if possible, to ensure the table and both charts use the same "red" and "green" definitions.

## Best Practices

### fl_chart
- Use `LineChartBarData.gradient` for the line itself.
- Use `BarAreaData` for the fills.
- Ensure `minY` and `maxY` are explicitly calculated to allow accurate gradient stop normalization.

### UI Consistency
- Use `Theme.of(context).colorScheme.error` for red.
- Use a consistent "success" or "primary" green for positive values.
