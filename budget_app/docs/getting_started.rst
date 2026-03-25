# Getting Started

## Installation

### Prerequisites

- Flutter SDK 3.x or later
- Dart SDK 3.x or later
- A device or emulator running Android, iOS, Web, or Desktop

### Clone the Repository

```bash
git clone https://github.com/anomalyco/budget_app.git
cd budget_app/budget_app
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

## First Time Setup

### 1. Set Your Currency

Navigate to Settings to configure your default currency. This currency will be used throughout the app for displaying amounts.

### 2. Create Your First Budget

1. Open the app - a default budget is created for the current month
2. To create additional budgets, tap the menu icon (three lines) in the top-left
3. Select a different month/year to create a new budget period

### 3. Add Categories

The app comes with default categories (Food, Transport, Utilities, etc.). You can:

- Add new categories in Settings → Manage Categories
- Edit existing categories
- Delete unused categories
- Assign icons to categories

## Basic Workflow

### Adding Income

1. Tap the **+** button on the Income card
2. Enter amount, select category, add description (optional)
3. Set date (defaults to today)
4. Tap **Add Income**

### Adding Expenses

1. Tap the **+** button on the Expense card
2. Enter amount, select category, add description (optional)
3. Set date (defaults to today)
4. Tap **Add Expense**

### Viewing Summary

The home screen displays:
- Total Income for the period
- Total Expenses for the period
- Current Balance (Income - Expenses)
- Budget goal progress (if set)

## Navigation

- **Sidebar Menu**: Access categories, projections, recurring transactions, settings
- **Budget Selector**: Switch between different budget periods
- **Top App Bar**: Access copy budget, currency conversion, and delete functions

## Advanced Features

### Recurring Transactions

Set up automatic recurring income or expenses:

1. Open menu → Recurring Transactions
2. Add new recurring transaction
3. Configure: amount, category, frequency (daily, weekly, monthly, etc.)
4. Set start and end dates

### Projections

View future financial projections:

1. Open menu → Projections
2. See projected balances for upcoming months
3. Based on recurring transactions and current trends

### Export Data

Export your financial data:

1. Open Settings → Export/Backup
2. Choose format: CSV, PDF, or Excel
3. Share or save the file

### Backup & Restore

1. Open Settings → Export/Backup
2. Create backup to save database
3. Restore from a previous backup file
