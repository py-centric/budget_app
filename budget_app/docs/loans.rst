Loans Management
================

Overview
--------

The loans feature helps you track money lent to others and money borrowed, with payment tracking and reminders.

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

## Features

### Loan Types

- **Lent**: Money you loaned to someone
- **Borrowed**: Money you owe to someone

### Creating a Loan

1. Navigate to Loans section
2. Tap "Add Loan"
3. Select type (Lent/Borrowed)
4. Enter details:
   - Person/Organization name
   - Total amount
   - Interest rate (optional)
   - Start date
   - Due date (optional)
   - Notes

### Loan Tracking

#### Payment Tracking

- Record partial payments
- Track payment history
- View remaining balance

#### Loan Status

- **Active**: Currently outstanding
- **Paid Off**: Fully repaid
- **Overdue**: Past due date

### Loan Details

For each loan:
- Total amount and remaining balance
- Interest rate and total interest
- Payment history
- Notes and documents

## Loan Data Model

```
Loan {
  id: String
  type: LoanType (lent/borrowed)
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
```

## Related Features

- [Transactions](transactions.rst)
- [Financial Tools](financial_tools.rst)
