Loans Management
================

Overview
--------

The loans management module enables tracking money lent to others (assets/receivables) and money borrowed (liabilities/debts), with payment schedules, interest calculations, and historical records.

Use Case Flow Diagram
---------------------

.. code-block:: text

    +-----------------------------------------------------------------------+
    |                     LOAN & DEBT MANAGEMENT FLOW                       |
    +-----------------------------------------------------------------------+
                                        |
                                        v
                            [ Create Loan Account ]
                                        |
                 Select Type: (LENT to person / BORROWED from person)
                                        |
                 Set Principal, Interest Rate, Term & Due Date
                                        |
                                        v
                    [ Calculate Amortization & Monthly Payment ]
                                        |
                                        v
                    Status: [ ACTIVE LOAN (Remaining Balance) ]
                                        |
                                        v
                           { Record Loan Payment Event }
                                        |
           +----------------------------+----------------------------+
           | (Partial Payment)                                       | (Full Settlement)
           v                                                         v
    Deduct Amount from Balance                            Status: [ PAID OFF ]
           |                                                         |
           v                                                         v
    Update Payment History Log                            Close Account & Record Completion

Features
--------

Loan Types
~~~~~~~~~~

- **Lent**: Money you loaned to someone (Receivable asset).
- **Borrowed**: Money you owe to an entity or individual (Payable liability).

Creating a Loan
~~~~~~~~~~~~~~~

1. Navigate to the Loans section.
2. Tap "Add Loan".
3. Select loan classification (Lent / Borrowed).
4. Enter key parameters:
   - Counterparty name (person or organization)
   - Principal amount
   - Annual interest rate (optional)
   - Start date and due date
   - Notes and agreements

Payment Tracking
~~~~~~~~~~~~~~~~

- **Partial Payments**: Record installments and automatically compute updated balance.
- **Payment History**: Detailed timestamped log of all repayments.
- **Status Badges**: Visual indicators for Active, Paid Off, and Overdue loans.

Data Models
-----------

.. code-block:: text

   Loan {
     id: String
     type: LoanType (lent / borrowed)
     personName: String
     totalAmount: double
     remainingAmount: double
     interestRate: double?
     startDate: DateTime
     dueDate: DateTime?
     isPaidOff: bool
     notes: String?
     createdAt: DateTime
   }

   LoanPayment {
     id: String
     loanId: String
     amount: double
     date: DateTime
     note: String?
   }

Related Features
----------------

- :doc:`transactions`
- :doc:`financial_tools`
