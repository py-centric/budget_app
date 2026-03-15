# Quickstart: Potential Transactions Tracking

## 1. Setup & Migration
1. Ensure `AppConstants.databaseVersion` is incremented to **8**.
2. Run the application to trigger the SQLite schema update (`is_potential` columns added).

## 2. Verify "Potential" Creation
1. Open the "Add Income" or "Add Expense" dialog.
2. Toggle the new "Potential" switch.
3. Save the entry.
4. Verify the current "Actual Balance" in the summary does **NOT** include this transaction.

## 3. Verify Visualization
1. Navigate to the Projections page.
2. Check the line chart.
3. Ensure there is a secondary dashed line (Potential) that diverges from the main line (Actual) on the date of the potential transaction.
4. Verify the projection table shows both "Actual Balance" and "Potential Balance" columns.

## 4. Verify Confirmation
1. In the projection table, select a date with a potential item.
2. Open the potential item's detail/action menu.
3. Select "Confirm".
4. Verify:
    - The "Actual Balance" summary updates.
    - The projection lines converge on that date.
    - The transaction is now listed in the main transaction history.

## 5. Verify Deletion
1. Add a new potential transaction.
2. Delete it.
3. Verify the "Potential" line on the chart returns to match the "Actual" line.
