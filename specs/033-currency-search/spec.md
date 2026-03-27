# Feature Specification: Currency Search

**Feature Branch**: `033-currency-search`  
**Created**: 2026-03-27  
**Status**: Draft  
**Input**: User description: "for all the currency fields add a search box, to make it easier to search for and select currencies"

## User Scenarios & Testing

### User Story 1 - Search Currency by Code (Priority: P1)

As a user, I want to search for currencies by their code (e.g., "USD", "EUR") so that I can quickly find the currency I need.

**Why this priority**: This is the core functionality - users know the currency codes and want fast access.

**Independent Test**: Can be tested by typing "USD" in the search box and verifying USD appears at the top of results.

**Acceptance Scenarios**:

1. **Given** the currency dropdown is open, **When** the user types "USD", **Then** USD should appear in the filtered results
2. **Given** the currency dropdown is open, **When** the user types a partial code like "US", **Then** all currencies starting with "US" should appear

---

### User Story 2 - Search Currency by Name (Priority: P1)

As a user, I want to search for currencies by their full name (e.g., "Dollar", "Euro") so that I can find currencies even if I don't know the code.

**Why this priority**: Users may not remember exact codes but know the currency name.

**Independent Test**: Can be tested by typing "Dollar" and verifying USD, CAD, AUD appear in results.

**Acceptance Scenarios**:

1. **Given** the currency dropdown is open, **When** the user types "Dollar", **Then** USD, CAD, AUD should appear in results
2. **Given** the currency dropdown is open, **When** the user types "Pound", **Then** GBP should appear

---

### User Story 3 - Select Currency from Results (Priority: P1)

As a user, I want to select a currency from the filtered results so that it gets applied to my account/budget.

**Why this priority**: The end goal - user selects and continues.

**Independent Test**: Can be tested by searching, selecting a currency, and verifying it's saved.

**Acceptance Scenarios**:

1. **Given** search results are displayed, **When** the user taps a currency, **Then** it should be selected and form should update

---

### Edge Cases

- What happens when search returns no results? - Show "No currencies found" message
- What happens when user clears the search? - Show all currencies again
- Should search be case-insensitive? - Yes, "usd" should match "USD"

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow users to search currencies by 3-letter ISO code
- **FR-002**: System MUST allow users to search currencies by full name
- **FR-003**: Search MUST be case-insensitive
- **FR-004**: System MUST display "No results" when search yields no matches
- **FR-005**: System MUST show all currencies when search box is cleared

### Key Entities

- **Currency**: ISO 4217 currency with code (USD) and name (US Dollar)

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can find and select any currency in under 5 seconds
- **SC-002**: Search results appear instantly as user types (no noticeable delay)
- **SC-003**: 100% of the 20 currencies are searchable by code and name
