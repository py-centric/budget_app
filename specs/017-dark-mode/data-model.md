# Data Model: Dark Mode Support

## Entities

### UserSettings (Updated)
- `weekStartDay`: Integer (1-7)
- `defaultProjectionHorizon`: String
- `currencyCode`: String
- `themeMode`: String (New) - Persisted string representation of ThemeMode Enum ("light", "dark", or "system").

## State Transitions (SettingsBloc)

| Initial State | Action | Final State |
|---------------|--------|-------------|
| System (Default) | Switch to Dark | Dark (Persisted) |
| Dark | Switch to Light | Light (Persisted) |
| Light | Switch to System | System (Persisted) |
