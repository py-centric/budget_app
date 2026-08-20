Transactions
============

Overview
--------

Transactions are the core data in Budget App: every income and expense entry. The app provides comprehensive transaction tracking with categories, dates, descriptions, optional financial account associations, and multi-account filtering.

Use Case Flow Diagram
---------------------

.. code-block:: text

    +-----------------------------------------------------------------------+
    |                        TRANSACTION LIFECYCLE FLOW                     |
    +-----------------------------------------------------------------------+
                                        |
                                        v
                          [ User Action on Dashboard ]
                                        |
           +----------------------------+----------------------------+
           |                                                         |
           v                                                         v
    [ Manual Entry Creation ]                              [ Potential Transaction ]
           |                                                         |
           v                                                         v
    Select Type (Income / Expense)                         Set Planned Amount & Date
           |                                                         |
           v                                                         v
    Choose Category & Amount                               Mark as Potential (What-if)
           |                                                         |
           v                                                         v
    Optional Financial Account                             [ User Confirms Actual ]
           |                                                         |
           v                                                         |
    Assign Date & Description                                        |
           |                                                         |
           +----------------------------+----------------------------+
                                        |
                                        v
                            [ Save to SQLite Database ]
                                        |
                                        v
                          [ Recalculate Period Totals ]
                                        |
                                        v
                          [ Re-render Financial Summary ]

Transaction Types
-----------------

Income
~~~~~~

Money received or expected to be received:

- Salary
- Freelance work
- Investments
- Gifts
- Other income sources

Expenses
~~~~~~~~

Money spent on goods and services:

- Food & Dining
- Transportation
- Utilities
- Entertainment
- Shopping
- Health
- Education
- And custom categories...

Adding Transactions
-------------------

Via Home Screen
~~~~~~~~~~~~~~~

1. Tap the **+** button on the Income or Expense card
2. Enter the amount
3. Select a category
4. Optionally choose an Account (Checking, Savings, Credit Card, etc.) or None (Unassigned)
5. Add description (optional)
6. Set the date (defaults to today)
7. Tap **Add Income** or **Add Expense**

Via Recurring Transactions
~~~~~~~~~~~~~~~~~~~~~~~~~~

Set up automatic recurring transactions:

1. Menu -> Recurring Transactions
2. Add new recurring transaction
3. Configure frequency (daily, weekly, bi-weekly, monthly, etc.)
4. The app automatically creates entries based on the schedule

Transaction Features
--------------------

Optional Account Assignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Transactions can optionally be linked to a registered bank, cash, or credit account:

- Account dropdown selector in Income and Expense creation/edit dialogs
- Seamless default to "None (Unassigned)" for quick entry
- Visual account badges on transaction list items

Multi-Account Filtering
~~~~~~~~~~~~~~~~~~~~~~~

The FilterBar includes a dedicated **Account** filter button:

- Opens the multi-select Account filter modal
- Filter by any arbitrary combination of accounts
- Toggle "Unassigned" transactions to isolate unallocated spending
- Real-time recalculation of income and expense list headers

Category Assignment
~~~~~~~~~~~~~~~~~~~

Every transaction must have a category. Categories can be:

- Pre-defined defaults
- User-created custom categories
- Modified at any time

Date Tracking
~~~~~~~~~~~~~

- Individual transactions have specific dates
- Recurring transactions are auto-generated on scheduled dates
- Can view transactions by period (month/year)

Descriptions
~~~~~~~~~~~~

Optional free-form text descriptions for additional context.

Potential Transactions
~~~~~~~~~~~~~~~~~~~~~~

"Planned" or "Potential" transactions can be:

- Created in advance
- Confirmed later when actually incurred
- Useful for budgeting future expenses

Transaction Data Model
----------------------

.. code-block:: dart

    class IncomeEntry {
      final String id;
      final String budgetId;
      final double amount;
      final String? description;
      final DateTime date;
      final int periodMonth;
      final int periodYear;
      final String categoryId;
      final String? categoryName;
      final String? categoryIcon;
      final String? accountId;
      final String? accountName;
      final bool isPotential;
    }

    class ExpenseEntry {
      final String id;
      final String budgetId;
      final double amount;
      final String categoryId;
      final String? description;
      final DateTime date;
      final int periodMonth;
      final int periodYear;
      final String? categoryName;
      final String? categoryIcon;
      final String? accountId;
      final String? accountName;
      final bool isPotential;
    }

Related Features
----------------

- `Budget Management <budget_management.rst>`_
- `Categories <categories.rst>`_
- `Recurring Transactions <recurring_transactions.rst>`_
