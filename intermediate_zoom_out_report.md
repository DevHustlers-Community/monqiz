# Stage 8 Intermediate Zoom Out Review: Monqiz Mobile App Architecture

**Target File:** `monqiz_mobile_architecture.md` (`lines 1..418`)  
**Context Ingested:** `concepts_brief.md`, `zoom_out_report.md`, `comprehension_report.md`, `critic_report.md`  
**Standard Evaluated:** Zoom-Out Standard (`resources/document_standards/zoom-out-standard.md`)  
**Reviewer:** Skeptical Architect (Zoom Out Goldfish)

---

### Executive Evaluation: High-Altitude Simplicity & Complexity Inflation Assessment

The architecture document for the Monqiz mobile client establishes a strong clinical foundation: strict hospital supervision, direct GPS navigation to accredited blood banks, and on-device recovery tracking. However, an evaluation of the aggregate system design across Stages 5, 6, and 7 reveals a clear risk of **complexity inflation**. The design is being pushed toward "clean architecture cargo-culting" (pass-through use cases for basic queries, unneeded functional programming libraries) and review-induced scope creep (demanding apheresis/platelet clinical matrices when the backend only models whole blood, or reactive stream pipelines for single pledge actions).

The primary mandate of this Stage 8 Zoom Out Review is to enforce **architectural minimalism**: prune speculative abstractions, prevent unnecessary third-party package bloat, and ensure proposed mitigations simplify the codebase rather than compound its complexity.

---

### Structured Review Findings

#### Finding 1: Speculative Complexity — Apheresis & Multi-Component Blood Rules (YAGNI)
* **Severity:** Major
* **Affected Scope:** Section `The Problem` (line 20), Section `CUJ 2` (line 53), Section `Goals` (line 30), and mitigations proposed in `critic_report.md` (Finding 3) & `comprehension_report.md` (Finding 5).
* **Simplicity Rationale:** 
  In `monqiz_mobile_architecture.md`, CUJ 2 casually mentions a request for *"3 units of B+ platelets"*. This triggered previous reviews to demand an entire apheresis recovery calculation engine (48h/14-day intervals, platelet-specific HLA/plasma compatibility tables).
  However, examining the ERD mapping table in `monqiz_mobile_architecture.md` reveals that the backend `Request` model only contains `BloodType` (O-, A+, etc.) and has **zero** fields for `DonationType` or component classification (Whole Blood vs Platelets vs Plasma).
  Attempting to design a multi-component apheresis calculation engine when the underlying .NET backend schema does not even distinguish between blood components is pure speculative over-engineering (YAGNI).
  *Minimalist Resolution:* Prune CUJ 2 to standard whole blood ("3 units of B+ blood"). Strictly scope `EligibilityCalculator` and compatibility matching to standard Whole Blood (ABO/Rh red blood cell rules; 90 days for males / 120 days for females per Egyptian MoHP standards). Explicitly record apheresis/platelet donation types as an out-of-scope Non-Goal.

---

#### Finding 2: Complexity Inflation in Error Handling — Third-Party Functional Programming Libraries (`dartz` / `fpdart`)
* **Severity:** Major
* **Affected Scope:** Section `Detailed Implementation Plan -> 1. Configuration & Dependencies` (lines 273–276), `2. Core Layer` (line 280), and `comprehension_report.md` (Finding 1).
* **Simplicity Rationale:** 
  `comprehension_report.md` flagged that `dartz` or `fpdart` was missing from `pubspec.yaml` because lines 280 and 392 mentioned the `Result`/`Either` pattern and `Right(RequestAcceptance)`.
  Adding `dartz` (an abandoned Haskell-inspired library with steep learning curves and opaque monad types) or `fpdart` to a modern Flutter project running Dart 3 (`sdk: ^3.13.0` per `pubspec.yaml`) is unnecessary dependency baggage.
  Dart 3 features native sealed classes and pattern matching. A 15-line native sealed class (`sealed class Result<T> { ... }` with `Success<T>` and `FailureResult<T>`) provides compile-time exhaustive type checking, clean `switch` expressions, zero third-party dependencies, and zero cognitive friction for Flutter developers.
  *Minimalist Resolution:* Reject adding `dartz` or `fpdart`. Replace `Either<Failure, T>` with a native Dart 3 sealed class `Result<T>` in `lib/core/error/result.dart`.

---

#### Finding 3: Premature Abstraction — 1-to-1 Pass-Through Use Case Proliferation
* **Severity:** Major
* **Affected Scope:** Section 2 (`Directory Layout by Layer`, lines 135–140), Section `Detailed Implementation Plan` (`Domain Layer`, lines 322–328), and `critic_report.md` (Finding 12).
* **Simplicity Rationale:** 
  The architecture mandates discrete single-method UseCase classes for every single repository query (`GetUrgentRequestsUseCase`, `GetRequestDetailsUseCase`, `GetHospitalsUseCase`, `GetHospitalByIdUseCase`, `LoginUseCase`, `LogoutUseCase`, etc.). `critic_report.md` even recommended adding more (`GetDonorProfileUseCase`, `UpdateDonationPreferencesUseCase`).
  In an MVP mobile app connecting to a REST API, wrapping every repository method in a boilerplate class that merely forwards `call() => repo.method()` generates 14+ redundant files, interfaces, and DI bindings in `injection_container.dart` without adding any business logic. It also doubles the unit test burden with trivial mock-delegation tests.
  *Minimalist Resolution:* Cubits should inject and call Domain Repository interfaces directly (`IBloodRequestRepository`, `IHospitalRepository`, `IAuthRepository`). Reserve Use Cases strictly for operations that orchestrate multi-entity business rules (e.g., `PledgeBloodDonationUseCase` checking eligibility rules before committing a pledge). This cuts domain boilerplate by over 60% without sacrificing testability or clean architecture boundaries.

---

#### Finding 4: Complexity Inflation in State Coordination — Reactive Streams vs. Consolidating Pledge Action
* **Severity:** Major
* **Affected Scope:** Section 2 (`cubits/`, lines 154–156), Section 3 (`Cubit State Management Contracts`, lines 186–191), and `critic_report.md` (Finding 4 Recommendation).
* **Simplicity Rationale:** 
  Pledging is a single user mutation performed on a specific emergency request. Isolating it into an independent `PledgeCubit` separates the action from the request state. In response, `critic_report.md` suggested mitigating this by introducing an explicit reactive repository stream (`Stream<BloodRequestEntity>`) across the entire repository layer.
  Introducing a custom reactive stream architecture (StreamControllers, stream subscriptions, and multi-listener management in repositories) just to update `unitsPledged` after a button tap inflates architectural complexity by an order of magnitude.
  *Minimalist Resolution:* Avoid reactive repository streams. Consolidate pledge submission directly into the request state flow within `RequestDetailsCubit` (or a unified `BloodRequestCubit`). The cubit triggers the mutation and directly updates the active request model upon success. Keep it simple and synchronous.

---

#### Finding 5: Premature Optimization & Binary Dependency Bloat — Local Database Engine (`Hive`) for Feed Caching
* **Severity:** Major
* **Affected Scope:** Section 1 (`Data Layer`, line 88), Section 2 (`Local DataSources`, line 145), Section `Non-Functional Requirements` (`Offline Tolerance`, lines 263–265), and `comprehension_report.md` (Finding 1).
* **Simplicity Rationale:** 
  `comprehension_report.md` suggested adding `hive`/`hive_flutter` to dependencies to fulfill lines 88 and 264.
  As identified in Stage 5, blood requisitions are dynamic clinical emergencies (often expiring in $< 3$ hours). Caching dynamic feed cards in a local disk database presents a severe clinical hazard: an offline user may view stale, already-fulfilled requests and travel to a blood bank unnecessarily.
  Furthermore, pulling in a NoSQL database engine like Hive requires type adapters, box lifecycles, and cache invalidation policies. 
  *Minimalist Resolution:* Drop `FeedLocalCache` and eliminate Hive completely from the architecture. Confine offline tolerance exclusively to static, immutable reference data: emergency hotlines (19888) and accredited hospital directory coordinates. These can be served from bundled static asset JSON (`assets/data/hospitals.json`) or cached in standard `shared_preferences`, keeping the local storage stack lean and dependency-free.

---

#### Finding 6: Architectural Simplification of Open Question 1 (Pledge Verification)
* **Severity:** Nit
* **Affected Scope:** Section `Open Questions` (lines 42–43) and `critic_report.md` (Finding 8).
* **Simplicity Rationale:** 
  Open Question 1 considers whether donation completion should require a one-time QR code/numerical token scanned at the hospital or donor self-reporting.
  Non-Goal 2 (line 36) states that hospital administration and approvals remain strictly within the .NET Web Portal. Introducing in-app QR code generators, mobile camera scanning hardware permissions, and cryptographic token exchanges in the mobile client for v1 is premature feature creep.
  *Minimalist Resolution:* Establish the v1 MVP baseline: when a donor arrives at the hospital blood bank, hospital clinical staff verify the donor's national ID / phone number and mark `RequestAcceptance.AcceptanceStatus = Completed` directly in the hospital's .NET Web Portal. The mobile app simply observes the status update on refresh, requiring zero QR scanning hardware code.

---

#### Finding 7: Missing Execution Slices in Detailed Implementation Plan
* **Severity:** Nit
* **Affected Scope:** Section `Detailed Implementation Plan -> Target Files to Create/Modify` (lines 270–380).
* **Simplicity Rationale:** 
  `comprehension_report.md` noted that the implementation tasks listed 30+ files but omitted Auth and Hospital datasources. Rather than dumping an overwhelming, unprioritized list of 40+ files to create all at once, the implementation plan should be structured into three minimal, verifiable vertical slices:
  - **Slice 1 (Core & Case Discovery):** Core setup, Dio client, Hospital asset cache, `BloodRequestRepository`, `CaseFeedCubit`, and `HomeFeedScreen`.
  - **Slice 2 (Pledge & Details):** `RequestDetailsCubit` with integrated pledge action, biological compatibility checks, and external map launcher.
  - **Slice 3 (Requisition & Donor Passport):** `CreateRequestCubit` (lightweight form validation), `DonorPassportCubit`, and shell navigation.

---

### Summary Checklist for Document Finalization

1. **Prune Speculative Biological Scope:** Remove "platelets" and multi-component apheresis from CUJ 2; lock scope to Whole Blood (90d male / 120d female).
2. **Reject `dartz`/`fpdart`:** Use native Dart 3 sealed class `Result<T>` instead of Haskell monad packages.
3. **Eliminate Hive & Dynamic Feed Cache:** Remove Hive; bundle hospital directory as static JSON fallback.
4. **Prune Pass-Through Use Cases:** Inject repositories directly into Cubits; reserve UseCases only for composite domain rules.
5. **Consolidate Pledge Flow:** Merge pledge submission into `RequestDetailsCubit`, avoiding reactive repository stream complexity.
6. **Adopt Minimal Baselines for Open Questions:** Let hospital staff complete pledges in the Web Portal; sort feed by date when GPS is disabled.
