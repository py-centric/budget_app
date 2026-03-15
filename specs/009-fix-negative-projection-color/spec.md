# Feature Specification: Show red color for negative balances in projection graphs

**Feature Branch**: `009-fix-negative-projection-color`  
**Created**: 2026-03-12  
**Status**: Draft  
**Input**: User description: "new feature the projection graph must show red when the balance is below zero, currently shows negative as green"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visual Warning for Negative Balance (Priority: P1)

As a user, I want the financial projection graph to show negative balances in red so that I can easily identify periods where I might run out of money.

**Why this priority**: Immediate visual identification of financial risk is a core value of a budget projection tool. Using green for negative values is misleading and potentially harmful to user planning.

**Independent Test**: Can be tested by entering expenses that exceed income/current balance and verifying that the resulting projection graph displays the negative portion of the trend line in red.

**Acceptance Scenarios**:

1. **Given** a projected balance that drops below zero, **When** I view the projection graph, **Then** the portion of the graph representing negative values must be colored red.
2. **Given** a projected balance that remains positive, **When** I view the projection graph, **Then** the graph should continue to use the standard primary/positive color (green).

---

### Edge Cases

- **Balance crossing zero**: The transition from green to red should happen precisely at the zero line on the Y-axis.
- **Extreme values**: The color logic should hold even for very large negative or positive values.
- **Empty states**: If no data is available, the "No data" state should remain neutral.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Points and line segments in the projection graph representing a balance < 0 MUST be displayed in red.
- **FR-002**: Points and line segments in the projection graph representing a balance >= 0 MUST be displayed in the standard primary color (green).
- **FR-003**: This color logic MUST apply to both the full Projection Chart and the Home Page Mini-Chart.
- **FR-004**: The background area under the curve (if area chart is used) MUST also reflect the color logic (red fill for negative areas using `aboveBarData`, green/primary fill for positive areas using `belowBarData`).
- **FR-005**: The projection table MUST display negative balance values in red text and positive/zero balances in the standard theme text color.

### Key Entities *(include if feature involves data)*

- **ProjectionPoint**: A data point in the projection series, now with an associated color attribute (derived from the balance value).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of negative data points in the projection graph are rendered in the designated red color.
- **SC-002**: The color transition occurs within a 5px margin of the zero-axis intersection.
- **SC-003**: Tabular view and Graphical view colors are synchronized for negative values.
