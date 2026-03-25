# Recurring Transactions

## Overview

Recurring transactions automate the entry of regular income and expenses, saving time and ensuring you never miss recurring payments.

## Features

### Creating Recurring Transactions

1. From the transactions screen, tap the recurring button
2. Select transaction type (income/expense)
3. Enter the amount
4. Choose category
5. Set recurrence pattern:
   - **Daily**: Every day
   - **Weekly**: Specific day of week
   - **Monthly**: Specific day of month
   - **Yearly**: Specific date
6. Set start date and optional end date
7. Add optional note

### Recurrence Patterns

- **Monthly**: Most common for rent, subscriptions, salaries
- **Weekly**: Useful for weekly gym membership, weekly allowances
- **Daily**: Rare, but available for daily expenses
- **Yearly**: For annual insurance, subscriptions

### Managing Recurring Transactions

#### Viewing All Recurring

Access all recurring transactions from the dedicated section in the app.

#### Editing Recurring Transactions

Modify any recurring transaction to change amount, category, or dates.

#### Stopping Recurring

- **Pause**: Temporarily stop without deleting
- **Delete**: Permanently remove the recurring rule

#### Manual Entry Override

When a recurring transaction is created, you can:
- Skip one occurrence
- Add a one-time adjustment for a specific instance

## Transaction Data Model

```
RecurringTransaction {
  id: String
  amount: double
  categoryId: String
  type: TransactionType (income/expense)
  recurrence: RecurrenceType (daily/weekly/monthly/yearly)
  dayOfWeek: int? (1-7 for weekly)
  dayOfMonth: int? (1-31 for monthly)
  month: int? (1-12 for yearly)
  startDate: DateTime
  endDate: DateTime?
  note: String?
  isActive: bool
  createdAt: DateTime
}
```

## Related Features

- [Transactions](transactions.rst)
- [Categories](categories.rst)
- [Projections](projections.rst)
