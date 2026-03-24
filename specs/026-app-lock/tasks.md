# Tasks: App Lock Feature (026-app-lock)

**Feature**: App Lock with PIN/Biometrics  
**Branch**: `026-app-lock` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Summary

- **Total Tasks**: 21
- **User Stories**: 3
- **Parallelizable Tasks**: 7
- **MVP Scope**: User Story 1 (Enable App Lock)

## Dependencies Graph

```
Phase 1 (Setup)
    │
    ▼
Phase 2 (Foundational)
    │
    ├─────────────────────┐
    ▼                     ▼
Phase 3 [US1]        Phase 4 [US2]
Enable App Lock     Disable App Lock
    │                     │
    └──────────┬──────────┘
               ▼
          Phase 5 [US3]
    Authenticate to Access App
               │
               ▼
          Phase 6 (Polish)
```

## Parallel Execution Examples

- T001, T002 (Setup) can run in parallel with T003, T004 (Foundational)
- T006, T007 (PIN setup UI) can run parallel to T008 (biometric check)
- T011, T012 (lock screen UI) can run in parallel

---

## Phase 1: Setup

- [X] T001 Add local_auth dependency to pubspec.yaml with flutter_secure_storage
- [X] T002 Configure iOS Info.plist for Face ID/Touch ID usage description

---

## Phase 2: Foundational

- [X] T003 Create AppLockSettings entity in budget_app/lib/features/app_lock/domain/entities/app_lock_settings.dart
- [X] T004 Create AuthService interface in budget_app/lib/features/app_lock/domain/services/auth_service.dart
- [X] T005 Implement AppLockRepository in budget_app/lib/features/app_lock/data/repositories/app_lock_repository_impl.dart
- [X] T006 [P] Create PIN input widget in budget_app/lib/features/app_lock/presentation/widgets/pin_input_widget.dart
- [X] T007 [P] Create biometric button widget in budget_app/lib/features/app_lock/presentation/widgets/biometric_button_widget.dart
- [X] T007b [P] Add biometric availability check in AuthService for conditional UI

---

## Phase 3: User Story 1 - Enable App Lock [US1]

**Goal**: Allow users to enable app lock with PIN or biometrics

**Independent Test**: Go to Settings, toggle on "App Lock", select PIN or Biometrics. Verify the app requires authentication on next launch.

- [X] T008 [P] [US1] Implement AppLockBloc in budget_app/lib/features/app_lock/presentation/bloc/app_lock_bloc.dart with events/states
- [X] T009 [US1] Add App Lock toggle to Settings page in budget_app/lib/features/settings/presentation/pages/settings_page.dart
- [X] T010 [US1] Create lock setup dialog in budget_app/lib/features/app_lock/presentation/widgets/lock_setup_dialog.dart
- [X] T011 [P] [US1] Create lock screen page in budget_app/lib/features/app_lock/presentation/pages/lock_screen_page.dart

---

## Phase 4: User Story 2 - Disable App Lock [US2]

**Goal**: Allow users to disable app locking

**Independent Test**: Go to Settings, toggle off "App Lock". Verify the app opens without authentication on next launch.

- [X] T012 [US2] Add PIN verification to disable lock flow in AppLockBloc
- [X] T013 [US2] Update Settings toggle to trigger disable with verification in budget_app/lib/features/settings/presentation/pages/settings_page.dart

---

## Phase 5: User Story 3 - Authenticate to Access App [US3]

**Goal**: Authenticate users when accessing the app

**Independent Test**: With lock enabled, open the app. Authenticate using configured method. Verify access is granted.

- [X] T014 [US3] Implement authentication flow in LockScreenPage in budget_app/lib/features/app_lock/presentation/pages/lock_screen_page.dart
- [X] T015 [US3] Add PIN validation logic in AppLockBloc
- [X] T016 [US3] Add biometric authentication logic in AppLockBloc
- [X] T017 [US3] Add failed attempt tracking and lockout in AppLockBloc
- [X] T017b [US3] Add AppLifecycleListener for background detection in budget_app/lib/features/app_lock/presentation/bloc/app_lock_bloc.dart
- [X] T017c [US3] Implement PIN reset flow in AppLockBloc with re-authentication requirement

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T018 Integrate lock screen as app entry point in budget_app/lib/main.dart

---

## Implementation Strategy

### MVP (User Story 1 Only)

1. Setup: T001, T002
2. Foundational: T003, T004, T005, T006, T007
3. Enable App Lock: T008, T009, T010, T011
4. Entry point: T018

### Incremental Delivery

- **Increment 1**: Setup + Foundational + T008, T011 (basic lock screen)
- **Increment 2**: T009, T010 (enable from settings)
- **Increment 3**: T012, T013 (disable flow)
- **Increment 4**: T014-T017 (full authentication)
- **Increment 5**: T018 (full integration)
