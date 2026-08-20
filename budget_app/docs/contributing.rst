Contributing Guidelines
=======================

Overview
--------

Thank you for contributing to Budget App! We welcome contributions, bug reports, and enhancements adhering to our architectural and testing standards.

Development Setup
-----------------

Prerequisites
~~~~~~~~~~~~~

- Flutter SDK 3.x (pinned stable version)
- Dart SDK 3.x
- Android SDK or Xcode (for mobile targets)
- Linux build libraries (for desktop targets)

Setup Steps
~~~~~~~~~~~

.. code-block:: bash

   git clone https://github.com/py-centric/budget_app.git
   cd budget_app/budget_app
   flutter pub get

Standard Task Commands
----------------------

The repository includes a cross-platform task runner configured via ``Taskfile.yml``:

.. code-block:: bash

   # Run automated test suite
   task test

   # Run static analysis and linting
   task lint
   task analyze

   # Build Sphinx documentation portal
   task docs

   # Launch local development instance
   task dev

Testing Standards
-----------------

- **Red-Green-Refactor**: Write unit and widget tests before implementing new business features.
- **Coverage Target**: Minimum 90% coverage for core domain logic, repositories, and use cases; minimum 80% coverage for UI widgets.
- **Zero Static Analysis Warnings**: ``flutter analyze`` must report 0 errors, 0 warnings, and 0 infos.
- **Strict Typography Standard**: Zero non-ASCII em-dashes or en-dashes anywhere in code, tests, or documentation. Always use standard hyphens (-), colons (:), or parentheses ().

Submitting Changes
------------------

1. Create a descriptive feature branch from ``main``.
2. Ensure all tests pass with ``task test``.
3. Ensure static analysis is clean with ``task analyze``.
4. Verify Sphinx docs compile cleanly with ``task docs``.
5. Submit a concise Pull Request for review.
