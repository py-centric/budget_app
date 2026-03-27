# Quickstart: Multi-Bank Accounts Feature

## Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Android SDK / Xcode

## Setup

```bash
# Ensure dependencies are installed
cd budget_app
flutter pub get
```

## Implementation Steps

### 1. Database Changes

Add to `lib/core/database/local_database.dart`:
- Add Account table in `_onCreate`
- Add Transfer table in `_onCreate`
- Add migration in `_onUpgrade` (increment database version)

### 2. Create Feature Structure

Create `lib/features/accounts/` with:
- `domain/entities/account.dart`
- `domain/entities/transfer.dart`
- `domain/repositories/account_repository.dart`
- `data/models/account_model.dart`
- `data/models/transfer_model.dart`
- `data/repositories/account_repository_impl.dart`
- `presentation/bloc/account_bloc.dart`
- `presentation/pages/accounts_page.dart`
- `presentation/widgets/account_form.dart`
- `presentation/widgets/transfer_form.dart`

### 3. Register Routes

Add account routes to navigation in `main.dart` or routing setup.

### 4. Add to Navigation

Add "Accounts" option to:
- Navigation drawer
- Tools hub (if applicable)

## Running

```bash
# Run on connected device/emulator
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Key Files

- Database: `lib/core/database/local_database.dart`
- Feature: `lib/features/accounts/`
- BLoC: `lib/features/accounts/presentation/bloc/`

## Testing

Run unit tests for:
- Account repository
- Transfer logic
- Balance calculations
