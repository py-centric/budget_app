# Feature Specification: Home Page Projection and Enhanced Action Buttons

**Feature Branch**: `008-home-projection-buttons`  
**Created**: 2026-03-12  
**Status**: Draft  
**Input**: User description: "new feature show the projection overview in the home page, and make the add income/expense button more visible/bigger"

## Clarifications

### Session 2026-03-12
- Q: Should this feature branch explicitly include fixing the underlying logic for the currently broken expense button? → A: Include fix for existing expense button logic.
- Q: What should be the default time horizon for this home page mini-chart? → A: Support "Current Month", "Rolling 7-day", and "Rolling 30-day" views via swipe.
- Q: When the FAB is expanded, should the background content be dimmed or blurred? → A: Dim background when expanded.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Home Page Projection Overview (Priority: P1)

As a user, I want to see a summary of my financial projection directly on the home page so that I can immediately understand my future financial trend without navigating away.

**Why this priority**: High value for daily financial awareness and immediate engagement upon opening the app.

**Independent Test**: Can be tested by opening the Home page and verifying that a projection summary (e.g., a mini-chart or projected end-of-month balance) is visible at the top of the page.

**Acceptance Scenarios**:

1. **Given** I have future income and expenses recorded, **When** I open the Home page, **Then** I should see a "Projection Overview" section at the very top showing the trend of my balance.
2. **Given** the Projection Overview is visible, **When** I swipe left or right on the widget, **Then** the time horizon should switch between Current Month, Rolling 7-day, and Rolling 30-day views.
3. **Given** the Projection Overview is visible, **When** I tap on it, **Then** I should be taken to the full Projections page for detailed analysis.

---

### User Story 2 - Direct Add Transaction Buttons (Priority: P1)

As a user, I want the buttons to add income and expenses to be directly on the home page and extremely visible so that I can record new transactions without navigating through a menu.

**Why this priority**: Reduces friction for the most frequent user action (data entry), improving overall app utility by making actions immediate.

**Independent Test**: Can be tested by navigating to the Home page and verifying the presence of large, distinct, side-by-side buttons for "Add Income" and "Add Expense" directly below the summary.

**Acceptance Scenarios**:

1. **Given** I am on the Home page, **When** I look for the add transaction buttons, **Then** I should see prominent, side-by-side buttons for "Add Income" and "Add Expense".
2. **Given** the new button design, **When** I tap "Add Income" or "Add Expense", **Then** the respective transaction entry form should open immediately in a dialog.

---

### Edge Cases

- **No Projection Data**: If no future transactions exist, the Projection Overview should show a helpful "Getting Started" message or a neutral projection line.
- **Small Screens**: The larger buttons and projection overview must scale appropriately to avoid obscuring critical content or causing layout breaking on small devices.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Home page MUST include a "Projection Overview" widget at the top of the content area.
- **FR-002**: The Projection Overview MUST display a visual summary of the balance trend using a simplified line chart.
- **FR-003**: The Projection Overview MUST support multiple time horizons: Current Month, Rolling 7-day, and Rolling 30-day.
- **FR-004**: Users MUST be able to switch between these horizons via a swipe gesture on the widget.
- **FR-005**: The Projection Overview MUST serve as a navigation shortcut to the main Projections page.
- **FR-006**: The Home page MUST feature prominent, side-by-side "Add Income" and "Add Expense" buttons.
- **FR-007**: These buttons MUST use a minimum contrast ratio of 4.5:1 and provide a large, easily accessible touch target.
- **FR-008**: System MUST ensure the Projection Overview updates automatically when a new transaction is added from the home page.
- **FR-009**: System MUST fix any existing logic issues preventing the "Add Expense" functionality from working correctly.

### Key Entities *(include if feature involves data)*

- **HomeProjectionState**: A lightweight representation of the `Projection` entity, containing key trend points and the projected end-of-period balance.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can identify the Projection Overview within 500ms of the Home page loading.
- **SC-002**: Transaction entry forms open within 300ms of selecting the action from the expanded FAB.
- **SC-003**: 90% of users successfully navigate to the full Projection page via the Home page shortcut.
- **SC-004**: Zero UI overflow or layout breaking across standard screen sizes (360dp to 600dp width).
- **SC-005**: 100% success rate for "Add Expense" transactions after fix implementation.
