# Consolidated Goldfish Review Report: Monqiz Mobile App Architecture

*   **Document Reviewed:** [`docs/designs/monqiz_mobile_architecture.md`](file:///d:/My_Projects/monqiz/docs/designs/monqiz_mobile_architecture.md)
*   **Execution Flow:** Uninterrupted Full Flow (Stages 5, 6, 7, 8, and 9)
*   **Date:** 2026-11-06
*   **Author:** Khalid Omr

---

## 1. Executive Summary & Review Metrics

The Monqiz Mobile App technical design underwent rigorous, multi-lens scrutiny through the five standardized EGM Goldfish review stages:
1. **Stage 5 (Initial Zoom Out Review):** Evaluated high-altitude simplicity, YAGNI, and anti-weeds.
2. **Stage 6 (Comprehension Test):** Audited self-containment, clarity, and undefined terms without assumed context.
3. **Stage 7 (Critic Review):** Antagonistic swarm audit spanning Architecture (`egm-design`), Structural Layout (`egm-structural`), and Technical Style (`egm-style`).
4. **Stage 8 (Intermediate Zoom Out Review):** Assessed aggregate complexity inflation, third-party dependency creep, and architectural minimalism.
5. **Stage 9 (Implementation Readiness Test):** Evaluated line-by-line execution feasibility, file completeness, and codebase symbol fidelity (`egm-implementation-readiness`, `egm-codebase-details`).

### Findings Breakdown
*   🔴 **Blockers:** 3 critical architectural, clinical safety, and dependency blockers.
*   🟡 **Majors:** 9 domain boundary, state management, and scope refinements.
*   🟢 **Nits:** 6 codebase symbol, naming, and documentation consistency items.
*   **Total Raw Findings:** 28 observations consolidated into 18 actionable remediation items.

---

## 2. Consolidated Action Items

### 🔴 Critical Blockers (Must Resolve Before Coding)

#### [BLK-01] Decouple Request Creation from Notification Broadcast & Enforce Two-Step Clinical Approval
*   **Origin:** Stage 6 (Finding 4), Stage 7 (Finding 1).
*   **Issue:** CUJ 2 states that upon request submission, the mobile app creates a `Pending` request and immediately broadcasts notifications to all matching donors. In a client-server architecture, client apps cannot push multicast notifications directly to peers without a backend broker (FCM/APNs). More critically, broadcasting alerts for unverified `Pending` requests violates the core platform invariant: 100% mandatory hospital supervision.
*   **Actionable Remediation:** Update CUJ 2 and the request creation workflow:
    1. Mobile user submits requisition in `PendingHospitalVerification` status.
    2. Hospital clinical staff inspects and approves the case via the administrative .NET Web Portal (changing status to `Approved`).
    3. Backend notification service detects the `Approved` event and dispatches targeted push notifications to donors in matching governorates.

#### [BLK-02] Complete Detailed Implementation File Inventory Across All Layers (Dual-Mode Mock/API)
*   **Origin:** Stage 6 (Finding 2), Stage 8 (Finding 7), Stage 9 (Finding 1).
*   **Issue:** The implementation task list previously omitted data and repository implementations for Authentication and Hospitals. Furthermore, the backend .NET API is actively under development, necessitating an immediate mock data setup while keeping future API integration clean.
*   **Actionable Remediation:** Establish a **Dual-Mode Data Source Strategy** with an `AppConfig.useMockData` toggle in `injection_container.dart`:
    *   **Phase 1 (Mock First):** Implement `MockBloodRequestDataSource`, `MockHospitalDataSource`, and `MockAuthDataSource` with realistic seed data matching the ERD, 500ms simulated latency, and error simulation.
    *   **Phase 2 (Production API Ready):** Implement `DioBloodRequestDataSource`, `DioHospitalDataSource`, and `DioAuthDataSource` implementing the same datasource interfaces.
    *   Structure the presentation layer into 3 complete phased vertical slices (Discovery Feed, Case Details & Pledge, Auth & البطاقة الرقمية) with 100% dependency closure.

#### [BLK-03] Supply Missing Production and Testing Dependencies in `pubspec.yaml`
*   **Origin:** Stage 6 (Finding 1), Stage 9 (Finding 2).
*   **Issue:** The dependency specification in line 275 omits several packages required by the plan:
    *   `url_launcher`: Required to launch external phone dialer (`tel:19888`) and Google Maps navigation (`Hospital.LocationUrl`).
    *   `bloc_test`: Mandated by the Cubit verification plan.
    *   `mocktail`: Required to mock repositories and cubits in unit and widget tests.
*   **Actionable Remediation:** Update `monqiz_app/pubspec.yaml` target dependencies:
    *   Add `url_launcher: ^6.3.0` to `dependencies`.
    *   Add `bloc_test: ^9.1.7` and `mocktail: ^1.0.4` to `dev_dependencies`.

---

### 🟡 Major Refinements (Domain, State, and Scope)

#### [MAJ-01] Relocate Clinical Rules from Core Utils to Domain Layer
*   **Origin:** Stage 6 (Finding 5), Stage 7 (Finding 2), Stage 9 (Finding 6).
*   **Issue:** `EligibilityCalculator` and `BloodCompatibilityEngine` are assigned to `lib/core/utils/`. Under Clean Architecture rules, core clinical invariants (donor eligibility recovery intervals, biological blood compatibility matrices) are pure healthcare domain logic, not platform utilities.
*   **Actionable Remediation:** Move clinical computation logic to `monqiz_app/lib/domain/rules/` (`eligibility_rules.dart`, `blood_compatibility_rules.dart`). Reserve `lib/core/utils/` strictly for generic platform helpers (e.g., date formatting).

#### [MAJ-02] Consolidate Pledge Action into `RequestDetailsCubit`
*   **Origin:** Stage 5 (Finding 3), Stage 7 (Finding 4), Stage 8 (Finding 4), Stage 9 (Finding 5).
*   **Issue:** Pledging is a single action on a specific request. Isolating it into an independent `PledgeCubit` creates state drift across feed and detail screens, requiring either error-prone cross-bloc communication or complex reactive repository streams.
*   **Actionable Remediation:** Eliminate `PledgeCubit`. Integrate `pledgeDonation(requestId)` directly as a method inside `RequestDetailsCubit`. Upon successful pledge, update the active case entity in place, keeping state management simple and synchronous.

#### [MAJ-03] Prune Speculative Multi-Component Apheresis (YAGNI)
*   **Origin:** Stage 6 (Finding 5), Stage 7 (Finding 3), Stage 8 (Finding 1).
*   **Issue:** CUJ 2 casually mentions "3 units of B+ platelets", triggering demands for complex apheresis recovery schedules. However, the backend ERD schema only models `BloodType` (ABO/Rh) and has zero support for blood component types.
*   **Actionable Remediation:** Lock scope to standard Whole Blood. Update CUJ 2 to "3 units of B+ blood". Explicitly declare apheresis/platelet component management as an out-of-scope Non-Goal.

#### [MAJ-04] Standardize Clinical Recovery Intervals on MoHP Standards
*   **Origin:** Stage 6 (Finding 6), Stage 7 (Finding 3).
*   **Issue:** The document references conflicting recovery intervals (56 days vs 90 days vs 120 days).
*   **Actionable Remediation:** Explicitly adopt Egyptian Ministry of Health & Population (MoHP) / Red Crescent guidelines:
    *   Whole Blood (Male): 90 days (3 months).
    *   Whole Blood (Female): 120 days (4 months).
    *   Minimum Age: 18 years; Maximum Age: 65 years.
    *   First-Time Donors (`lastDonationDate == null`): Eligible.

#### [MAJ-05] Eliminate Hive and Dynamic Feed Disk Caching
*   **Origin:** Stage 5 (Finding 2), Stage 8 (Finding 5).
*   **Issue:** Caching dynamic emergency requests locally using `Hive` introduces cache invalidation overhead and presents a clinical hazard: offline donors may view stale, expired, or already-fulfilled emergency requests.
*   **Actionable Remediation:** Remove `FeedLocalCache` and `Hive`. Confine offline tolerance strictly to static reference data: bundle accredited hospital coordinates and hotlines in `assets/data/hospitals_fallback.json` and persist user preferences in standard `shared_preferences`.

#### [MAJ-06] Replace `Either`/`Right` with Native Dart 3 Sealed `Result<T>`
*   **Origin:** Stage 6 (Finding 1), Stage 8 (Finding 2), Stage 9 (Finding 3).
*   **Issue:** The document mandates `Result`/`Either` and tests `Right()`, but omits `dartz`/`fpdart`. Adding abandoned Haskell monad libraries creates dependency baggage.
*   **Actionable Remediation:** Reject `dartz`/`fpdart`. Create `monqiz_app/lib/core/error/result.dart` using a native Dart 3 sealed class:
    ```dart
    sealed class Result<T> { const Result(); }
    final class Success<T> extends Result<T> { final T data; const Success(this.data); }
    final class FailureResult<T> extends Result<T> { final Failure failure; const FailureResult(this.failure); }
    ```
    Update tests to expect `Success(data)` and `FailureResult(failure)`.

#### [MAJ-07] Prune 1-to-1 Pass-Through Use Cases
*   **Origin:** Stage 5 (Finding 1), Stage 8 (Finding 3), Stage 9 (Finding 6).
*   **Issue:** Mandating single-method UseCases for every trivial repository query (`GetHospitalsUseCase`, `GetHospitalByIdUseCase`, `GetUrgentRequestsUseCase`) creates 14+ redundant pass-through files with zero business logic.
*   **Actionable Remediation:** Allow Cubits to inject and consume domain repository interfaces directly (`BloodRequestRepository`, `HospitalRepository`, `AuthRepository`). Reserve UseCases strictly for multi-entity domain operations (e.g., `PledgeBloodDonationUseCase` checking eligibility rules before committing).

#### [MAJ-08] Expand Cubit State Machine Specifications
*   **Origin:** Stage 6 (Finding 9), Stage 7 (Finding 7).
*   **Issue:** Section 3 documents state contracts only for 3 cubits, leaving `AuthCubit`, `RequestDetailsCubit`, `DonorPassportCubit`, and `HospitalDirectoryCubit` completely undefined.
*   **Actionable Remediation:** Document full sealed state hierarchies, fields, and error handling for all 5 production cubits in Section 3.

#### [MAJ-09] Establish Concrete MVP Baselines for Open Questions
*   **Origin:** Stage 7 (Finding 8), Stage 8 (Finding 6).
*   **Issue:** Open Questions regarding pledge verification and GPS-denied feed sorting lack implementation baselines.
*   **Actionable Remediation:** Set explicit MVP baselines in Section "Open Questions":
    *   *Pledge Verification:* Hospital clinical staff validates donor arrival via National ID / phone and updates status to `Completed` directly in the .NET Web Portal.
    *   *GPS-Denied Sorting:* Filter requests by the user's registered `DonationAddress` governorates, sorted by `requiredDate` ascending.

---

### 🟢 Minor Consistency & Hygiene Nits

#### [NIT-01] Standardize Theme Symbol on `MonqizTheme`
*   **Origin:** Stage 5 (Finding 6), Stage 7 (Finding 14), Stage 9 (Finding 7).
*   **Action:** Change `AppTheme.lightTheme` to `MonqizTheme.lightTheme` to match `monqiz_app/lib/core/theme/app_theme.dart`.

#### [NIT-02] Standardize Domain Entity Naming
*   **Origin:** Stage 6 (Finding 3), Stage 7 (Finding 6), Stage 9 (Finding 9).
*   **Action:** Use `RequestAcceptanceEntity` consistently (remove `PledgeEntity` aliases). Remove C#-style `I` prefixes from Dart repository interfaces (`BloodRequestRepository` implemented by `BloodRequestRepositoryImpl`).

#### [NIT-03] Replace Hardcoded Windows Links with Portable Relative Paths
*   **Origin:** Stage 7 (Finding 11).
*   **Action:** Replace `file:///d:/...` links with relative paths (`../../monqiz_app/lib/...`).

#### [NIT-04] Define Local Emergency Hotline Magic Number "19888"
*   **Origin:** Stage 6 (Finding 7), Stage 7 (Finding 13).
*   **Action:** Expand to "Egyptian National Blood Transfusion Service hotline (19888)".

#### [NIT-05] Explicitly Enumerate 4 Bottom Navigation Shell Tabs
*   **Origin:** Stage 6 (Finding 8).
*   **Action:** Explicitly list the four root destinations: (1) Home Feed, (2) Hospitals Directory, (3) Create Request (+), (4) Donor Passport.

#### [NIT-06] Align Backend Framework Ground Truth to .NET 10
*   **Origin:** Stage 7 (Finding 9).
*   **Action:** Update all occurrences of ".NET 9" to ".NET 10" to match root `README.md`.

---

## 3. Traceability Matrix

| Raw Finding Source | Reviewer Lens | Scope / Category | Consolidated Action Item |
| :--- | :--- | :--- | :--- |
| `zoom_out_report.md` #1 | `egm-zoom-out` | Simplicity / Use Case Proliferation | **[MAJ-07]** Prune Pass-Through Use Cases |
| `zoom_out_report.md` #2 | `egm-zoom-out` | Clinical Safety / Hive Cache | **[MAJ-05]** Eliminate Hive & Dynamic Feed Cache |
| `zoom_out_report.md` #3 | `egm-zoom-out` | State Coordination / PledgeCubit | **[MAJ-02]** Consolidate Pledge Action into RequestDetailsCubit |
| `zoom_out_report.md` #4 | `egm-zoom-out` | Layer-First vs Feature-First | Documented Author Invariant (Retained by Choice) |
| `zoom_out_report.md` #5 | `egm-zoom-out` | Dependencies / SharedPreferences | **[MAJ-05]** Use standard shared_preferences |
| `zoom_out_report.md` #6 | `egm-zoom-out` | Codebase Symbol / AppTheme | **[NIT-01]** Standardize on MonqizTheme |
| `comprehension_report.md` #1 | `egm-comprehension` | Dependencies / bloc_test, dartz | **[BLK-03]** Add Dependencies, **[MAJ-06]** Native Result |
| `comprehension_report.md` #2 | `egm-comprehension` | Architecture / Omitted Auth/Hospital Files | **[BLK-02]** Complete File Inventory in 3 Slices |
| `comprehension_report.md` #3 | `egm-comprehension` | Naming / PledgeEntity vs RequestAcceptance | **[NIT-02]** Standardize RequestAcceptanceEntity |
| `comprehension_report.md` #4 | `egm-comprehension` | CUJ 2 / Direct Push Broadcast | **[BLK-01]** Two-Step Clinical Approval |
| `comprehension_report.md` #5 | `egm-comprehension` | Clinical / Platelets & Biological Rules | **[MAJ-01]** Domain Rules, **[MAJ-03]** Whole Blood Only |
| `comprehension_report.md` #6 | `egm-comprehension` | Clinical / Conflicting Recovery Days | **[MAJ-04]** Standardize MoHP Guidelines (90d / 120d) |
| `comprehension_report.md` #7 | `egm-comprehension` | Style / Magic Number 19888 | **[NIT-04]** Define Hotline 19888 |
| `comprehension_report.md` #8 | `egm-comprehension` | UI / Unspecified Shell Tabs | **[NIT-05]** Enumerate 4 Bottom Navigation Tabs |
| `comprehension_report.md` #9 | `egm-comprehension` | State / Missing Cubit Contracts | **[MAJ-08]** Expand Cubit State Contracts |
| `critic_report.md` #1 | `egm-design` | Architecture / Direct Push in CUJ 2 | **[BLK-01]** Two-Step Clinical Approval |
| `critic_report.md` #2 | `egm-design` | Clean Architecture / Utils Violation | **[MAJ-01]** Relocate Rules to Domain |
| `critic_report.md` #3 | `egm-design` | Clinical / Recovery Contradictions | **[MAJ-04]** Standardize MoHP Guidelines |
| `critic_report.md` #4 | `egm-design` | State / PledgeCubit Hazards | **[MAJ-02]** Consolidate Pledge Action |
| `critic_report.md` #5 | `egm-design` | Architecture / Presentation Side-Effects | **[MAJ-02]** Single-Fire BlocListener for UI Intents |
| `critic_report.md` #6 | `egm-structural` | Naming / Entity Divergence | **[NIT-02]** Standardize RequestAcceptanceEntity |
| `critic_report.md` #7 | `egm-structural` | Scope / Incomplete Cubit Specs | **[MAJ-08]** Expand Cubit State Contracts |
| `critic_report.md` #8 | `egm-structural` | Architecture / Unresolved Open Questions | **[MAJ-09]** Establish MVP Baselines |
| `critic_report.md` #9 | `egm-style` | Ground Truth / .NET 9 vs .NET 10 | **[NIT-06]** Align with .NET 10 |
| `critic_report.md` #10 | `egm-style` | Metadata / Document Status | Set Status to `In Review` until remediated |
| `critic_report.md` #11 | `egm-structural` | Portability / Windows Absolute Links | **[NIT-03]** Use Relative Repository Paths |
| `critic_report.md` #12 | `egm-structural` | Traceability / IUserRepository | Handled in **[BLK-02]** (Consolidated in Auth) |
| `critic_report.md` #13 | `egm-style` | Documentation / Hotline 19888 | **[NIT-04]** Define Hotline 19888 |
| `critic_report.md` #14 | `egm-style` | Codebase / AppTheme | **[NIT-01]** Standardize on MonqizTheme |
| `intermediate_zoom_out_report.md` #1 | `egm-zoom-out` | YAGNI / Apheresis Platelet Overkill | **[MAJ-03]** Prune Platelets Scope |
| `intermediate_zoom_out_report.md` #2 | `egm-zoom-out` | Dependencies / Reject dartz/fpdart | **[MAJ-06]** Native Dart 3 Sealed Result |
| `intermediate_zoom_out_report.md` #3 | `egm-zoom-out` | Simplicity / Pass-Through Use Cases | **[MAJ-07]** Prune Pass-Through Use Cases |
| `intermediate_zoom_out_report.md` #4 | `egm-zoom-out` | Simplicity / Avoid Reactive Streams | **[MAJ-02]** In-place Update in RequestDetailsCubit |
| `intermediate_zoom_out_report.md` #5 | `egm-zoom-out` | YAGNI / Eliminate Hive | **[MAJ-05]** Eliminate Hive Database |
| `intermediate_zoom_out_report.md` #6 | `egm-zoom-out` | Simplicity / QR Scanning Premature | **[MAJ-09]** Hospital Web Portal Verification |
| `intermediate_zoom_out_report.md` #7 | `egm-zoom-out` | Feasibility / 3 Execution Slices | **[BLK-02]** 3 Phased Vertical Slices |
| `implementation_readiness_report.md` #1 | `egm-implementation-readiness` | File Closure / Missing Data Layer | **[BLK-02]** Complete File Inventory in 3 Slices |
| `implementation_readiness_report.md` #2 | `egm-implementation-readiness` | Dependencies / Missing pubspec packages | **[BLK-03]** Add url_launcher, bloc_test, mocktail |
| `implementation_readiness_report.md` #3 | `egm-codebase-details` | Pattern / Either vs Native Result | **[MAJ-06]** Native Dart 3 Sealed Result |
| `implementation_readiness_report.md` #4 | `egm-implementation-readiness` | Testing / Incomplete Test Matrix | **[MAJ-04]** & Comprehensive Test Specs |
| `implementation_readiness_report.md` #5 | `egm-implementation-readiness` | State / Missing Cubit Files | **[BLK-02]** & **[MAJ-02]** |
| `implementation_readiness_report.md` #6 | `egm-implementation-readiness` | Boundaries / Relocate Rules to Domain | **[MAJ-01]** Domain Rules Package |
| `implementation_readiness_report.md` #7 | `egm-codebase-details` | Codebase / MonqizTheme Fidelity | **[NIT-01]** Standardize on MonqizTheme |
| `implementation_readiness_report.md` #8 | `egm-codebase-details` | Environment / Root Path Normalization | **[NIT-06]** monqiz_app/ prefix & cd command |
| `implementation_readiness_report.md` #9 | `egm-style` | Style / Entity & Repository Naming | **[NIT-02]** Remove 'I' prefix, RequestAcceptanceEntity |
| `implementation_readiness_report.md` #10 | `egm-implementation-readiness` | Offline / Hospital Asset Fallback | **[MAJ-05]** assets/data/hospitals_fallback.json |
| `implementation_readiness_report.md` #11 | `egm-style` | Metadata / Trailing Artifact | Cleanup document footer |

---

*Consolidated Review compiled under the Elephant-Goldfish Model (EGM)*
