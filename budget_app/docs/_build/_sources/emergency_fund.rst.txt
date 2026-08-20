Emergency Fund
==============

Overview
--------

The Emergency Fund module calculates and tracks your financial safety cushion based on monthly essential expenses and user-defined protection horizons.

Features
--------

Fund Sizing
~~~~~~~~~~~

Input your monthly living expenses to evaluate:

- **3-Month Fund**: Basic emergency coverage (minimum safety net).
- **6-Month Fund**: Standard financial recommendation.
- **12-Month Fund**: Comprehensive safety net for freelancers and entrepreneurs.

Input Parameters
~~~~~~~~~~~~~~~~

- Monthly essential expenditures
- Current liquid savings allocated to emergency fund
- Target coverage duration (in months)

Goal Tracking
~~~~~~~~~~~~~

- Set customized or formula-recommended savings targets.
- Real-time progress percentage and visual gauges.
- Calculated months of runway based on current cash reserves.

Calculation Formulas
--------------------

.. code-block:: text

   Target Fund Amount = Monthly Expenses * Target Months
   Progress Percentage = (Current Savings / Target Fund Amount) * 100%
   Runway Months = Current Savings / Monthly Expenses

Related Features
----------------

- :doc:`budget_management`
- :doc:`projections`
- :doc:`financial_tools`
