# Implementation Plan: [FEATURE]

**Branch**: `026-app-lock` | **Date**: 2026-03-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/026-app-lock/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

**Primary Requirement**: Implement app lock feature allowing users to secure the app using PIN or biometrics, with toggle in settings.

**Technical Approach**: Use local_auth package for biometrics and flutter_secure_storage for PIN. Add lock screen as app entry point when enabled. Track lock state in SettingsBloc.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart 3.x (Flutter 3.x)  
**Primary Dependencies**: flutter_secure_storage (existing), local_auth (new - biometrics)  
**Storage**: flutter_secure_storage for PIN, existing settings storage for preferences  
**Testing**: flutter_test, mocktail (existing)  
**Target Platform**: iOS 15+, Android (latest stable)  
**Project Type**: Mobile-app (Flutter)  
**Performance Goals**: Auth screen appears within 500ms  
**Constraints**: Offline-only, no cloud sync, biometric availability varies by device  
**Scale/Scope**: Single user, local authentication only

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Use Flutter/Dart | ✅ PASS | Feature uses Dart with Flutter framework per constitution |
| Offline-First Architecture | ✅ PASS | All data stored locally; no external APIs |
| SQLite Storage | ✅ PASS | Not needed - using flutter_secure_storage |
| Clean Architecture | ✅ PASS | Feature follows Clean Architecture pattern |
| License Compliance | ✅ PASS | local_auth is BSD-3-Clause, flutter_secure_storage is MIT |

**Constitution Alignment**: All gates pass. No violations detected.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── app.dart
├── core/
│   └── constants/
├── features/
│   ├── settings/
│   │   └── presentation/pages/    # App Lock toggle here
│   └── app_lock/                   # NEW feature
│       ├── presentation/
│       │   ├── bloc/
│       │   ├── pages/
│       │   └── widgets/
│       └── domain/
│           └── services/
└── shared/
    └── widgets/

test/
├── unit/
└── widget/
```

**Structure Decision**: New feature module `app_lock/` with lock screen and BLoC. Settings toggle in existing settings feature.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
