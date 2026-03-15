<!--
Sync Impact Report:

- Version change: 2.1.0 → 2.2.0 (MINOR bump)

- Modified principles:
    - 3. Local Storage Requirements: Added "Migrations" subsection.

- Added sections:
    - None

- Removed sections:
    - None

- Templates requiring updates:
    - .specify/templates/tasks-template.md: ✅ already includes migration setup sample
    - .specify/templates/plan-template.md: ✅ no changes needed
    - .specify/templates/spec-template.md: ✅ no changes needed

- Follow-up TODOs:
    - None
-->
# Budget App Constitution

## 1. Tech Stack
- **Framework:** Flutter 3.x (latest stable)
- **Language:** Dart 3.x
- **State Management:** flutter_bloc (BLoC pattern) or Riverpod
- **Local Database:** SQLite (via sqflite) or Hive for offline storage
- **Architecture:** Clean Architecture (UI → Domain → Data layers)
- **Testing:** flutter_test, mocktail

## 2. Offline-First Architecture
- **Requirement:** The app MUST function fully without internet connectivity
- **Implication:** All data MUST be stored locally on device
- **Sync:** No cloud sync feature - data remains on device only
- **Backup:** Export/import functionality via local file system

## 3. Local Storage Requirements
- **Primary Storage:** SQLite database using sqflite package
- **Data Models:**
  - Budget categories
  - Transactions (income/expenses)
  - Recurring entries
  - User preferences
- **Security:** Use flutter_secure_storage for sensitive data if needed
- **No External APIs:** All features must work offline
- **Migrations:** Database schema changes MUST include a migration path in `LocalDatabase._onUpgrade` and increment `AppConstants.databaseVersion`. All new tables or columns MUST be reflected in both `_onCreate` (for new installs) and `_onUpgrade` (for existing users).

## 4. UX & Accessibility Principles
- **Priority:** UX is the primary design consideration
- **Accessibility:** MUST comply with WCAG 2.1 AA standards
- **Platform Guidelines:** Follow Material Design 3 guidelines
- **Responsive:** Support various screen sizes and orientations
- **Performance:** UI interactions must be smooth (60fps target)
- **Onboarding:** Simple, intuitive onboarding flow

## 5. Visual Design
- **Design System:** Material Design 3 with custom theming
- **Color Palette:** Accessible color combinations with dark mode support
- **Typography:** Clear hierarchy, readable fonts
- **Animations:** Purposeful, smooth transitions
- **Icons:** Consistent icon set (Material Icons)

## 6. License Compliance
- **Requirement:** All dependencies MUST use OSI-approved licenses
- **Allowed Licenses:** MIT, Apache 2.0, BSD, MPL, etc.
- **Forbidden:** GPLv3 (传染性) - prefer permissive licenses
- **Verification:** Review all pub.dev dependencies for license compliance

## 7. Development Workflow

### Project Structure
- **Layout:** Feature-first Clean Architecture
  - `lib/features/<feature>/` (domain, data, presentation layers)
  - `lib/core/` (shared utilities, themes, constants)
  - `lib/shared/` (shared widgets, repositories)

### Dependency Management
- **Manifest:** All dependencies in `pubspec.yaml`
- **Tools:** Use `flutter pub` for package management
- **Dev Dependencies:** Clearly separate from runtime dependencies

### Version Control
- **Branching:** Feature branch workflow (main + feature/* branches)
- **Commits:** Conventional Commits format
- **Pre-commit:** flutter analyze, flutter format

### Implementation Verification
- **Runtime Check:** At the end of every feature implementation, the developer MUST run `flutter run` to ensure the project compiles and executes correctly on at least one target platform.

## 8. Testing Standards
- **Unit Tests:** Test business logic in domain layer
- **Widget Tests:** Test UI components in isolation
- **Integration Tests:** Test full user flows
- **Coverage:** Aim for 80%+ code coverage on business logic

## 9. Code Quality
- **Linting:** flutter_lints (strict mode)
- **Formatting:** flutter format on save
- **Documentation:** Dart doc comments for public APIs
- **Error Handling:** Graceful error states with user feedback

## Governance

This Constitution establishes the foundational principles and rules for the `Budget App` project. All project participants are expected to adhere to these guidelines.

**Amendment Procedure:**
- Proposed amendments must be submitted as a pull request to the project's main repository.
- Amendments require approval from a majority of designated project maintainers.
- Significant amendments (MAJOR version bumps) should include a migration plan if they introduce backward-incompatible changes.

**Versioning Policy:**
- The Constitution follows Semantic Versioning (MAJOR.MINOR.PATCH).
  - MAJOR: Backward incompatible governance/principle removals or redefinitions.
  - MINOR: New principle/section added or materially expanded guidance.
  - PATCH: Clarifications, wording, typo fixes, non-semantic refinements.

**Compliance Review:**
- All pull requests will be reviewed for compliance with the Constitution's principles and standards.
- Regular audits may be conducted to ensure ongoing adherence to project governance.
- License compliance checks must be performed on all dependency additions.

**Version**: 2.2.0 | **Ratified**: 2026-03-10 | **Last Amended**: 2026-03-13
