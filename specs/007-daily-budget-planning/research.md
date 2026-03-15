# Research: Daily Budget Planning and Projections

## Decisions

### Decision 1: Graphing Library selection
- **What was chosen**: `fl_chart`
- **Rationale**: It is the most popular and flexible charting library for Flutter. It supports line charts (perfect for balance projections) and area charts, which are requested in the spec. It handles large datasets well and is highly customizable.
- **Alternatives considered**:
    - `syncfusion_flutter_charts`: Feature-rich but has a proprietary license (Community license available but with revenue limits).
    - `community_charts_flutter`: Google's old `charts_flutter` maintained by the community, but `fl_chart` is currently more active and has better Material 3 support.

### Decision 2: Projection Calculation Strategy
- **What was chosen**: Synchronous calculation in a Repository or Use Case layer, wrapped in a BLoC for state management.
- **Rationale**: Since we are offline-first with SQLite, calculating a 90-day projection (max horizon) involves simple arithmetic on at most a few hundred records. This can be done efficiently in Dart. We will emit a `ProjectionLoaded` state containing the pre-calculated data points for both table and graph.
- **Alternatives considered**:
    - Computing on-the-fly in the UI: Bad for performance and separation of concerns.
    - Database views/triggers: Overly complex for simple running balance logic.

### Decision 3: Weekly Grouping Logic
- **What was chosen**: Custom grouping function that takes `weekStartDay` into account.
- **Rationale**: The user requested the ability to define the starting day of the week. Standard `DateTime` week logic is often hardcoded to Monday or Sunday. A custom utility will allow us to bucket transactions correctly based on the user's preference.
- **Alternatives considered**:
    - Using `intl`'s default week logic: Too rigid for the "User-defined Start Day" requirement.

## Findings

1. **fl_chart** supports custom tooltips and touch interactions, which will be useful for showing the exact balance on specific dates in the graph.
2. **sqflite** performance for the query `SELECT * FROM transactions WHERE date BETWEEN ? AND ?` is very high, even without indexes, for the volume of data expected in a personal budget app. However, adding an index on the `date` column is recommended.
3. **Daily vs Weekly**: The Daily view is the "source of truth". The Weekly view is a projection of the balance at the end of each week-ending day.

## Best Practices

### fl_chart
- Use `LineChart` with `belowBarData` for the area chart look.
- Use `FlTitlesData` to customize the X-axis labels for daily (1, 5, 10...) vs monthly (Jan, Feb...).

### Date Management
- Always use `DateTime.utc()` or local dates consistently.
- For budget planning, local date is usually preferred as users think in their own timezone.
- Use `DateTime(year, month, day)` to strip time components for daily bucketing.
