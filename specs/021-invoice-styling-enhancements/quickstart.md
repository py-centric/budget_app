# Quickstart: Invoice Styling & Branding Enhancements

## Developer Setup

### 1. New Dependencies
No new external packages needed; already using `pdf`, `printing`, `sqflite`.

### 2. SQLite Migration
Locate `lib/core/data/local_database.dart` (or similar) and add a migration for `AppConstants.databaseVersion`.

```dart
// Example Migration Snippet
await db.execute('ALTER TABLE profiles ADD COLUMN bank_name TEXT');
// Repeat for other columns...
```

### 3. Entity Updates
Update `CompanyProfile` and `Invoice` in `lib/features/business_tools/domain/entities/`.

## Verification Steps

### 1. Branding Setup
- Navigate to **Business Profile**.
- Upload a **Logo**.
- Enter **Banking Details**.
- Select a **Brand Color** and **Font**.
- Click **Save**.

### 2. Invoice Creation
- Navigate to **Invoice Creation**.
- Fill in client details and items with **VAT rates**.
- Confirm that **Banking Details** default from the profile but can be edited.
- Click **Create**.
- Verify that the **PDF Preview** opens immediately.

### 3. PDF Verification
- Check for **Logo** in header.
- Check for **VAT Summary Matrix** at the bottom (Net, VAT, Gross per rate).
- Check for **Banking Details** in the footer.
- Verify **Brand Color** accents and **Font Choice**.

## Critical Flows
- `Profile Setup` -> `Invoice Creation` -> `Instant Preview` -> `PDF Styling Validation`.
