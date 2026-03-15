# Data Model: Global Currency Selection

## Entities

### UserSettings
Manages application-wide user preferences.

| Field | Type | Description |
|-------|------|-------------|
| `currencyCode` | `String` | ISO 4217 code (e.g., "USD", "EUR", "GBP"). |
| `currencySymbol` | `String` | (Computed) The symbol associated with the code (e.g., "$", "€"). |

## Validation Rules
- `currencyCode` MUST be one of the supported ISO 4217 codes defined in the system.
- Initial value MUST be derived from system locale or default to "USD" if detection fails.

## State Transitions (SettingsBloc)

| Initial State | Action | Final State |
|---------------|--------|-------------|
| Initial (Null) | App Start | Detected Locale State |
| Loaded State | Change Currency | New Currency State + Persisted |
| Loaded State | Reset Settings | Default State (USD) |

## Supported Currencies (Initial List)
- USD ($)
- EUR (€)
- GBP (£)
- JPY (¥)
- CAD ($)
- AUD ($)
- CNY (¥)
- INR (₹)
