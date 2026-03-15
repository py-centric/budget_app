# Quickstart: Global Currency Selection

## 1. Setup
1. Launch the app on a fresh emulator or clear app data.
2. Verify that the initial currency is set to USD (or matches your system locale if implemented).

## 2. Change Currency
1. Navigate to the **Settings** page (via navigation drawer or menu).
2. Tap on the **Currency** selection dropdown.
3. Select **Euro (EUR)**.
4. Verify the dropdown updates to show "Euro (EUR)".

## 3. Global Verification
1. Return to the **Home** page.
2. Verify all balance cards now show the **€** symbol.
3. Check the transaction lists (Income/Expenses) and verify they use **€**.
4. Navigate to the **Projections** page and verify the chart and table use **€**.

## 4. Persistence Check
1. Close the app completely (kill the process).
2. Relaunch the app.
3. Verify that the currency remains **Euro (EUR)** across all screens.

## 5. UI Layout Integrity
1. Select a currency with a longer symbol or code (e.g., "zł" or "CAD").
2. Check the Home page summary card and headers.
3. Ensure no text overflows or awkward wrapping occurs.
