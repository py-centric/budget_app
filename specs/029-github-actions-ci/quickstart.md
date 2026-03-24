# Quickstart: GitHub Actions CI/CD Pipeline

## Overview

This document describes how to set up and use the automated CI/CD workflows for the Budget App.

## Prerequisites

- GitHub repository with push access
- GitHub Actions enabled (enabled by default on public repos, may need enabling for private repos)

## Setup

### 1. First-Time Configuration

The workflow files are located at:
- `.github/workflows/ci.yml` - Runs tests on main branch pushes
- `.github/workflows/release.yml` - Builds APK on release branch pushes

No additional setup is required - workflows are automatically discovered by GitHub Actions when present in `.github/workflows/`.

### 2. Verify Workflows

After merging this feature:
1. Navigate to repository's **Actions** tab
2. You should see "Flutter CI" and "Flutter Release Build" workflows listed
3. Workflows are trigger-based and will run on next appropriate push

## Usage

### Running Tests (Main Branch)

Tests run automatically on:
- Every push to `main` branch
- Every pull request targeting `main`

To manually trigger:
1. Go to **Actions** tab
2. Select "Flutter CI" workflow
3. Click **Run workflow** → select branch → click **Run workflow**

### Building APK (Release Branches)

APK builds run automatically on:
- Every push to `release/*` branches
- Every push to `hotfix/*` branches

To create a release build:
```bash
git checkout -b release/v1.0.0
git push origin release/v1.0.0
```

The APK will be available in the Actions run artifacts after completion.

### Downloading Artifacts

1. Go to **Actions** tab
2. Select the completed workflow run
3. Under **Artifacts**, click the APK artifact to download

## Troubleshooting

### Workflow Not Running
- Check that branch name matches pattern (`main`, `release/*`, `hotfix/*`)
- Verify workflow files are in `.github/workflows/`
- Check repository Settings → Actions → General

### Build Failures
- Check the workflow run logs for error messages
- Common issues:
  - Flutter SDK version unavailable
  - Dependency resolution failures
  - Test failures

### Artifacts Not Available
- Ensure workflow completed successfully (green checkmark)
- Artifacts are retained for 90 days by default

## Maintenance

### Updating Flutter Version

To update the Flutter SDK version used in workflows:

1. Open `.github/workflows/ci.yml` or `.github/workflows/release.yml`
2. Find the `flutter-version` input
3. Update to desired version (e.g., `3.24.0`)
4. Commit and push changes

### Adding New Test Types

To add additional test commands:

1. Open `.github/workflows/ci.yml`
2. Add new `run:` commands in the `test:` step
3. Ensure commands are separated by `&&` for proper error handling

## Security Considerations

- Workflows run in isolated GitHub-hosted runners
- No secrets are exposed in workflow logs
- Artifact downloads require GitHub authentication
