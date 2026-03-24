# Feature Specification: App Lock

**Feature Branch**: `026-app-lock`  
**Created**: 2026-03-24  
**Status**: Draft  
**Input**: User description: "implement an option to lock the app using biometrics or a pin, this must be toggled on and off in the settings"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Enable App Lock (Priority: P1)

As a user, I want to enable app locking so that my financial data is protected from unauthorized access.

**Why this priority**: Core security feature - protects sensitive financial information.

**Independent Test**: Go to Settings, toggle on "App Lock", select PIN or Biometrics. Verify the app requires authentication on next launch.

**Acceptance Scenarios**:

1. **Given** I am in Settings, **When** I toggle "App Lock" to ON, **Then** I am prompted to choose between PIN or Biometrics.
2. **Given** I select PIN, **When** I enter a 4-6 digit PIN, **Then** the lock is enabled and PIN is saved securely.
3. **Given** I select Biometrics, **When** I authenticate with fingerprint/face, **Then** the lock is enabled using biometric authentication.
4. **Given** App Lock is enabled, **When** I close and reopen the app, **Then** I am prompted to authenticate before seeing any content.

---

### User Story 2 - Disable App Lock (Priority: P1)

As a user, I want to disable app locking so that I can access the app without authentication when needed.

**Why this priority**: User may want to remove security for convenience in safe environments.

**Independent Test**: Go to Settings, toggle off "App Lock". Verify the app opens without authentication on next launch.

**Acceptance Scenarios**:

1. **Given** App Lock is enabled with PIN, **When** I toggle "App Lock" to OFF and enter current PIN, **Then** the lock is disabled.
2. **Given** App Lock is enabled with Biometrics, **When** I toggle "App Lock" to OFF and authenticate with biometrics, **Then** the lock is disabled.
3. **Given** App Lock is disabled, **When** I reopen the app, **Then** no authentication is required.

---

### User Story 3 - Authenticate to Access App (Priority: P1)

As a user, I want to authenticate using my chosen method so that I can access my financial data securely.

**Why this priority**: Core authentication flow - must work reliably.

**Independent Test**: With lock enabled, open the app. Authenticate using configured method. Verify access is granted.

**Acceptance Scenarios**:

1. **Given** App Lock uses PIN, **When** I enter correct PIN, **Then** the app unlocks and shows the home screen.
2. **Given** App Lock uses PIN, **When** I enter incorrect PIN, **Then** I see an error message and can try again (max 5 attempts).
3. **Given** App Lock uses Biometrics, **When** I authenticate successfully, **Then** the app unlocks and shows the home screen.
4. **Given** App Lock uses Biometrics, **When** authentication fails, **Then** I see an error and can try again or use PIN as fallback.

---

### Edge Cases

- **Biometrics unavailable**: If device doesn't support biometrics, hide biometric option and show only PIN.
- **Forgot PIN**: Provide option to reset PIN (requires re-authenticating or clearing app data).
- **Multiple failed attempts**: After 5 failed PIN attempts, lock out for 30 seconds before allowing more tries.
- **App in background**: Require re-authentication when app returns from background (after 5 minutes).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an "App Lock" toggle in Settings.
- **FR-002**: System MUST allow users to choose between PIN and Biometrics when enabling lock.
- **FR-003**: System MUST require 4-6 digit PIN and validate format.
- **FR-004**: System MUST use device biometric authentication (fingerprint/face) when available.
- **FR-005**: System MUST authenticate user on app launch when lock is enabled.
- **FR-006**: System MUST authenticate user when returning from background (after timeout).
- **FR-007**: System MUST require current authentication to disable lock.
- **FR-008**: System MUST store PIN securely using flutter_secure_storage.
- **FR-009**: System MUST lock after 5 minutes of inactivity in background.
- **FR-010**: System MUST show lock screen before any app content when locked.

### Key Entities

- **AppLockSettings**: Stores lock preference, authentication method (PIN/Biometrics), enabled state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can enable app lock in under 30 seconds.
- **SC-002**: Authentication succeeds within 2 seconds of valid input.
- **SC-003**: 100% of users can successfully authenticate after 5 attempts (PIN) or 2 attempts (biometrics).
- **SC-004**: App remains locked until valid authentication is provided.

## Assumptions

- Device has biometric capability (fallback to PIN-only if not available).
- User has set up device PIN/biometrics already.
- flutter_secure_storage is available for secure PIN storage.
- Lock screen appears immediately on app launch when enabled.