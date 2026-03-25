# Budget App Documentation

## Overview

Budget App is a comprehensive personal finance management application built with Flutter. It helps users track income, expenses, budgets, and financial goals across multiple time periods. The app is designed with an offline-first architecture, ensuring all data stays on the user's device.

## Key Features

### Budget Management
- Create and manage monthly budgets
- Support for multiple budgets per period
- Budget duplication for recurring periods
- Budget deletion with confirmation

### Transaction Tracking
- Income and expense tracking
- Category-based organization
- Recurring transactions
- Potential/Planned transactions

### Financial Projections
- Future balance forecasting
- Income vs expense analysis
- Visual charts and tables

### Multi-Currency Support
- 20+ supported currencies
- Currency conversion between currencies
- Travel budget planning with different currencies
- User-configurable default currency

### Business Tools
- Invoice management
- Client tracking
- Company profiles
- Professional invoice generation

### Financial Calculators
- Loan calculator
- Net worth calculator
- Emergency fund calculator
- Compound interest projections

### Data Management
- Export to CSV, PDF, Excel
- Database backup and restore
- Share functionality

### Security
- App lock with biometrics
- PIN protection
- Secure data storage

## Supported Platforms

- Android
- iOS
- Web
- Desktop (Linux, macOS, Windows)

## Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: flutter_bloc (BLoC pattern)
- **Local Database**: SQLite via sqflite
- **Architecture**: Clean Architecture (UI → Domain → Data layers)

## Getting Started

See the [Getting Started Guide](getting_started.rst) for installation and setup instructions.

## Documentation Structure

The documentation is organized into several sections:

1. **Introduction** - Overview, getting started, architecture
2. **Core Features** - Budget management, transactions, categories
3. **Advanced Features** - Currency, loans, business tools
4. **Utilities** - Export, backup, settings
5. **Development** - Contributing, changelog

## License

This project is licensed under the MIT License.
