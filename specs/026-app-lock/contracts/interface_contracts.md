# Contracts: App Lock

## 1. Authentication Service Interface

### Methods
```dart
Future<bool> authenticateWithBiometrics();
Future<bool> authenticateWithPIN(String pin);
Future<void> savePIN(String pin);
Future<bool> verifyPIN(String pin);
Future<bool> isBiometricsAvailable();
```

## 2. AppLockBloc Interface

### Events
- `CheckLockStatus`: Check if lock is enabled on app start
- `EnableLock(AuthMethod method, String? pin)`: Enable app lock
- `DisableLock`: Disable app lock with verification
- `Authenticate`: Process authentication attempt
- `AppBackgrounded`: Record background timestamp
- `AppResumed`: Check if re-authentication needed

### State
- `AppLockInitial`: Initial state
- `AppLockLocked`: Show lock screen
- `AppLockUnlocked`: App unlocked, show home
- `AppLockDisabled`: Lock is disabled, no authentication needed

## 3. Settings Integration

### Settings Toggle
- Toggle in SettingsPage calls `EnableLock` or `DisableLock` events
- PIN setup dialog shown when enabling with PIN
- Biometric permission requested when enabling with biometrics

## 4. Lock Screen Widget Interface

### Input
- AuthMethod: Current auth method (PIN/biometrics)
- FailedAttempts: Number of failed attempts

### Output
- On success: Navigate to home, emit `AppLockUnlocked` state
- On failure: Show error message, allow retry

### Callbacks
- `onBiometricAuth`: Trigger biometric authentication
- `onPINSubmit(String pin)`: Process PIN entry