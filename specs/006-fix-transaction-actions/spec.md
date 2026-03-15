# Feature Specification: Fix and Complete Transaction Slide Actions

**Feature Branch**: `006-fix-transaction-actions`  
**Created**: 2026-03-12  
**Status**: Draft  
**Input**: User description: "the slide to remove and edit income and expense items, isn't fully implement yet, the edit, must just bring a pop up with the fields, the delete currently leave the app hanging, and doesn't refresh and take you back to the home page"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Edit Transaction via Slide (Priority: P1)

As a user, I want to be able to slide a transaction item to reveal an edit action that opens a popup so I can quickly correct transaction details.

**Why this priority**: Correcting data entry errors is a core user need for financial tracking. Providing a quick "slide-to-edit" shortcut enhances the user experience.

**Independent Test**: Can be tested by sliding an income or expense item, clicking "Edit", and verifying a popup appears with the correct fields pre-filled.

**Acceptance Scenarios**:

1. **Given** I am on the transaction list, **When** I slide an item to the right/left and tap "Edit", **Then** a popup dialog should appear with all transaction fields (amount, category, date, description).
2. **Given** the edit popup is open, **When** I modify a field and tap "Save", **Then** the popup should close, the transaction should be updated in the database, and the list should refresh to show the new data.

---

### User Story 2 - Delete Transaction via Slide (Priority: P1)

As a user, I want to be able to slide a transaction item to reveal a delete action that removes the item and immediately updates the UI without hanging.

**Why this priority**: Users must be able to remove incorrect or duplicate entries. The current "hanging" behavior is a critical bug that prevents normal app usage after a deletion attempt.

**Independent Test**: Can be tested by sliding an item, tapping "Delete", and verifying the item disappears and the app remains responsive.

**Acceptance Scenarios**:

1. **Given** I am on the transaction list, **When** I slide an item and tap "Delete", **Then** the item should be removed from the database immediately.
2. **Given** a deletion has just occurred, **When** the system completes the request, **Then** the app should remain responsive (no hanging), the transaction list should refresh, and the summary card should update.

---

### User Story 3 - Return to Home after Deletion (Priority: P2)

As a user, I want the app to return me to the primary view/refresh the view after I delete a transaction so I can continue managing my budget.

**Why this priority**: Ensures a smooth flow and clear feedback that the action was successful and the system state is reset.

**Independent Test**: Can be tested by performing a delete action and verifying the user is redirected to the home/summary view if they were in a sub-view, or the current view refreshes.

**Acceptance Scenarios**:

1. **Given** I am deleting or editing a transaction, **When** the action is confirmed, **Then** the system MUST dismiss the edit/delete dialog and, if initiated from a sub-page, navigate back to the primary Home/Summary view with refreshed data.

---

### Edge Cases

- **What happens when the database is busy?** The system should show a brief loading indicator instead of hanging the entire UI.
- **How does the system handle deleting the last item in a month/category?** The list should refresh to show an "Empty State" widget.
- **What happens if I slide and then tap outside?** The slide action should be cancelled, and the item should return to its original position.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a "Slide to Edit" action on all income and expense items in the list.
- **FR-002**: System MUST open a Modal Popup (Dialog) when the "Edit" action is triggered.
- **FR-003**: The Edit Popup MUST contain fields for Amount, Category, Date, and Description.
- **FR-004**: System MUST provide a "Slide to Delete" action on all income and expense items.
- **FR-005**: System MUST perform deletions asynchronously and ensure the UI thread remains responsive.
- **FR-006**: System MUST refresh the active period's transaction list and summary totals immediately after a successful deletion or edit.
- **FR-007**: System MUST provide visual feedback (e.g., a SnackBar) confirming the deletion or update.

### Key Entities *(include if feature involves data)*

- **Transaction (Income/Expense)**: Represents a single financial record with an ID, amount, date, category reference, and optional description.
- **Budget Period**: The logical grouping (usually Month/Year) where the transaction resides and where the refresh must occur.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of "Delete" actions result in a responsive UI (zero "hanging" incidents).
- **SC-002**: Users can initiate an edit in under 1 second (time from slide/tap to popup visible).
- **SC-003**: The transaction list and summary totals update within 500ms of a successful database operation.
- **SC-004**: Task completion rate for "Edit" and "Delete" is 100% for standard user flows.
- **SC-005**: Zero app crashes or forced restarts required during transaction management.
