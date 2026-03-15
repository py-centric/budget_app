# Feature Specification: Global Currency Selection

**Feature Branch**: `016-currency-selection`  
**Created**: 2026-03-13  
**Status**: Draft  
**Input**: User description: "allow the user to be able to select the currency they are using"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Select Preferred Currency (Priority: P1)

As a user, I want to select my preferred currency from a list in the settings, so that all monetary values in the app reflect my local or chosen currency symbol and formatting.

**Why this priority**: Essential for global usability. The app is currently limited to a single hardcoded currency (USD assumed), which limits its target audience.

**Independent Test**: Navigate to settings, change currency from USD to EUR. All balances and transaction amounts should immediately display with the € symbol instead of $.

**Acceptance Scenarios**:

1. **Given** I am on the settings page, **When** I select "Euro (EUR)" from the currency list, **Then** my preference must be saved locally.
2. **Given** I have changed my currency to EUR, **When** I navigate to the Home page, **Then** all summary amounts and transaction list items must use the € symbol.

---

### User Story 2 - Automated Locale Detection (Priority: P2)

As a user opening the app for the first time, I want the app to automatically detect my device's locale and suggest or set the corresponding currency, so that I don't have to configure it manually.

**Why this priority**: Improves onboarding experience and "alive" feel of the app.

**Independent Test**: Install app on a device with locale set to United Kingdom. The default currency should be set to GBP (£).

**Acceptance Scenarios**:

1. **Given** no currency preference is set, **When** the app initializes, **Then** it should attempt to derive the currency from the system locale.
2. **Given** a detected locale, **When** no match is found in the supported list, **Then** it should fallback to USD ($).

---

### Edge Cases

- **No Match Found**: If the device locale does not correspond to a supported currency code, system defaults to USD.
- **UI Overflow**: Some currency symbols (e.g., "kr", "zł") or long codes might cause layout shifts in tight headers or summary cards.
- **Historical Data**: Changing currency does NOT perform conversion (e.g., $100 does not become €92). It only changes the display symbol. This MUST be clear to the user.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a selection list of common global currencies (USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, etc.) in the Settings page.
- **FR-002**: System MUST store the selected currency code in persistent local storage (HydratedBloc or UserSettings table).
- **FR-003**: System MUST provide a centralized formatting utility that respects the selected currency preference.
- **FR-004**: All UI components displaying monetary values MUST use the centralized formatting utility.
- **FR-005**: System MUST detect the initial currency from the device locale on first run.
- **FR-006**: Changing the currency MUST trigger an immediate global UI update without requiring an app restart.

### Key Entities *(include if feature involves data)*

- **UserSettings (Update)**:
    - `currencyCode`: String (ISO 4217 code, e.g., "USD", "EUR").
    - `currencySymbol`: String (Computed, e.g., "$", "€").

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: User can change currency in under 3 taps from the Home page.
- **SC-002**: UI updates all currency symbols globally within 300ms of selection.
- **SC-003**: 100% persistence of currency preference after app termination and restart.
- **SC-004**: Zero manual formatting logic allowed in individual widgets (enforced by centralized utility).
