# Research: Dark Mode Support

## Dec-01: Persistent Theme Storage
- **Decision**: Use `HydratedBloc` in `SettingsBloc` to persist the `themeMode`.
- **Rationale**: `HydratedBloc` is already used for `currencyCode` and provides a simple way to persist key-value pairs without manual SQLite or `SharedPreferences` management.
- **Alternatives considered**: `SharedPreferences` (rejected as it adds an unnecessary dependency since `HydratedBloc` is already available).

## Dec-02: Reacting to System Theme Changes
- **Decision**: Use `ThemeMode.system` as the default value. The `MaterialApp` will automatically listen to system brightness changes when `ThemeMode.system` is active.
- **Rationale**: Standard Flutter practice. No manual listener is required if `MaterialApp.themeMode` is properly set.

## Dec-03: Theme Selection Options
- **Decision**: Provide "Light", "Dark", and "System Default" as options.
- **Rationale**: Matches modern user expectations for theme control.

## Dec-04: Component Consistency
- **Decision**: Rely on `Theme.of(context)` for all component colors.
- **Rationale**: Ensures that custom widgets (like projection charts) adapt correctly if they use the app's `ColorScheme`.
