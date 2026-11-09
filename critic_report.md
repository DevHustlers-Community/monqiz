# Stage 7 Critic Review Report: Monqiz Mobile App Architecture

**Target:** `d:\My_Projects\monqiz\docs\designs\monqiz_mobile_architecture.md` (`lines 1..267`)

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| `egm-design` | completed |
| `egm-structural` | completed |
| `egm-style` | completed |

## Severity Breakdown
- 🔴 **Blocker:** 1
- 🟡 **Major:** 8
- 🟢 **Nit:** 5

---

## Prioritized Findings (Blockers -> Major -> Nits)

### 1. Direct Push Broadcast & Pre-Approval Alerting in CUJ 2 Violates Clinical Supervision - Severity: Blocker
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `lines 52–56` (`Critical User Journeys: CUJ 2`), `line 29` (`Goals`), `line 36` (`Non-Goals`)
* **Discrepancy Description:** CUJ 2 specifies: *"The app validates the hospital link, creates a `Request` entity in `Pending` state, and broadcasts notifications to all compatible donors with matching `DonationAddress` records."* This introduces two fundamental flaws:
  1. **Architectural Impossibility:** Mobile clients cannot multicast push notifications directly to peer devices without a backend broker (e.g., FCM / APNs).
  2. **Severe Clinical Safety Breach:** Non-Goal 2 (line 36) explicitly states that hospital approvals remain within the .NET Web Portal. Broadcasting urgent requisitions to voluntary donors while the case is in an unvetted `Pending` state violates the platform's core invariant ("Mandatory Hospital Binding" and "Hospital-Supervised Case Matching", lines 13, 29, 251), creating severe vulnerability to false, unvetted, or fraudulent emergency requests.
* **Rationale & Recommendation:** Decouple requisition creation from notification dispatch. The mobile client must only submit the emergency request in `PendingHospitalVerification` status. Once hospital clinical staff verify and approve the requisition in the .NET Web Portal, backend notification workers must trigger the targeted donor broadcast. Update CUJ 2 to reflect this two-step clinical approval workflow.

---

### 2. Clean Architecture Layer Invariant Violation: Core Biological Compatibility Placed in Core Utils - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `lines 110–115` (`Layer Invariants`), `line 129` (`Directory Layout`), `lines 19, 23` (`The Problem / Goals`)
* **Discrepancy Description:** `BloodCompatibilityEngine` and `EligibilityCalculator` are assigned to `lib/core/utils/` (line 129). Under Layer Invariant 1 (line 111), the Domain layer must house all core business rules and clinical invariants. Biological ABO/Rh matching, apheresis compatibility, and statutory recovery interval calculations are core clinical domain rules, not generic transversal utilities like date parsers or device helpers. Placing them in `core/` violates clean domain encapsulation.
* **Rationale & Recommendation:** Relocate clinical computation logic from `lib/core/utils/` to `lib/domain/services/` or `lib/domain/rules/` (`BloodCompatibilityEngine`, `EligibilityCalculator`). Reserve `lib/core/utils/` strictly for platform-level and domain-agnostic helpers.

---

### 3. Clinical Recovery Interval Contradictions Across Journeys and Specifications - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `line 20` (`The Problem`), `line 48` (`CUJ 1`), `line 58` (`CUJ 3`), `line 30` (`Goals`)
* **Discrepancy Description:** The document cites conflicting clinical recovery intervals without specifying the underlying physiological or regulatory standards:
  - Line 20 cites *"56 days for whole blood, up to 90/120 days depending on donor profile"*.
  - Line 48 (CUJ 1) assumes an eligible donor has a last donation `> 90 days ago` regardless of gender.
  - Line 58 (CUJ 3) flags a donor ineligible after `3 weeks` (21 days).
  - Line 53 introduces a requisition for *"platelets"*, which follow apheresis recovery schedules (typically 48 hours to 7–14 days), yet the document treats all donation types identically.
* **Rationale & Recommendation:** Formally specify the exact clinical rules enforced in `EligibilityCalculator`: explicitly adopt Egyptian Ministry of Health / Red Crescent standards (Whole Blood: 90 days for males, 120 days for females; Platelets: 14 days minimum). Explicitly define donor gender and donation component type in all CUJ scenarios to make eligibility testable and unambiguous.

---

### 4. State Fragmentation & Synchronization Hazards in Standalone `PledgeCubit` - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `lines 154–156` (`cubits/`), `lines 186–191` (`PledgeCubit State Machine`), `lines 220–223` (`Screen Inventory`)
* **Discrepancy Description:** Pledging is modeled via an independent `PledgeCubit` isolated from `CaseFeedCubit` and `RequestDetailsCubit`. When a donor successfully commits a pledge (`PledgeSuccess`), the parent request's `unitsPledged` must be immediately updated across the active feed and details screens. Isolating this single mutation into its own cubit requires error-prone cross-bloc communication, global event buses, or manual cache refetches that risk race conditions and UI inconsistency.
* **Rationale & Recommendation:** Consolidate the pledge action directly into `RequestDetailsCubit` (or unify feed and request lifecycle under a consolidated `BloodRequestCubit`). If a discrete `PledgeCubit` is maintained, define an explicit reactive repository stream (e.g., `Stream<BloodRequestEntity>`) so state updates automatically cascade across all observing widgets without manual synchronization.

---

### 5. Presentation Side-Effects Defined Within Cubit State Machine - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `lines 189–190` (`PledgeCubit State Machine`)
* **Discrepancy Description:** Line 189 states that `PledgeSuccess` *"triggers deep-link intent for `Hospital.LocationUrl` (Google Maps) and displays confirmation modal."* In reactive Flutter architecture, Cubit states should represent pure, immutable data models of the UI. Triggering external platform intents (such as launching external map applications) or modal navigations directly within state classes or cubit emissions causes repeated intent triggers during widget rebuilds and breaks headless unit tests.
* **Rationale & Recommendation:** Decouple platform intents and modal routing from state definitions. Specify that `PledgeSuccess` emits data only, while UI side-effects (opening Google Maps or showing dialogs) are executed in presentation screens using `BlocListener` with single-fire navigation semantics.

---

### 6. Domain Entity Naming Discrepancy Across Architecture Sections - Severity: Major
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `line 133` (`Directory Layout`), `line 189` (`PledgeCubit Contract`), `line 209` (`Domain Mapping Table`)
* **Discrepancy Description:** The core entity representing donor commitments is referred to by conflicting names:
  - Line 133 lists `PledgeEntity`.
  - Line 189 references `RequestAcceptanceEntity`.
  - Line 209 specifies `RequestAcceptanceEntity` with property `acceptanceStatus`.
  This naming divergence causes ambiguity across domain entities, models, and repository contracts.
* **Rationale & Recommendation:** Standardize on `RequestAcceptanceEntity` across the entire document to ensure 1:1 parity with the backend .NET schema `RequestAcceptance` table. If the business domain prefers the term `Pledge`, define `PledgeEntity` explicitly as the domain model and document `RequestAcceptanceModel` as its network DTO.

---

### 7. Incomplete Cubit State Machine Specifications - Severity: Major
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `lines 151–158` (`Directory Layout`), `lines 171–198` (`Section 3: Cubit State Management Contracts`)
* **Discrepancy Description:** Section 2 enumerates 7 cubits (`AuthCubit`, `CaseFeedCubit`, `RequestDetailsCubit`, `CreateRequestCubit`, `PledgeCubit`, `DonorPassportCubit`, `HospitalDirectoryCubit`). However, Section 3 only specifies state contracts for three (`CaseFeedCubit`, `PledgeCubit`, `CreateRequestCubit`). Four cubits are completely omitted from the state contracts section. In particular, `DonorPassportCubit` directly powers CUJ 3, yet its states, fields, and error handling are left undefined.
* **Rationale & Recommendation:** Expand Section 3 to document the state machine contracts for `AuthCubit`, `RequestDetailsCubit`, `DonorPassportCubit`, and `HospitalDirectoryCubit`, specifying their state hierarchies, properties, and failure modes.

---

### 8. Unresolved Open Questions Lacking Architectural Baselines - Severity: Major
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `lines 40–44` (`Open Questions`), `lines 175–191` (`Cubit Contracts`), `lines 255–266` (`NFRs`)
* **Discrepancy Description:** Section "Open Questions" raises two fundamental operational questions:
  1. Question 1 asks how donation completion is verified (one-time numerical token/QR scan vs. donor self-reporting).
  2. Question 2 asks how the case feed is sorted when GPS access is denied.
  However, neither the Cubit state machines, the ERD mapping, nor the screen inventory provides an interim default or architecture baseline for these questions. Consequently, `RequestAcceptance.AcceptanceStatus` lifecycle transitions and `CaseFeedCubit` fallback sorting logic remain structurally unresolved.
* **Rationale & Recommendation:** For each Open Question, establish an explicit baseline decision for the MVP / v1 implementation (e.g., *"v1 Baseline: Hospital staff validates completion via QR token scan; Fallback feed sorting: Filter by user's registered governorates, sorted by `requiredDate` ascending"*).

---

### 9. Backend Framework Version Mismatch with Project Baseline - Severity: Major
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `line 11` (`Overview`), `line 112` (`Layer Invariants`)
* **Discrepancy Description:** The document states that the mobile app interfaces with an existing ".NET 9 Web API". However, the project's root `README.md` (lines 8, 44, 48) defines the runtime environment as `.NET 10 / C# 14` with `EF Core 10.0`. Referencing an outdated runtime framework creates technical friction and inconsistent documentation across the repository.
* **Rationale & Recommendation:** Update all occurrences of ".NET 9" to ".NET 10" to align with repository ground truth.

---

### 10. Document Status Metadata Contradiction - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `line 4` (`Status: Approved`)
* **Discrepancy Description:** The document header marks the status as `Approved` despite containing unresolved open questions, missing cubit contracts, and being under active Critic Review.
* **Rationale & Recommendation:** Update status to `Draft (In Review)` until all review findings are addressed.

---

### 11. Hardcoded Local Absolute File Link in Screen Inventory - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `line 219` (`Screen Inventory`)
* **Discrepancy Description:** Line 219 uses a machine-specific file link: `[MonqizBloodRequestCard](file:///d:/My_Projects/monqiz/monqiz_app/lib/core/design_system/cards/monqiz_blood_request_card.dart)`. This hardcoded Windows path breaks portability across developer environments, CI pipelines, and macOS/Linux systems.
* **Rationale & Recommendation:** Use relative repository paths (e.g., `[MonqizBloodRequestCard](../../monqiz_app/lib/core/design_system/cards/monqiz_blood_request_card.dart)`).

---

### 12. Missing Use Cases and Traceability for `IUserRepository` - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `line 134` (`Directory Layout`), `line 204` (`Domain Mapping Table`)
* **Discrepancy Description:** `IUserRepository` is declared in line 134, but no corresponding use cases appear in `domain/usecases/`, nor is it referenced in cubit state definitions.
* **Rationale & Recommendation:** Add `GetDonorProfileUseCase` and `UpdateDonationPreferencesUseCase` under `domain/usecases/user/`, or clarify whether profile retrieval is encapsulated within `IAuthRepository`.

---

### 13. Undefined Local Emergency Hotline Magic Number "19888" - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `line 264` (`Offline Tolerance`)
* **Discrepancy Description:** "emergency hotlines (19888)" is mentioned without cultural or institutional context, making it an obscure magic number for non-Egyptian developers.
* **Rationale & Recommendation:** Expand to "Egyptian National Blood Transfusion Service emergency hotline (19888)".

---

### 14. Design System Theme Class Naming Discrepancy (`MonqizTheme` vs `AppTheme`) - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `line 99` (`Mermaid Diagram - Core Layer`)
* **Discrepancy Description:** The architecture diagram refers to `AppTheme`, whereas the existing Flutter design system uses `MonqizTheme`.
* **Rationale & Recommendation:** Change `AppTheme` to `MonqizTheme` to maintain design system brand consistency.
