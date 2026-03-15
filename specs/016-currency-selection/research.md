# Research: Global Currency Selection

## Dec-01: Centralized Formatting Utility
- **Decision**: Enhance `lib/core/utils/currency_formatter.dart` to accept a `currencyCode` and use the `intl` package's `NumberFormat.simpleCurrency`.
- **Rationale**: The `intl` package is standard for Flutter localization. Using `simpleCurrency` automatically handles symbol placement (prefix vs. suffix) and decimal separators based on the currency code.
- **Alternatives considered**: 
    - Manual string concatenation: Rejected due to complex global variations in symbol placement and formatting rules.

## Dec-02: Initial Currency Detection
- **Decision**: Use `PlatformDispatcher.instance.locale` to get the system locale and map it to a currency code using a lookup map or the `intl` package's `NumberFormat().currencyName`.
- **Rationale**: Avoids adding an external dependency like `devicelocale` for simple detection. `PlatformDispatcher` is built into Flutter and works well for most cases.
- **Alternatives considered**: 
    - Always defaulting to USD: Rejected as it provides a poor initial UX for international users.

## Dec-03: State Management for Settings
- **Decision**: Implement a `SettingsBloc` (using `HydratedBloc`) at the root of the app (`main.dart`).
- **Rationale**: `HydratedBloc` provides built-in persistence. Providing it at the root ensures that every widget can access the current currency via `context.watch<SettingsBloc>()` or by passing the state down.
- **Alternatives considered**: 
    - SQLite for settings: Rejected as overkill for simple key-value preferences. `HydratedBloc` is faster to implement and maintain.

## Dec-04: UI Update Mechanism
- **Decision**: All widgets displaying money MUST consume the `SettingsBloc` state.
- **Rationale**: Flutter's reactive framework will automatically trigger a rebuild of these widgets when the `SettingsBloc` emits a new state with a different currency code.
- **Alternatives considered**: 
    - Event bus: Rejected as it's less idiomatic in Bloc-based applications.
