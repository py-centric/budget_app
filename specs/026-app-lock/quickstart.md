# Quickstart: App Lock

## Developer Setup

### 1. Add Dependency
- Add `local_auth` to `pubspec.yaml` (for biometrics)
- flutter_secure_storage already in dependencies

### 2. iOS Configuration (Info.plist)
- Add `NSFaceIDUsageDescription` for biometric permission

### 3. Android Configuration
- Add `USE_BIOMETRIC` and `USE_FINGERPRINT` permissions

## Verification Steps

### 1. Enable App Lock with PIN
- Go to Settings
- Toggle "App Lock" to ON
- Select "PIN" option
- Enter 4-6 digit PIN
- Confirm PIN
- Close and reopen app
- Verify lock screen appears

### 2. Enable App Lock with Biometrics
- Go to Settings
- Toggle "App Lock" to ON
- Select "Biometrics" option
- Authenticate with fingerprint/face
- Close and reopen app
- Verify lock screen appears with biometric prompt

### 3. Disable App Lock
- Go to Settings
- Toggle "App Lock" to OFF
- Authenticate to confirm
- Verify app opens without lock

### 4. Background Timeout
- Enable app lock
- Put app in background
- Wait 5 minutes
- Return to app
- Verify lock screen appears

## Critical Flows

- `App Launch` -> Check lock enabled -> Show lock screen or home
- `Settings Toggle` -> Enable/Disable lock -> Requires authentication
- `Authentication` -> PIN or Biometric -> Success/failure handling
- `Background Resume` -> Check timeout -> Show lock if needed