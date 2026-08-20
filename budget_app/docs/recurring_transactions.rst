Recurring Transactions
======================

Overview
--------

Recurring transactions automate the entry of regular income and expenses, saving time and ensuring scheduled bills, subscriptions, and salaries are reflected in future projections.

Features
--------

Creating Recurring Transactions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. From the transactions screen or form, toggle the recurring switch.
2. Select transaction type (income or expense).
3. Enter the amount.
4. Choose category and optional account.
5. Set recurrence pattern:
   - **Daily**: Fixed daily interval
   - **Weekly**: Specific weekly interval
   - **Monthly**: Specific monthly schedule
   - **Yearly**: Annual billing cycles
6. Set start date and optional end date.
7. Add optional description.

Recurrence Patterns
~~~~~~~~~~~~~~~~~~~

- **Monthly**: Standard for rent, utilities, streaming subscriptions, and salaries.
- **Weekly**: For weekly allowances, gym dues, and transit passes.
- **Daily**: Recurring daily allocations.
- **Yearly**: Annual domain registrations, insurance premiums, and memberships.

Managing Recurring Transactions
-------------------------------

Viewing All Recurring
~~~~~~~~~~~~~~~~~~~~~

Access all active recurring transactions from the dedicated menu section.

Editing Recurring Rules
~~~~~~~~~~~~~~~~~~~~~~~

Modify any recurring transaction to change amount, category, or interval dates.

Pausing and Stopping
~~~~~~~~~~~~~~~~~~~~

- **Pause**: Temporarily pause occurrences without deleting history.
- **Delete**: Remove the recurring rule permanently.

One-Time Overrides
~~~~~~~~~~~~~~~~~~

Individual occurrences can be overridden or skipped for a specific month without altering the master recurring schedule.

Data Model
----------

.. code-block:: text

   RecurringTransaction {
     id: String
     amount: double
     categoryId: String
     type: String (INCOME / EXPENSE)
     interval: int
     unit: RecurrenceUnit (day / week / month / year)
     startDate: DateTime
     endDate: DateTime?
     description: String?
     createdAt: DateTime
   }

Related Features
----------------

- :doc:`transactions`
- :doc:`categories`
- :doc:`projections`
