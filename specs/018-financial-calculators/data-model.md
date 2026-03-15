# Data Model: Financial Calculators

## Entities

### SavedCalculation
Represents a financial calculation snapshot saved by the user.

- `id`: String (UUID)
- `type`: String (e.g., "NET_WORTH", "LOAN", "SAVINGS")
- `name`: String (User-defined name for the snapshot)
- `data`: String (JSON serialized blob of inputs and results)
- `createdAt`: DateTime

### FinancialToolEntry (UI Entity)
Represents a single input line item in a calculator (used for Net Worth assets/liabilities).

- `label`: String
- `value`: Double

### AmortizationPoint (Domain Entity)
Represents a single point in an amortization or savings schedule.

- `month`: Integer
- `principalPaid`: Double (or `contribution` for savings)
- `interestPaid`: Double (or `interestEarned` for savings)
- `remainingBalance`: Double (or `totalValue` for savings)

## Database Schema Updates

### Table: saved_calculations
- `id` TEXT PRIMARY KEY
- `type` TEXT NOT NULL
- `name` TEXT NOT NULL
- `data` TEXT NOT NULL
- `created_at` TEXT NOT NULL

## Logic Rules

### Net Worth Calculation
- `Net Worth = SUM(Assets) - SUM(Liabilities)`

### Loan Calculation (Fixed Rate)
- `Monthly Payment = (Principal * r * (1 + r)^n) / ((1 + r)^n - 1)`
- where `r = annual_rate / 12 / 100` and `n = years * 12`

### Compound Interest Calculation (Monthly Contributions)
- `Future Value = Principal * (1 + r)^n + PMT * (((1 + r)^n - 1) / r)`
- where `r = annual_rate / 12 / 100` and `n = years * 12`
- Note: This assumes contributions are made at the end of each period.
