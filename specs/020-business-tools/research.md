# Research: Business Tools

## Decision: PDF Library Choice
**Decision**: Use the `pdf` and `printing` packages.
**Rationale**: These are the most widely used, community-supported, and feature-rich packages for PDF generation in Flutter. They support multi-platform printing, sharing, and robust widget-to-pdf layout capabilities. `syncfusion_flutter_pdf` is powerful but requires a paid license or community license with attribution, which adds complexity.
**Alternatives considered**: 
- `syncfusion_flutter_pdf` (Good but licensing concerns).
- `html_to_pdf` (Less flexible for complex MD3 layouts).

## Decision: Logo and Asset Storage
**Decision**: Store logo images in the local file system (via `path_provider`) and save the absolute path in the SQLite database.
**Rationale**: Storing large images as BLOBs in SQLite can significantly degrade database performance and increase file size. Using the file system is more performant and aligns with standard mobile/desktop practices.
**Alternatives considered**:
- SQLite BLOBs (Simple but poor performance for large assets).
- Base64 in DB (Massive overhead, not recommended for assets).

## Decision: VAT Rate Management
**Decision**: Implement a "Default VAT Rate" at the Company Profile level, but allow overrides at the line-item level.
**Rationale**: This provides the best balance of speed (auto-filling from profile) and flexibility (handling items with different tax categories like reduced rates or exemptions).
**Alternatives considered**:
- Global only (Too rigid).
- Item only (Too tedious for users).

## Decision: Payment Tracking Logic
**Decision**: Use a separate `invoice_payments` table with a foreign key to `invoices`.
**Rationale**: This allows for multiple partial payments over time while maintaining a clear audit trail. Balance due will be a computed value (Grand Total - Sum of Payments).
**Alternatives considered**:
- Single `paid_amount` column (Simpler but doesn't support multiple payment dates/methods).
