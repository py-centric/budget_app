# Quickstart: Budget Management Reset Options

## Overview

This document describes how to test the budget delete, clear all, and factory reset functionality.

## Prerequisites

- Flutter SDK 3.x installed
- Budget App project set up
- Test device or emulator

## Testing Instructions

### 1. Delete Budget from Home Page

**Steps:**
1. Open the Budget App
2. Navigate to the home page (budget list)
3. Tap the delete option on a budget item (three-dot menu or swipe action)
4. Verify confirmation dialog appears
5. Tap "Delete" to confirm
6. Verify budget is removed from the list

**Verification:**
- Budget should no longer appear in the list
- If it was the active budget, another budget should become active

### 2. Clear All Budgets from Sidebar

**Steps:**
1. Open the sidebar navigation
2. Find "Clear All Budgets" option
3. Tap "Clear All Budgets"
4. Verify warning dialog appears
5. Tap "Clear All" to confirm
6. Verify all budgets are removed

**Verification:**
- Budget list should be empty
- App should show empty state

### 3. Factory Reset from Settings

**Steps:**
1. Navigate to Settings screen
2. Find "Factory Reset" option
3. Tap "Factory Reset"
4. Verify warning dialog explains what will be deleted
5. Type confirmation text when prompted
6. Confirm the reset
7. Verify app returns to initial state

**Verification:**
- All budgets should be deleted
- All transactions should be deleted
- All categories should be deleted
- User preferences (theme, currency, etc.) should be reset
- App should show onboarding or empty state

## Edge Case Testing

### Delete Last Budget
- Delete the only remaining budget
- Verify empty state is shown

### Clear with No Budgets
- Try "Clear All Budgets" when no budgets exist
- Verify appropriate message shown

### Cancel Confirmation
- Initiate any delete action
- Tap "Cancel" instead of confirming
- Verify no changes were made

## Troubleshooting

### Delete not appearing
- Verify budget item has delete option in UI
- Check budget card/widget implementation

### Clear All not in sidebar
- Verify sidebar menu includes the option
- Check sidebar widget implementation

### Factory Reset not in settings
- Verify Settings page has the option
- Check Settings widget implementation
