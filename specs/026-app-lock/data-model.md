# Data Model: App Lock

## Settings Entity

### AppLockSettings
| Field | Type | Description |
| :--- | :--- | :--- |
| `isEnabled` | `bool` | Whether app lock is active |
| `authMethod` | `Enum` | `pin` or `biometrics` |
| `lastBackgroundTime` | `DateTime?` | Timestamp when app went to background |

## State Transitions

### Lock Flow
```
App Launch -> Check isEnabled?
  -> No: Show HomePage
  -> Yes: Show LockScreen
  
Background -> Check elapsed time
  -> < 5 min: Resume
  -> >= 5 min: Show LockScreen
```

### Authentication Flow
```
LockScreen -> PIN Entry or Biometric
  -> Success: Set isLocked = false, Navigate to Home
  -> Failure: Show error, allow retry (max 5)
  -> 5 failures: Lock out for 30 seconds
```

## Persistence

- PIN: Stored encrypted in flutter_secure_storage (key: `app_lock_pin`)
- Settings: Stored in existing UserSettings via SharedPreferences (key: 'app_lock_enabled', 'app_lock_auth_method')