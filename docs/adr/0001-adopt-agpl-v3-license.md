# ADR-0001: Adopt the GNU Affero General Public License v3.0 (AGPL-3.0) for the Entire Codebase

- **Status**: Accepted
- **Date**: 2026-08-24
- **Deciders**: vhutali (sole maintainer, 174479435+vhutalit@users.noreply.github.com)

## Context

budget_app is an offline-first personal finance application written in Dart/Flutter. It persists all user data locally via sqflite and local device storage (no hosted backend ships to users), follows a Clean Architecture layout (`lib/core`, `lib/features`, `lib/shared`), keeps per-feature specifications under `specs/`, and builds three release targets (editions: Personal, Business, Combined) governed by feature flags.

Two facts force a licensing decision now:

1. **No prior license existed.** The repository previously contained no LICENSE file. Under default copyright law, source code published without a license is "all rights reserved": technically nobody other than the author may copy, modify, or redistribute it. This ambiguity blocks any meaningful collaboration, contribution, or redistribution, and it leaves well-intentioned forks legally infringing by default. Before opening the project to wider collaboration, clear terms must exist.
2. **Clean intellectual-property provenance.** Following a history cleanup, all 203 commits are attributed to a single author (vhutali, GitHub noreply email 174479435+vhutalit@users.noreply.github.com). There are no third-party contributors whose consent would be needed for this decision or for any future relicense. The window in which licensing can be chosen unilaterally is now; it closes the moment outside contributions land.

The full canonical text of the GNU Affero General Public License v3.0 has been placed (currently uncommitted) at the repository root as `LICENSE`.

## Decision

License the entire budget_app codebase under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

- The verbatim AGPL-3.0 text lives at the repository root as `LICENSE`.
- Coverage includes all first-party Dart source under `lib/` and `test/`, build and utility scripts, CI workflow definitions, and the accompanying feature specifications under `specs/`.
- Distribution of the application (including the edition variants: Personal, Business, Combined) carries the AGPL-3.0 obligations described below.

### Rationale

AGPL-3.0 is the strongest widely used copyleft license, and critically it extends the share-alike obligation to software offered over a network (Section 13). For a finance application, this matters: without the network clause, a third party could take the code, add cloud sync or a hosted advisory service, and sell access without ever releasing their modifications. AGPL-3.0 closes that loophole: anyone operating a modified version as a network service must offer its complete corresponding source to the users of that service. Combined with the app's offline-first, local-data philosophy (users own their data and deserve to inspect the tooling that handles it), strong copyleft is the natural fit.

## Licenses and Compatibility

The AGPL-3.0 obligation attaches to this project's original code, not to everything it links against. Current compatibility posture:

- **Flutter framework**: licensed under BSD-3-Clause (a permissive license). Linking against it imposes no copyleft obligations on the framework and is fully compatible with distributing our code under AGPL-3.0.
- **pub.dev packages**: the typical ecosystem package is MIT, BSD, or Apache-2.0, all of which are compatible with AGPL-3.0 (Apache-2.0 explicitly so under GPLv3 Section 7 patent/termination terms). **Verification step required**: before each tagged release, audit `pubspec.yaml` / `pubspec.lock` and confirm every direct and transitive dependency carries a license compatible with AGPL-3.0. In particular, GPL-2.0-only dependencies are NOT compatible with AGPL-3.0 and must be avoided or replaced.
- **First-party assets** (icons, fonts, bundled data) should carry the same terms or a permissive notice where third-party origin requires attribution.

## Consequences

### Positive

- **Network-services protection**: modified versions offered as SaaS/hosted services must release source (Section 13), preventing closed-source hosted forks of a finance app.
- **Derivative works stay open**: any redistribution or modification must ship under AGPL-3.0 with source available.
- **Clear terms enable collaboration**: contributors and redistributors know exactly where they stand; the current de facto "all rights reserved" ambiguity is removed.
- **User trust**: for an app handling personal financial data, guaranteeing source availability aligns with the offline-first privacy posture.

### Negative

- **Copyleft friction**: organizations with blanket bans on strong copyleft (some enterprises) cannot adopt or embed the app; adoption may be narrower than under MIT/Apache.
- **Dependency discipline**: every new package addition now carries a license-compatibility check (see Licenses and Compatibility above).
- **Commercial-strategy constraint**: any future proprietary or paid edition (beyond the current Personal/Business/Combined flag targets) cannot be distributed closed-source while it derives from this codebase. Two lawful paths remain: respect the copyleft, or dual-license. Because all 203 commits have single-author provenance, the sole maintainer retains the right to relicense or offer commercial exceptions at will; however, this option erodes once external contributions are accepted unless a contributor agreement (CLA with license grant, plus DCO) is adopted alongside them.
- **Compliance effort**: distributors must satisfy Section 6 (source delivery) and Section 13 (network source offer) obligations, which is more demanding than permissive-license compliance.
