### What this proposes
The document proposes an architectural blueprint and implementation plan for Monqiz, a Flutter mobile client (Android/iOS) designed to streamline emergency blood donation across Egypt and the MENA region. The mobile client implements Layered Clean Architecture (Core, Domain, Data, Presentation) and uses `flutter_bloc` Cubits for unidirectional state management. It connects donors exclusively to verified, hospital-hosted blood requisition requests, enforcing biological compatibility matching, on-device donor recovery countdowns, and one-tap pledge commitments. The app interfaces with an existing .NET 9 Web API and leverages an existing atomic design system in `monqiz_app/lib/core/design_system` to deliver an Arabic RTL user interface.

### How the existing system works, per this document
The existing backend infrastructure consists of a .NET 9 Web API backed by a relational schema containing `User`, `Address`, `Hospital`, `Request`, `DonationAddress`, and `RequestAcceptance` entities, paired with an administrative .NET Web Portal that handles hospital management, inventory, and staff approvals. Outside this platform, regional emergency blood requisition currently relies on chaotic informal channels (social media posts, group chats) suffering from fulfillment latency, incompatible donor matches, repeat donation safety violations, and vulnerability to fraud. Within the Flutter repository, an atomic design token and widget library (`monqiz_app/lib/core/design_system`) already exists with typography, emergency color palettes, and component cards, but the application layers, state management, and screens remain to be built.

---

### Findings

#### 1. Major
* **Affected Scope:** Section `Detailed Implementation Plan` -> `1. Configuration & Dependencies` (lines 273–275), `Core Layer` (lines 278–280), and `Verification Plan` (lines 383–406).
* **Discrepancy Description & Rationale:** Missing Required Dependencies for Stated Patterns.
  The document mandates that domain failures use the `Result`/`Either` pattern returning `Right(RequestAcceptance)` (lines 280, 392), Cubit state tests use `bloc_test` (line 394), widget and repository tests mock dependencies (lines 390–406), and the UI triggers external map intents and hotline calls (lines 189, 229, 351). Additionally, the architecture diagram (line 88) and NFRs (line 264) mandate local caching via `Hive`. However, the dependencies listed for `pubspec.yaml` (lines 273–275) completely omit functional error-handling packages (`dartz` or `fpdart`), testing packages (`bloc_test`, `mocktail`/`mockito`), intent launchers (`url_launcher`), and local cache databases (`hive`/`hive_flutter`). A developer following the plan step-by-step will immediately hit compilation errors due to missing packages.

#### 2. Major
* **Affected Scope:** Section `2. Directory Layout by Layer` (lines 120–167) vs Section `Target Files to Create/Modify` (lines 270–380).
* **Discrepancy Description & Rationale:** Architectural Scope Mismatch in Detailed Implementation Tasks.
  Section 2 outlines a comprehensive four-layer system containing full modules for Authentication (`AuthCubit`, `AuthRepositoryImpl`, `AuthRemoteDataSource`, `AuthLocalDataSource`), Hospital Directories (`HospitalDirectoryCubit`, `HospitalRepositoryImpl`, `HospitalRemoteDataSource`), Address entities/models, and local storage wrappers (`SecureStorageWrapper`, `PrefsWrapper`). In contrast, Section `Target Files to Create/Modify` only specifies tasks for Blood Requests, Pledges, and Models. It leaves out all Auth and Hospital data sources, repositories, and cubits, yet prescribes building `HospitalsDirectoryScreen` and `AppRouter` with authentication route guards. It is unclear whether the implementation plan represents an incomplete vertical slice or accidentally omitted these essential files.

#### 3. Major
* **Affected Scope:** Section `2. Directory Layout by Layer` (line 133), Section `4. ERD-to-Mobile Domain Mapping` (lines 208–209), and Section `3. Domain Layer` (lines 310–311, line 392).
* **Discrepancy Description & Rationale:** Domain Model & Entity Naming Inconsistencies.
  The entity representing donor commitments is referred to by three conflicting names: `PledgeEntity` in the directory layout (line 133), `RequestAcceptanceEntity` in the ERD mapping table and file list (lines 209, 310), and `RequestAcceptance` in the verification tests (line 392). Additionally, its status field is defined as `acceptanceStatus` in line 209 but as `status` in line 311. Furthermore, `DonationAddressEntity` and `AddressEntity` are defined in the ERD mapping table (lines 207–208), but are omitted from the Target Files list (lines 300–312) despite `HospitalEntity` depending on `AddressEntity`.

#### 4. Major
* **Affected Scope:** Section `Critical User Journeys` -> `CUJ 2` (lines 52–56) & Section `Non-Goals` (line 36).
* **Discrepancy Description & Rationale:** Ambiguous Notification Architecture & Clinical Prematurity in CUJ 2.
  CUJ 2 states that upon request submission, "The app validates the hospital link, creates a `Request` entity in `Pending` state, and broadcasts notifications to all compatible donors with matching `DonationAddress` records." In a standard client-server architecture, client apps cannot broadcast push notifications directly to other devices; notification dispatch is handled by backend services. More critically, Non-Goal 2 (line 36) states that hospital approvals occur within the .NET Web Portal. Broadcasting emergency alerts to voluntary donors while the case is still in an unapproved `Pending` state contradicts the core premise of verified, hospital-supervised requisitions.

#### 5. Major
* **Affected Scope:** Section `The Problem` (line 19), Section `Goals` (line 23), Section `2. Directory Layout by Layer` (line 129), and Section `Target Files to Create/Modify` (lines 277–299).
* **Discrepancy Description & Rationale:** Undefined Biological Compatibility Logic and Missing Engine File.
  "Automated biological compatibility matching" is presented as a primary value proposition (lines 19, 23), and `BloodCompatibilityEngine` is placed in `lib/core/utils/` (line 129). However, `BloodCompatibilityEngine` is omitted from the implementation file plan (lines 270–380). Additionally, the document never defines how biological compatibility is evaluated, nor does it specify the `BloodType` domain type (enum, value object, or entity). Furthermore, CUJ 2 mentions "platelets", whose ABO and plasma compatibility rules differ substantially from red blood cells; the document does not clarify if component-specific rules apply. Placing medical compatibility logic under `core/utils` also violates Clean Architecture by separating core clinical domain rules from the Domain layer.

#### 6. Major
* **Affected Scope:** Section `The Problem` (line 20), Section `CUJ 1` (line 48), Section `CUJ 3` (line 58), Section `2. Core Layer` (line 294), and Section `Verification Plan` (lines 386–389).
* **Discrepancy Description & Rationale:** Contradictory Clinical Recovery Interval Constraints.
  The document presents conflicting intervals for donor donation eligibility without defining the underlying clinical rules:
  - Line 20 cites "56 days for whole blood, up to 90/120 days depending on donor profile".
  - Line 48 considers a donor eligible when their "last donation > 90 days ago".
  - Line 294 references "gender recovery constraints (90 vs. 120 days)".
  - Lines 387–388 only test male donors at 90 days and omit female rules or when 56 days applies.
  A developer implementing `EligibilityCalculator` cannot determine whether the mandatory recovery period is 56 days, 90 days (men), or 120 days (women).

#### 7. Nit
* **Affected Scope:** Section `Non-Functional Requirements` -> `Offline Tolerance` (line 264).
* **Discrepancy Description & Rationale:** Undefined Magic Number "19888".
  Line 264 states that "emergency hotlines (19888)" must be cached locally. Without explanation, "19888" is an unexplained magic number to team members unfamiliar with Egypt's local emergency healthcare numbers (National Blood Transfusion / Red Crescent hotline). It should be defined explicitly.

#### 8. Nit
* **Affected Scope:** Section `Detailed Implementation Plan` -> `5. Presentation Layer` (line 360).
* **Discrepancy Description & Rationale:** Unspecified Root Tabs in `MainShellScreen`.
  Line 360 states that `MainShellScreen` scaffolds a bottom navigation bar with "4 root tabs", but does not specify which screens occupy those tabs. While five modules exist in the directory (Home, Request Details, Create Request, Passport, Hospitals Directory), the document should explicitly specify the four bottom navigation destinations.

#### 9. Nit
* **Affected Scope:** Section `3. Cubit State Management Contracts` (lines 171–198).
* **Discrepancy Description & Rationale:** Missing State Machine Specifications for Auth, Directory, and Passport Cubits.
  Section 3 defines contracts only for `CaseFeedCubit`, `PledgeCubit`, and `CreateRequestCubit`. It omits state contracts for `AuthCubit`, `RequestDetailsCubit`, `DonorPassportCubit`, and `HospitalDirectoryCubit`. Given that `DonorPassportCubit` drives CUJ 3, its states and emission sequence should be specified alongside the others.
