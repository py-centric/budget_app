# Feature Specification: Financial Calculators

**Feature Branch**: `018-financial-calculators`  
**Created**: 2026-03-13  
**Status**: Draft  
**Input**: User description: "add a new screen to help calculate networth, and a screen for calculating savings, loan repayment, ammortisation, and other financial calculations"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Net Worth Calculator (Priority: P1)

As a user, I want to list my assets and liabilities in a dedicated screen so that I can see my total net worth.

**Why this priority**: High value for long-term financial planning. Net worth is a key metric for many users.

**Independent Test**: User navigates to "Net Worth" tool, enters $10,000 in assets and $2,000 in liabilities. The tool displays a net worth of $8,000.

**Acceptance Scenarios**:

1. **Given** I am on the Net Worth screen, **When** I add multiple asset categories (e.g., Cash, Property) and liability categories (e.g., Loans), **Then** the total net worth must update in real-time.
2. **Given** I have entered data, **When** I leave the screen and return, **Then** my entries should only be restored if I chose to "Save" or "Pin" the calculation previously.

---

### User Story 2 - Loan Repayment & Amortization (Priority: P1)

As a user, I want to calculate my monthly loan repayments and see an amortization schedule so that I can understand the cost of debt over time.

**Why this priority**: Crucial for users managing mortgages or personal loans.

**Independent Test**: User enters $200,000 loan at 5% for 30 years. The tool calculates the monthly payment and shows a table of principal vs interest over time.

**Acceptance Scenarios**:

1. **Given** loan parameters (Principal, Interest Rate, Term), **When** I calculate, **Then** I see the monthly payment amount.
2. **Given** a calculation result, **When** I view the "Schedule", **Then** I see a monthly breakdown of interest, principal, and remaining balance.

---

### User Story 3 - Savings & Compound Interest (Priority: P2)

As a user, I want to project my future savings based on compound interest so that I can plan for retirement or large purchases.

**Why this priority**: Motivates saving and helps with long-term goals.

**Independent Test**: User enters $1,000 initial, $100 monthly, 7% return for 10 years. The tool shows the total future value.

**Acceptance Scenarios**:

1. **Given** initial deposit, monthly contribution, and interest rate, **When** I calculate, **Then** I see the projected total after the specified duration.

---

### User Story 4 - Rate Converter & Interest Solver (Priority: P2)

As a user, I want to convert interest rates between simple and compound models, and solve for the effective interest rate given my loan terms and monthly payment, so that I can verify the true cost of loans offered by banks.

**Independent Test**: User enters $10,000 principal, 12 months, and $900 monthly payment. The tool solves for the effective interest rate (~7.34% total interest).

---

### Edge Cases

- **Zero/Negative Interest**: Calculators must handle 0% interest and prevent negative terms or principal amounts.
- **Large Numbers**: UI must not overflow when calculating multi-million dollar scenarios.
- **Currency Consistency**: All calculators must use the user's selected global currency (from feature 016).
- **Solver Convergence**: The interest rate solver must handle edge cases where no solution exists or multiple solutions exist (using iterative approximation).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a "Financial Tools" menu or hub screen.
- **FR-002**: Net Worth tool MUST allow entry of multiple asset and liability line items.
- **FR-003**: Loan tool MUST support both Simple Interest and Compound Interest (Amortized) models.
- **FR-004**: Savings tool MUST support compound interest calculations.
- **FR-005**: All calculators MUST update results in real-time as the user modifies inputs.
- **FR-006**: System MUST use the global currency symbol for all inputs/outputs.
- **FR-007**: Amortization tool MUST display a list or chart showing the repayment schedule.
- **FR-008**: System MUST allow users to explicitly "Save" or "Pin" a specific calculation.
- **FR-009**: System MUST provide a "Rate Solver" tool to calculate interest rates based on Principal, Term, and Repayment.
- **FR-010**: System MUST provide a "Rate Converter" to translate between Simple and Compound effective annual rates.

### Key Entities *(include if feature involves data)*

- **FinancialToolEntry**: Represents an input field in a calculator (label, value).
- **AmortizationPoint**: Represents a single month in a loan schedule (interest, principal, balance).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% mathematical accuracy verified against industry-standard financial formulas.
- **SC-002**: Navigation from home page to any calculator hub takes under 2 taps.
- **SC-003**: UI rendering of amortization schedule (up to 360 months) occurs in under 300ms.
- **SC-004**: Calculators are fully usable offline.
