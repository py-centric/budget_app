# Architecture

## Overview

Budget App follows **Clean Architecture** principles with clear separation between UI, business logic, and data layers. The architecture ensures maintainability, testability, and scalability.

## Layer Structure

```
lib/
├── core/                  # Shared utilities and constants
│   ├── constants/        # App-wide constants
│   ├── theme/           # Material Design 3 theming
│   └── utils/           # Currency, date, and chart utilities
│
├── features/             # Feature modules (独立功能模块)
│   ├── budget/          # Core budget functionality
│   ├── settings/        # App settings
│   ├── export/           # Data export
│   ├── backup/          # Backup & restore
│   ├── loans/           # Loan management
│   ├── emergency_fund/  # Emergency fund calculator
│   ├── financial_tools/ # Financial calculators
│   └── business_tools/  # Invoices, clients, profiles
│
└── shared/              # Shared widgets and repositories
```

## Each Feature Follows Clean Architecture

```
feature/
├── domain/                    # Business Logic Layer
│   ├── entities/             # Business objects
│   ├── repositories/         # Repository interfaces
│   └── usecases/            # Business use cases
│
├── data/                     # Data Layer
│   ├── datasources/          # Local database (SQLite)
│   ├── models/               # Data models
│   └── repositories/         # Repository implementations
│
└── presentation/             # UI Layer
    ├── bloc/                 # BLoC state management
    ├── pages/               # Screen widgets
    └── widgets/             # Reusable UI components
```

## Key Components

### Domain Layer

- **Entities**: Pure business objects (Budget, IncomeEntry, ExpenseEntry, Category)
- **Repositories**: Abstract interfaces for data operations
- **Use Cases**: Business logic implementations

### Data Layer

- **LocalDatabase**: SQLite database via sqflite package
- **Models**: Database-specific data representations
- **Repository Implementations**: Concrete data access implementations

### Presentation Layer

- **BLoC**: State management using flutter_bloc
- **Pages**: Full-screen widgets for each route
- **Widgets**: Reusable UI components

## State Management

The app uses **BLoC (Business Logic Component)** pattern via flutter_bloc:

- **BudgetBloc**: Manages budget CRUD operations
- **NavigationBloc**: Handles period/budget navigation
- **CategoryBloc**: Manages categories
- **ProjectionBloc**: Handles financial projections
- **SettingsBloc**: App configuration state

## Database Schema

### Main Tables

- **budgets**: Budget periods and metadata
- **income_entries**: Income transactions
- **expense_entries**: Expense transactions
- **categories**: Income and expense categories
- **recurring_transactions**: Recurring transaction definitions
- **budget_goals**: Category budget limits
- **invoices**: Business invoices (business tools)
- **clients**: Business clients (business tools)
- **company_profiles**: Business company profiles

### Database Version

Current schema version: 16

Migrations are handled in `LocalDatabase._onUpgrade()` following constitution requirements.

## Theme

The app uses **Material Design 3** with custom theming:

- Light and dark mode support
- Custom color scheme for income (green), expenses (red), balance (blue)
- Accessible color combinations

## Security

- **flutter_secure_storage**: Sensitive data encryption
- **local_auth**: Biometric authentication (fingerprint, Face ID)
- **App Lock**: PIN/biometric app protection

## Offline-First Architecture

All data is stored locally on the device using SQLite. No cloud sync is implemented, ensuring user privacy and offline functionality.

### Backup Strategy

- Export to local file system (CSV, PDF, Excel)
- Full database backup and restore
- Share functionality via system share sheet
