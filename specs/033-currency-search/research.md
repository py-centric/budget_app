# Research: Currency Search

## Overview

This is a simple UI enhancement - no complex technical decisions needed.

## Technical Approach

**Widget Pattern**: Dialog-based searchable dropdown
- User taps currency field → dialog opens with search box
- User types → list filters in real-time
- User selects → dialog closes, value saved

**Alternatives Considered**:
1. Autocomplete TextField - More complex to integrate with forms
2. Searchable Dropdown package - Adds external dependency
3. Custom Dialog (chosen) - No new dependencies, full control

## Decision

Use a simple AlertDialog with TextField + ListView for filtering. This matches existing Material Design patterns in the app and requires no new packages.

## No Clarifications Needed

All aspects are determinable from the spec and existing codebase patterns.
