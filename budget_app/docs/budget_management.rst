# Budget Management

## Overview

Budget management is the core feature of the app, allowing users to create, manage, and track multiple budgets across different time periods.

## Features

### Create Budget

When you first open the app, a default budget is created for the current month. You can create additional budgets by:

1. Opening the sidebar menu
2. Selecting a different month/year
3. A new budget is automatically created

### Budget Periods

- **Monthly Budgets**: Each budget covers a specific month and year
- **Multiple Budgets**: Support for multiple budgets per period
- **Navigation**: Easy switching between periods via sidebar

### Budget Actions

From the home page app bar:

- **Copy Budget**: Duplicate an existing budget to another period
- **Convert Currency**: Convert budget to a different currency
- **Delete Budget**: Remove a budget (with confirmation)

### Budget Fields

Each budget contains:

- **Name**: User-defined budget name
- **Period**: Month and year
- **Currency**: Budget currency (for travel budgets)
- **Target Currency**: For currency conversion
- **Exchange Rate**: User-specified exchange rate
- **Converted Amount**: Calculated converted amount
- **Transactions**: Associated income and expense entries

## Budget Data Model

```
Budget {
  id: String
  name: String
  periodMonth: int (1-12)
  periodYear: int
  isActive: bool
  currencyCode: String (ISO 4217)
  targetCurrencyCode: String?
  exchangeRate: double?
  convertedAmount: double?
  createdAt: DateTime
}
```

## Budget Selection

The budget selector in the home page allows quick switching between:
- Different periods
- Different budgets within the same period

## Related Features

- [Currency Conversion](currency_conversion.rst)
- [Transactions](transactions.rst)
- [Categories](categories.rst)
