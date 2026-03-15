# Budget App - Gemini CLI Context

## Technology Stack (Current Plan)
- **Language**: Dart 3.x / Flutter 3.x
- **Frameworks**: `flutter_bloc`, `hydrated_bloc`, `sqflite`, `intl`, `uuid`, `flutter_slidable`
- **Database**: SQLite (via `sqflite`) - Offline-first local storage

## Architecture Principles
- Clean Architecture (UI → Domain → Data)
- Offline-first (All data local, no external APIs)
- Material Design 3

## Navigation & State
- **Active Period**: Managed via `NavigationBloc` (Global State)
- **Categories**: Dynamic management via `CategoryBloc`
- **Entries**: Editable via swipe actions (Popup Dialog) and Delete confirmation

