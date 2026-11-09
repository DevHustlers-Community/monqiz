# Stage 5 Initial Zoom Out Review: Monqiz Mobile App Architecture

**Target File:** `d:\My_Projects\monqiz\docs\designs\monqiz_mobile_architecture.md`  
**Standard Evaluated:** Zoom-Out Standard (`resources/document_standards/zoom-out-standard.md`)  
**Context:** Emergency blood donation mobile client (Flutter) interfacing with .NET 9 Web API backend.

---

### Executive Summary
The architecture document establishes a clear problem definition, well-defined clinical boundaries (mandatory hospital supervision, clinical recovery interval tracking), and accurate alignment with the existing Flutter design system tokens. However, from a high-altitude simplicity and YAGNI standpoint, the design suffers from **premature abstraction** (use-case explosion for trivial CRUD queries), **premature optimization and clinical safety risks** (offline caching of dynamic emergency feed data), and **state fragmentation** (isolated cubits for single-button actions).

---

### Structured Review Findings

#### Finding 1: Premature Abstraction — 1-to-1 Use Case Boilerplate Explosion
* **Severity:** Major
* **Affected Scope:** Section 2 (`Directory Layout by Layer`, lines 135–140) & Section `Detailed Implementation Plan` (`Domain Layer`, lines 322–328).
* **Simplicity Rationale:** The architecture mandates a discrete UseCase class for every single repository method (`GetUrgentRequestsUseCase`, `GetRequestDetailsUseCase`, `GetHospitalsUseCase`, `GetHospitalByIdUseCase`, `LoginUseCase`, `LogoutUseCase`, `GetMyPledgesUseCase`, etc.). In a mobile client connecting to a standard REST API, wrapping every simple repository query in a single-method class that simply forwards `call() => repo.method()` introduces 12+ redundant files, interfaces, and DI bindings with zero added business logic.
* **Simplification Suggestion:** Cubits should consume domain repository contracts directly (`IBloodRequestRepository`, `IHospitalRepository`, `IAuthRepository`). Reserve UseCases strictly for operations that orchestrate multiple sources or enforce core domain business rules (e.g., `CheckDonationEligibilityUseCase` and `PledgeDonationUseCase`).

---

#### Finding 2: Premature Optimization & Clinical Risk — Offline Feed Caching (`FeedLocalCache` / `Hive`)
* **Severity:** Major
* **Affected Scope:** Section 1 (`Data Layer`, line 88), Section 2 (`Local DataSources`, line 145), and Section `Non-Functional Requirements` (`Offline Tolerance`, lines 263–265).
* **Simplicity Rationale:** The proposal introduces `FeedLocalCache` with `Hive/SecureStorage` to cache active blood donation requests locally. Blood requisition is a time-sensitive clinical emergency (often with urgent windows < 3 hours). Displaying stale cached emergency requests when offline presents a severe real-world hazard: a donor might see an expired or already-fulfilled request from hours ago and travel to a hospital in vain. Furthermore, introducing a local database engine like Hive adds unnecessary cache-invalidation, TTL, and synchronization complexity for an initial release.
* **Simplification Suggestion:** Drop `FeedLocalCache` and remove Hive from the data layer. Offline tolerance should be strictly scoped to static, immutable reference data: emergency hotlines (19888) and the accredited hospital directory. These can be served directly from bundled static JSON assets or simple in-memory/shared preferences.

---

#### Finding 3: State Fragmentation & Coordination Overhead — Standalone `PledgeCubit`
* **Severity:** Major
* **Affected Scope:** Section 2 (`cubits/`, lines 154–156), Section 3 (`Cubit State Management Contracts`, lines 186–190), and Section 5 (`Screen Inventory`, lines 220–223).
* **Simplicity Rationale:** Pledging is a single action/mutation performed on a specific emergency request within `RequestDetailsScreen` or directly from `HomeFeedScreen` cards. Separating pledge execution into an independent `PledgeCubit` separate from `RequestDetailsCubit` and `CaseFeedCubit` introduces cross-cubit synchronization hurdles: when a pledge succeeds, updating the parent request's pledged units in `CaseFeedCubit` or `RequestDetailsCubit` requires awkward listeners or multi-bloc coordination.
* **Simplification Suggestion:** Merge the pledge submission flow into the request state flow (either as an action in `RequestDetailsCubit` or a unified `BloodRequestCubit`), removing unnecessary boilerplate and eliminating cross-cubit state drift.

---

#### Finding 4: Architectural Alignment & File Sprawl — Layer-First vs Feature-First Layout
* **Severity:** Nit
* **Affected Scope:** Section 2 (`Directory Layout by Layer`, lines 120–167) & Section `Alternatives Considered` (`Alternative A`, lines 235–240).
* **Simplicity Rationale:** The concept brief (`concepts_brief.md`, line 20) explicitly recommended a "Feature-First layered architecture". The architecture doc rejects Feature-First in favor of technical Layer-First (`lib/domain`, `lib/data`, `lib/presentation`), which forces developers to touch 5+ distant root folders for any single feature change ("shotgun surgery"). Feature-First packaging with internal layers (`features/requests/data`, `domain`, `presentation`) preserves 100% of Clean Architecture decoupling while drastically reducing cognitive load and navigation overhead.

---

#### Finding 5: Dependency Specification Discrepancy
* **Severity:** Nit
* **Affected Scope:** Section `Detailed Implementation Plan -> Configuration & Dependencies` (lines 273–276) vs Section 2 (line 127).
* **Simplicity Rationale:** The architecture tree mentions `PrefsWrapper` and local datasources, but `pubspec.yaml` target dependencies omit `shared_preferences`. If preferences are needed for local app settings, `shared_preferences` should be added; conversely, all references to `Hive` should be removed in accordance with Finding 2.

---

#### Finding 6: Codebase Symbol Naming Inconsistency (`MonqizTheme` vs `AppTheme`)
* **Severity:** Nit
* **Affected Scope:** Section 1 (`Core Layer`, line 99) and Section `Detailed Implementation Plan` (line 379).
* **Simplicity Rationale:** The document references `AppTheme.lightTheme`. In the active codebase (`monqiz_app/lib/core/theme/app_theme.dart`), the class is named `MonqizTheme.lightTheme`. Standardizing on `MonqizTheme` ensures consistency with the existing design system barrel exports.
