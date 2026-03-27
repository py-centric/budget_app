# Quickstart: Currency Search Feature

## Overview

Replace static currency dropdowns with a searchable dialog selector.

## Implementation Steps

### 1. Create CurrencySelector Widget

Create `lib/shared/widgets/currency_selector.dart`:
- StatefulWidget with TextField for search
- ListView filtered by search query
- Search matches both currency code and currency name
- Case-insensitive filtering
- "No results" state when empty

### 2. Update Existing Currency Fields

Replace DropdownButtonFormField with CurrencySelector in:
- `lib/features/accounts/presentation/widgets/account_form.dart`
- `lib/features/budget/presentation/widgets/currency_conversion_dialog.dart`
- Any other currency fields

### 3. Currency Data

Use existing 20-currency list:
- USD, EUR, GBP, JPY, AUD, CAD, CHF, CNY, INR, MXN, BRL, KRW, SGD, HKD, NOK, SEK, DKK, NZD, ZAR, THB

## Running

```bash
cd budget_app
flutter analyze
flutter run
```

## Key Files

- New: `lib/shared/widgets/currency_selector.dart`
- Update: `lib/features/accounts/presentation/widgets/account_form.dart`
- Update: `lib/features/budget/presentation/widgets/currency_conversion_dialog.dart`
