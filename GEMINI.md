# Budget App - Gemini CLI Context

## Technology Stack (Current Plan)
- **Language**: Dart 3.x / Flutter 3.x
- **Frameworks**: `flutter_bloc` (BLoC pattern), `hydrated_bloc` (persistence), `sqflite` (SQLite), `intl` (date/currency formatting), `fl_chart` (charting), `uuid`
- **Database**: SQLite (via `sqflite`) and HydratedBloc (for preferences) - Offline-first local storage

## Architecture Principles
- Clean Architecture (UI → Domain → Data)
- Offline-first (All data local, no external APIs)
- Material Design 3

## Navigation & State
- **Active Period**: Managed via `NavigationBloc` (Global State)
- **Currency**: Managed via `SettingsBloc` (Global State, persists via HydratedBloc)
- **Theme Mode**: Managed via `SettingsBloc` (Light, Dark, or System; persists via HydratedBloc)
- **Sidebar**: Grouped by Year, Chronological Month Navigation
- **Entries**: Editable via swipe actions (Popup Dialog) and Delete confirmation
- **Recurring Transactions**: Automated income/expenses with flexible frequency and overrides
- **Potential Transactions**: Modeled items for "what-if" projections; can be confirmed or deleted.
- **Home Page Summaries**: List headers for Income and Expenses display real-time actual and potential totals.
- **Financial Tools**: Dedicated hub for calculators (Net Worth, Loan, Savings); supports explicit "Save/Pin" persistence to SQLite.


## Active Technologies
- Dart 3.x / Flutter 3.x + `flutter_bloc`, `hydrated_bloc` (017-dark-mode)
- `hydrated_bloc` (persistent JSON storage) (017-dark-mode)
- Dart 3.x / Flutter 3.x + `flutter_bloc`, `hydrated_bloc`, `sqflite`, `intl` (for currency formatting), `fl_chart` (for amortization charts) (018-financial-calculators)
- SQLite (for pinned calculations) and `hydrated_bloc` (for UI state/scratchpad) (018-financial-calculators)
- Dart 3.x / Flutter 3.x + `flutter_bloc`, `sqflite`, `intl` (019-emergency-fund-calculator)
- SQLite (sqflite) for persistence of entries and global target (019-emergency-fund-calculator)

## Recent Changes
- 017-dark-mode: Added Dart 3.x / Flutter 3.x + `flutter_bloc`, `hydrated_bloc`
1
