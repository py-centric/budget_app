Getting Started
===============

Overview
--------

Budget App is an offline-first personal and business finance management platform built with Flutter and Dart. This guide walks you through setting up your development environment, installing dependencies, configuring your first budget, and navigating the core features.

Installation
------------

Prerequisites
~~~~~~~~~~~~~

- Flutter SDK 3.x or later (pinned stable version)
- Dart SDK 3.x or later
- Android SDK, Xcode, or Linux/macOS/Windows desktop build dependencies

Clone the Repository
~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   git clone https://github.com/py-centric/budget_app.git
   cd budget_app/budget_app

Install Dependencies
~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   flutter pub get

Run the App
~~~~~~~~~~~

.. code-block:: bash

   # Run with default edition
   flutter run

   # Or using Taskfile
   task dev

First-Time Setup
----------------

1. Set Your Preferred Currency
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Navigate to **Settings** to select your base currency. Over 20 global currencies (USD, EUR, GBP, JPY, CAD, AUD, ZAR, etc.) are supported with automated symbol and decimal formatting.

2. Create Your First Budget
~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Launch the app: a default budget is automatically generated for the active calendar month.
2. To create or navigate to other budget periods, open the sidebar navigation drawer.
3. Select any target month and year to instantly initialize and switch active periods.

3. Configure Accounts & Categories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Accounts**: Add your primary bank, credit card, and savings accounts in the **Accounts** screen to enable account filtering on your transactions.
- **Categories**: Organize your spending using built-in categories (Food, Transport, Housing, Utilities) or create custom categories with custom icons and color schemes.

Basic Workflow
--------------

Adding Income
~~~~~~~~~~~~~

1. Tap the **Add Income** floating action button at the bottom of the Home screen.
2. Enter the amount, select an Income category, specify date, and optionally assign an account.
3. Save to immediately update your balance and income summaries.

Adding Expenses
~~~~~~~~~~~~~~~

1. Tap the **Add Expense** floating action button at the bottom of the Home screen.
2. Enter the expense amount, choose the corresponding category, add a description, and select the payment account.
3. Submit to record the transaction and recalculate remaining category limits.

Transaction Filtering & Search
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the top **Filter Bar** to:

- Search transaction descriptions in real-time.
- Sort by amount, date, or category.
- Filter by transaction amount thresholds.
- Filter by specific bank or credit card accounts.
- Reset all active filters using the **Clear** action pinned to the far right.

Advanced Capabilities
---------------------

- **Recurring Transactions**: Automate regular monthly bills and salary deposits with customizable intervals.
- **Financial Projections**: Forecast cash flow across 3, 6, and 12-month time horizons.
- **Multi-Bank Accounts**: Monitor total net worth across multiple liquid and debt accounts.
- **Export & Backup**: Export financial records to CSV, Excel, or PDF, and generate encrypted SQLite database backups.
- **App Lock**: Protect your financial data with PIN or biometric (Touch ID / Face ID) authentication.
