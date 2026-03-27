# Research: Multiple Bank/Savings Accounts

## Overview

This document captures technical decisions for implementing multi-bank account support in the Budget App.

## Technical Stack Decisions

### State Management
- **Decision**: flutter_bloc
- **Rationale**: Constitution requires flutter_bloc. Existing codebase uses flutter_bloc in other features (budget, loans, export). Maintains consistency.
- **Alternatives considered**: Riverpod (also allowed by constitution, but flutter_bloc used throughout)

### Database
- **Decision**: SQLite via sqflite
- **Rationale**: Constitution mandates sqflite for local storage. Existing database schema uses sqflite.
- **Alternatives considered**: Hive (allowed by constitution, but would add migration complexity)

### Architecture
- **Decision**: Clean Architecture with feature-first structure
- **Rationale**: Constitution requires Clean Architecture. Existing features follow this pattern.
- **Alternatives considered**: Simple MVC (insufficient for complexity)

## Implementation Pattern

### Database Schema
- **Account table**: id, name, type, balance, currency, createdAt, updatedAt
- **Transfer table**: id, fromAccountId, toAccountId, amount, date, note, createdAt
- Both tables will be added to LocalDatabase with proper migration

### Entity Structure
- Account: name, type (checking/savings/investment/other), balance, currency
- Transfer: fromAccount, toAccount, amount, date, note

### UI Pattern
- Accounts list page (home)
- Add/Edit account form
- Transfer form (accessible from accounts list)
- Follow existing Material Design 3 patterns

## No Clarifications Needed

All technical decisions were determinable from:
1. Project Constitution (Flutter, flutter_bloc, sqflite required)
2. Existing codebase patterns
3. Feature specification requirements

No external research required.
