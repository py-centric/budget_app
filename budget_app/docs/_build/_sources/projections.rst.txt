Projections
===========

Overview
--------

Projections help you forecast your financial future based on recurring transactions, planned expenses, and historical trends.

Features
--------

Income Projection
~~~~~~~~~~~~~~~~~

Forecast expected earnings for:

- Current month
- Next 3 months
- Next 6 months
- Next 12 months

Expense Projection
~~~~~~~~~~~~~~~~~~

Track anticipated expenses across:

- Individual categories
- Total monthly obligations
- Daily burn rate

Balance Projection
~~~~~~~~~~~~~~~~~~

Forecast account balances based on:

- Current cash position
- Projected income streams
- Projected fixed and variable expenses

Projection Horizons
~~~~~~~~~~~~~~~~~~~

- **Monthly View**: Detailed current month breakdown
- **Quarterly View**: 3-month forecast outlook
- **Yearly View**: 12-month trajectory

How Projections Work
--------------------

1. System identifies all active recurring transactions.
2. Projects future occurrences based on interval rules and dates.
3. Incorporates potential (what-if) transactions if enabled.
4. Aggregates totals by category and period.
5. Renders trend lines and balance forecasts in real-time.

Projection Formula
~~~~~~~~~~~~~~~~~~

.. code-block:: text

   Projected Income = Sum of recurring and confirmed income
   Projected Expense = Sum of recurring and confirmed expenses
   Projected Balance = Current Balance + Projected Income - Projected Expense

Visualizations
--------------

- **Interactive Line Charts**: Balance trajectories powered by `fl_chart`.
- **Bar Charts**: Income versus expense comparisons.
- **Summary Cards**: Net projected cash flow and emergency runway metrics.

Related Features
----------------

- :doc:`recurring_transactions`
- :doc:`budget_management`
- :doc:`emergency_fund`
