# Transactions

## Overview

Transactions are the core data in Budget App - every income and expense entry. The app provides comprehensive transaction tracking with categories, dates, and descriptions.

## Transaction Types

### Income

Money received or expected to be received:

- Salary
- Freelance work
- Investments
- Gifts
- Other income sources

### Expenses

Money spent on goods and services:

- Food & Dining
- Transportation
- Utilities
- Entertainment
- Shopping
- Health
- Education
- And custom categories...

## Adding Transactions

### Via Home Screen

1. Tap the **+** button on the Income or Expense card
2. Enter the amount
3. Select a category
4. Add description (optional)
5. Set the date (defaults to today)
6. Tap **Add Income** or **Add Expense**

### Via Recurring Transactions

Set up automatic recurring transactions:

1. Menu → Recurring Transactions
2. Add new recurring transaction
3. Configure frequency (daily, weekly, bi-weekly, monthly, etc.)
4. The app automatically creates entries based on the schedule

## Transaction Features

### Category Assignment

Every transaction must have a category. Categories can be:

- Pre-defined defaults
- User-created custom categories
- Modified at any time

### Date Tracking

- Individual transactions have specific dates
- Recurring transactions are auto-generated on scheduled dates
- Can view transactions by period (month/year)

### Descriptions

Optional free-form text descriptions for additional context.

### Potential Transactions

"Planned" or "Potential" transactions can be:

- Created in advance
- Confirmed later when actually incurred
- Useful for budgeting future expenses

## Transaction Data Model

```dart
IncomeEntry {
  id: String
  budgetId: String
  amount: double
  description: String?
  date: DateTime
  categoryId: String
  isPotential: bool
}

ExpenseEntry {
  id: String
  budgetId: String
  amount: double
  description: String?
  date: DateTime
  categoryId: String
  isPotential: bool
}
```

## Related Features

- [Budget Management](budget_management.rst)
- [Categories](categories.rst)
- [Recurring Transactions](recurring_transactions.rst)
