# Budget App

> ⚠️ **This project is still in active development.** Some features may be incomplete or subject to change.

A comprehensive personal finance management Flutter application with support for budgets, transactions, loans, invoicing, and more.

## Features

### Core Features
- **Budget Management** - Create and manage monthly budgets with multi-currency support
- **Transaction Tracking** - Track income and expenses with categories
- **Categories** - Customizable expense/income categories with icons and colors
- **Recurring Transactions** - Automate regular income and expenses
- **Financial Projections** - Forecast income and expenses based on recurring transactions

### Advanced Features
- **Currency Conversion** - Support for 20 currencies with manual exchange rates
- **Travel Budget Planner** - Duplicate budgets with currency conversion for travel
- **Loans Management** - Track money lent and borrowed with payment tracking
- **Emergency Fund Calculator** - Calculate and track your financial safety net
- **Business Tools** - Invoice dashboard and payable tracking
- **Financial Calculators** - Tip, currency, loan, and savings calculators

### Data Management
- **Export** - Export data to CSV, PDF, and Excel formats
- **Backup & Restore** - Full database backup and restore
- **App Lock** - PIN and biometric authentication

## Tech Stack

- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: flutter_bloc
- **Database**: SQLite (sqflite)
- **Security**: flutter_secure_storage, local_auth

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Android SDK or Xcode (for mobile builds)

## Architecture & Feature Flagging System

The app utilizes a decoupled **Feature Flagging & Release Edition** engine allowing single-codebase targeting for Personal, Business, or Combined product editions.

```mermaid
graph TD
    subgraph Build & Environment
        A["Compile Flag<br/>(--dart-define=RELEASE_EDITION=...)"] --> B["DefaultFeatureMapping"]
        C["Dev Settings Override"] --> D["HydratedStorage (Local Cache)"]
    end

    subgraph State Management Layer
        B --> E["FeatureFlagsBloc"]
        D --> E
        E --> F["FeatureGateService"]
    end

    subgraph UI & Navigation Layer
        F --> G["FeatureGate Widget"]
        F --> H["FeatureRouteGuard"]
        G --> I["Navigation Drawer"]
        G --> J["Dashboard Widget Catalog"]
        H --> K["Gated Feature Screens"]
    end

    subgraph Storage Layer (Offline-First)
        L[("Local SQLite Database")]
        M["Unified Table Schema (Preserved across editions)"]
        L --- M
    end

    I -. Access Gated .-> L
```

### Running & Building by Release Edition

The app supports three target release editions (`personal`, `business`, and `combined`).

#### Using `make` (Recommended)

```bash
# Run local dev targets
make run-personal     # Run Personal Edition
make run-business     # Run Business Edition
make run-combined     # Run Combined Edition

# Build Linux executables
make build-personal   # Build Personal release
make build-business   # Build Business release
make build-combined   # Build Combined release
make build-all        # Build all 3 release editions

# Build Android APKs
make build-personal-apk
make build-business-apk
make build-combined-apk

# Documentation & Testing
make test             # Run test suite
make docs             # Generate diagrams & Sphinx HTML docs
```

#### Direct `flutter` CLI Commands

```bash
# Personal Edition (Budgeting, savings, debt payoff)
flutter run -d linux --dart-define=RELEASE_EDITION=personal

# Business Edition (Invoicing, payables, reconciliation)
flutter run -d linux --dart-define=RELEASE_EDITION=business

# Combined Edition (Full suite - default)
flutter run -d linux --dart-define=RELEASE_EDITION=combined
```

### Installation

```bash
# Clone the repository
git clone https://github.com/py-centric/budget_app.git
cd budget_app

# Install dependencies
flutter pub get

# Generate code (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Building

```bash
# Debug build
flutter build apk

# Release build
flutter build apk --release
```

## Project Structure

```
lib/
├── core/           # Shared utilities, themes, constants
├── features/       # Feature modules
│   ├── app_lock/       # App lock with biometrics
│   ├── backup/        # Database backup/restore
│   ├── budget/        # Budget management
│   ├── business_tools/# Invoicing and payables
│   ├── emergency_fund/# Emergency fund calculator
│   ├── export/        # Data export
│   ├── financial_tools/ # Calculators
│   ├── loans/         # Loans management
│   └── settings/      # App settings
└── main.dart
```

## Documentation

Full documentation is available in the `docs/` directory:
- [Getting Started](docs/getting_started.rst)
- [Architecture](docs/architecture.rst)
- [Budget Management](docs/budget_management.rst)
- [Transactions](docs/transactions.rst)
- [and more...](docs/)

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](docs/contributing.rst) before submitting PRs.

## License

MIT License - see LICENSE file for details.
