# Research: Financial Calculators

## Dec-01: Mathematical Formulas
- **Decision**: Use standard financial formulas for all calculations.
- **Rationale**: Ensures accuracy and consistency with industry standards.
- **Details**:
    - **Loan Payment (Amortization)**: $P = L[c(1 + c)^n] / [(1 + c)^n - 1]$ (Compound) or $P = (L + (L \times r \times t)) / n$ (Simple).
    - **Compound Interest (Savings)**: $A = P(1 + r/n)^{nt} + PMT \times \{ [(1 + r/n)^{nt} - 1] / (r/n) \} \times (1 + r/n)$
    - **Simple vs Compound Rate Conversion**: Effective Annual Rate (EAR) for compound is $(1 + r/n)^n - 1$. Simple interest rate is linear. Conversion will allow users to compare the two directly.
    - **Rate Solver**: Uses the Newton-Raphson method or Binary Search to solve for `r` in the amortization formula given `P`, `n`, and `M` (Monthly Payment).

## Dec-02: Persistence Layer
- **Decision**: Create a `saved_calculations` table in SQLite.
- **Rationale**: While `HydratedBloc` is good for UI state (scratchpad), SQLite is better for structured, explicit "Saved" or "Pinned" data that users might want to keep long-term and manage (delete, list, rename).
- **Alternatives considered**: Storing only in `HydratedBloc`. Rejected because it makes it harder to manage multiple saved scenarios of the same type.

## Dec-03: Visualization Approach
- **Decision**: Use `fl_chart` for a stacked area chart in the Loan calculator (showing Total Paid = Principal + Interest) and a line chart for the Savings projection.
- **Rationale**: Visualizing the cost of debt (interest vs principal) is high-value for users.
- **Alternatives considered**: Table only. Rejected because charts provide a much faster intuitive understanding of the data.

## Dec-04: Real-time vs Manual Calculation
- **Decision**: Real-time calculation for all inputs.
- **Rationale**: Provides immediate feedback, which is expected in modern mobile apps. The formulas are computationally inexpensive.
- **Edge Case handling**: Debounce input changes to avoid UI jitter if needed, though for 3 inputs it shouldn't be necessary.
