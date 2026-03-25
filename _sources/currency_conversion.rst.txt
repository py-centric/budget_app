# Currency Conversion

## Overview

The currency conversion feature allows you to work with budgets in different currencies, useful for travel planning and international expenses.

## Supported Currencies

The app supports 20 currencies:

- USD - US Dollar
- EUR - Euro
- GBP - British Pound
- JPY - Japanese Yen
- AUD - Australian Dollar
- CAD - Canadian Dollar
- CHF - Swiss Franc
- CNY - Chinese Yuan
- INR - Indian Rupee
- MXN - Mexican Peso
- BRL - Brazilian Real
- KRW - South Korean Won
- SGD - Singapore Dollar
- HKD - Hong Kong Dollar
- NOK - Norwegian Krone
- SEK - Swedish Krona
- DKK - Danish Krone
- NZD - New Zealand Dollar
- ZAR - South African Rand
- THB - Thai Baht

## Features

### Currency Selection

When creating a budget, you can select:
- **Base Currency**: Your primary currency for the budget
- **Target Currency**: Currency for conversion (optional)

### Exchange Rate

- Manual entry of exchange rate
- Rate is stored with the budget for consistency

### Converted Amount

When target currency is set:
- Original amount in base currency
- Converted amount in target currency
- Exchange rate used

## Budget Currency Fields

```
Budget {
  currencyCode: String (ISO 4217)
  targetCurrencyCode: String?
  exchangeRate: double?
  convertedAmount: double?
}
```

## Related Features

- [Travel Budget Planner](travel_budget_planner.rst)
- [Budget Management](budget_management.rst)
