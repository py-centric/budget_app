Currency Conversion
===================

Overview
--------

The currency conversion engine allows users to manage budgets in diverse global currencies with custom exchange rates, essential for international travel planning and cross-border expense management.

Supported Currencies
--------------------

The app supports 20 major world currencies with dedicated formatting:

- USD: US Dollar ($)
- EUR: Euro (€)
- GBP: British Pound (£)
- JPY: Japanese Yen (¥)
- AUD: Australian Dollar (A$)
- CAD: Canadian Dollar (C$)
- CHF: Swiss Franc (CHF)
- CNY: Chinese Yuan (¥)
- INR: Indian Rupee (₹)
- MXN: Mexican Peso (Mex$)
- BRL: Brazilian Real (R$)
- KRW: South Korean Won (₩)
- SGD: Singapore Dollar (S$)
- HKD: Hong Kong Dollar (HK$)
- NOK: Norwegian Krone (kr)
- SEK: Swedish Krona (kr)
- DKK: Danish Krone (kr)
- NZD: New Zealand Dollar (NZ$)
- ZAR: South African Rand (R)
- THB: Thai Baht (฿)

Features
--------

Currency Selection
~~~~~~~~~~~~~~~~~~

- **Base Currency**: Global default currency configured in settings.
- **Target Currency**: Dedicated travel or conversion currency per budget.

Exchange Rate Engine
~~~~~~~~~~~~~~~~~~~~

- Manual offline rate entry ensuring predictable calculations without internet dependency.
- Pinned exchange rate stored with each budget for historical precision.

Converted Summary
~~~~~~~~~~~~~~~~~

- Displays dual amounts (base currency and target converted currency).
- Automatically converts category allocations during budget duplication.

Data Model
----------

.. code-block:: text

   Budget {
     currencyCode: String (ISO 4217)
     targetCurrencyCode: String?
     exchangeRate: double?
     convertedAmount: double?
   }

Related Features
----------------

- :doc:`travel_budget_planner`
- :doc:`budget_management`
