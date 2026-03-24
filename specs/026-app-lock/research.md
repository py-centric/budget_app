# Research: App Lock Feature

## Decisions & Rationale

### 1. Biometric Authentication
- **Decision**: Use `local_auth` package for biometric authentication
- **Rationale**: Flutter's standard package for biometric auth, supports fingerprint and face on iOS/Android. MIT licensed.
- **Alternatives Considered**: `flutter_local_auth` (deprecated), custom platform channels (overkill)

### 2. PIN Storage
- **Decision**: Use `flutter_secure_storage` for PIN
- **Rationale**: Already in project dependencies per AGENTS.md. Provides encrypted storage on both platforms.
- **Alternatives Considered**: Hive with encryption (more complex), simple hash (not secure enough for financial app)

### 3. Lock Screen Implementation
- **Decision**: Wrap app in lock check at startup, show lock screen as first widget
- **Rationale**: Ensures no content is shown before authentication. Use AppLifecycleListener for background timeout.
- **Alternatives Considered**: Route guard (more complex), Navigator.push overlay (potential for bypassing)

### 4. Background Timeout
- **Decision**: 5 minute timeout as per spec FR-009
- **Rationale**: Industry standard for financial apps. Balance between security and convenience.
- **Implementation**: Use WidgetsBindingObserver to detect when app goes to background, track timestamp.

## Best Practices Applied

1. **Security First**: PIN never stored in plain text, always encrypted
2. **Fail-Safe**: Multiple failed attempts result in temporary lockout
3. **Graceful Degradation**: Biometrics unavailable fallback to PIN-only
4. **User Experience**: Lock screen appears immediately, authentication within 2 seconds

## Technology Stack Summary

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| Biometrics | local_auth | ^2.x |
| Secure Storage | flutter_secure_storage | ^9.x (existing) |
| State Management | flutter_bloc | ^8.x (existing) |