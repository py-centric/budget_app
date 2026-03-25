# Contributing

## Overview

Thank you for your interest in contributing to Budget App!

## Development Setup

### Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Clone and Setup

```bash
git clone <repository-url>
cd budget_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

## Project Structure

The app uses Clean Architecture with features organized in:

```
lib/
├── core/           # Shared utilities, themes, constants
├── features/       # Feature modules
│   ├── budget/
│   ├── transactions/
│   ├── categories/
│   └── ...
├── shared/         # Shared widgets and utilities
└── main.dart       # App entry point
```

## Coding Standards

- Follow Dart/Flutter conventions
- Use flutter_bloc for state management
- Write unit tests for business logic
- Run flutter analyze before submitting

## Pull Requests

1. Create a feature branch
2. Make your changes
3. Add tests if applicable
4. Ensure flutter analyze passes
5. Submit a pull request

## Issues

Report bugs and feature requests via GitHub Issues.

## License

This project is open source under the MIT license.
