# Stage 9 Implementation Readiness Review: Monqiz Mobile App Architecture

**Target:** `d:\My_Projects\monqiz\docs\designs\monqiz_mobile_architecture.md` (`lines 268..418`)

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| `egm-implementation-readiness` | completed |
| `egm-codebase-details` | completed |
| `egm-style` | completed |

## Severity Breakdown
- 🔴 **Blocker:** 2
- 🟡 **Major:** 5
- 🟢 **Nit:** 4
- **Total Findings:** 11

---

## Prioritized Findings (Blockers -> Major -> Nits)

### 1. Critical Architecture Incompleteness: Omission of Data Sources, Repositories, and Auth/Hospital Infrastructure - Severity: Blocker
* **Reviewer Lens:** `egm-implementation-readiness`
* **Affected Scope:** `lines 329–345` (`4. Data Layer`), `lines 313–321` (`3. Domain Layer`), `lines 290–292` (`Core Layer: injection_container.dart`)
* **Discrepancy Description**: The implementation plan outlines 30+ files but completely omits the entire data layer for Authentication and Hospitals (`AuthRemoteDataSource`, `AuthLocalDataSource`, `AuthRepositoryImpl`, `HospitalRemoteDataSource`, `HospitalRepositoryImpl`), along with required DTOs and entities (`AddressEntity`, `DonationAddressEntity`, `AddressModel`, `RequestAcceptanceModel`). Furthermore, `injection_container.dart` (line 290) is tasked with initializing singletons and factories across all layers, yet the concrete data sources and repository implementations for Auth and Hospital queries do not exist in the plan. An engineer implementing this plan cannot assemble DI, satisfy route guards in `AppRouter`, or back `HospitalsDirectoryScreen`.
* **Rationale & Recommendation**: Complete the file inventory across all layers or structure the implementation plan into three phased vertical execution slices with full dependency closure:
  - **Slice 1 (Core & Case Discovery):** Core setup, `AddressEntity`/`HospitalEntity`, `HospitalRemoteDataSource`, `BloodRequestRemoteDataSource`, `BloodRequestRepositoryImpl`, and `CaseFeedCubit`.
  - **Slice 2 (Pledge & Case Details):** `RequestAcceptanceEntity`/Model, `BloodCompatibilityRules`, and `RequestDetailsCubit` with integrated pledge action.
  - **Slice 3 (Auth, Wizard & Donor Passport):** `AuthRemoteDataSource`, `AuthRepositoryImpl`, `CreateRequestCubit`, and `DonorPassportCubit`.

---

### 2. Missing Essential Production & Testing Dependencies in `pubspec.yaml` - Severity: Blocker
* **Reviewer Lens:** `egm-codebase-details`
* **Affected Scope:** `lines 273–276` (`1. Configuration & Dependencies`), `lines 383–406` (`Verification Plan`), `line 351`, `lines 366, 375`
* **Discrepancy Description**: The dependency specification in line 275 omits several packages required by the implementation plan and verification tests:
  1. `bloc_test`: Mandated by Section 2 of the Verification Plan (`bloc_test`, lines 394–401), but absent from `pubspec.yaml`.
  2. `mocktail` (or `mockito`): Unit and widget tests (lines 390–406) mandate mocking repositories and cubits, but no mocking package is included in `dev_dependencies`.
  3. `url_launcher`: Required by `PledgeCubit` (line 351: "map launch intents"), `RequestDetailsScreen` (line 366: "hospital phone CTA"), and `HospitalsDirectoryScreen` (line 375: "quick call and navigation triggers"). Flutter cannot launch dialer (`tel:`) or map intents (`https://maps.google.com/...`) without `url_launcher`.
  4. Missing functional/sealed Result representation: Lines 280 and 392 mandate `Result`/`Either` returning `Right(RequestAcceptance)`, yet neither `dartz`/`fpdart` is added, nor is a native sealed `Result` file declared.
* **Rationale & Recommendation**: Update line 275 to specify all required runtime and dev dependencies:
  - `dependencies`: add `url_launcher: ^6.3.0`
  - `dev_dependencies`: add `bloc_test: ^9.1.7` and `mocktail: ^1.0.4`
  - Core error handling: Add `lib/core/error/result.dart` (native Dart 3 sealed class `Result<T>`) rather than pulling in external monad packages.

---

### 3. Contradictory Error Handling Pattern (`Either` / `Right` vs. Native Dart 3 Sealed `Result`) - Severity: Major
* **Reviewer Lens:** `egm-codebase-details`
* **Affected Scope:** `lines 278–283` (`2. Core Layer`), `line 392` (`Verification Plan`)
* **Discrepancy Description**: Line 280 specifies returning domain failures via `Result`/`Either` pattern, and line 392 expects `Right(RequestAcceptance)`. However, only `failures.dart` and `exceptions.dart` are listed in the Core Layer; there is no `result.dart` or `either.dart`. Stage 8 Intermediate Zoom-Out explicitly directed the removal of Haskell-style `dartz`/`fpdart` packages in favor of native Dart 3 sealed classes (`Result<T>`). Testing `Right(...)` contradicts this directive and fails to compile without `dartz`.
* **Rationale & Recommendation**: Eliminate all references to `Either` and `Right()`. Add `lib/core/error/result.dart` defining a native Dart 3 sealed class:
  ```dart
  sealed class Result<T> {
    const Result();
  }
  final class Success<T> extends Result<T> {
    final T data;
    const Success(this.data);
  }
  final class FailureResult<T> extends Result<T> {
    final Failure failure;
    const FailureResult(this.failure);
  }
  ```
  Update line 392 to test `Result.success(RequestAcceptanceEntity)` and line 280 to reference `Result<T>`.

---

### 4. Missing Verification Coverage for Female Donors, Boundary Ages, and Repository Failures - Severity: Major
* **Reviewer Lens:** `egm-implementation-readiness`
* **Affected Scope:** `lines 385–406` (`Verification Plan`)
* **Discrepancy Description**: The verification plan contains major testing gaps:
  1. `eligibility_calculator_test.dart` (lines 386–389) tests only male donors at 90 days. Line 294 specifies gender recovery constraints (90 vs. 120 days). Female donor recovery (120 days), first-time donors (null `lastDonationDate`), and boundary ages (< 18, exactly 18, and > 65) are untested.
  2. `pledge_blood_donation_usecase_test.dart` (lines 390–393) only tests eligibility blocking and happy path. It omits testing repository network/server failures, and capacity exhaustion (`unitsPledged >= unitsNeeded`).
  3. `case_feed_cubit_test.dart` (lines 395–398) tests basic loaded/error states, but omits governorate filtering, empty states (`CaseFeedEmpty`), and pull-to-refresh logic.
  4. Widget tests cover only `HomeFeedScreen` in loaded state; `RequestDetailsScreen`, `CreateRequestWizardScreen`, and error/loading states are unverified.
* **Rationale & Recommendation**: Expand the test suite in Section 383–406:
  - Add female donor eligibility test cases: female donor at 90 days -> ineligible (30 days remaining); female donor at 120 days -> eligible.
  - Add first-time donor test case (`lastDonationDate == null` -> eligible).
  - Add repository failure propagation test for `pledge_blood_donation_usecase_test.dart`.
  - Add widget tests for `CaseFeedError` retry button and `RequestDetailsScreen` pledge submission flow.

---

### 5. State Management Fragmentation and Missing Cubits for Screen Inventory - Severity: Major
* **Reviewer Lens:** `egm-implementation-readiness`
* **Affected Scope:** `lines 347–376` (`5. Presentation Layer`)
* **Discrepancy Description**:
  1. Standalone `PledgeCubit` (line 350) is retained despite Zoom-Out recommendations to merge the pledge action into `RequestDetailsCubit`. This creates state drift between the feed, details, and pledge states.
  2. `RequestDetailsScreen` (line 365) has no corresponding `RequestDetailsCubit` listed in the implementation plan to load case details or manage case state.
  3. `HospitalsDirectoryScreen` (line 374) has no `HospitalDirectoryCubit` listed to query or filter hospitals.
  4. `AuthCubit` is omitted from the file list, despite `app_router.dart` (line 297) requiring authentication route guards.
* **Rationale & Recommendation**: Consolidate pledge mutation into `RequestDetailsCubit` (`lib/presentation/cubits/request_details/request_details_cubit.dart`). Add `HospitalDirectoryCubit` and `AuthCubit` (or a lightweight `SessionCubit`) to the Presentation Layer file inventory to support their respective screens and router guards.

---

### 6. Clean Architecture Boundary Violations Retained in Detailed Implementation Plan - Severity: Major
* **Reviewer Lens:** `egm-implementation-readiness`
* **Affected Scope:** `lines 293–295` (`Core Layer`), `lines 322–324` (`Domain Layer`)
* **Discrepancy Description**:
  1. `eligibility_calculator.dart` is placed under `lib/core/utils/` (line 293). Clinical eligibility rules enforcing donor recovery intervals are healthcare domain logic, not platform utilities.
  2. `BloodCompatibilityEngine` (required for matching blood donor groups to requests) is omitted from the target files list entirely.
  3. `get_urgent_requests_usecase.dart` (line 322) is a pass-through forwarding class with zero business logic, violating the simplification mandates established in Stage 5 and Stage 8 Zoom-Out reviews.
* **Rationale & Recommendation**: Relocate clinical rules from `lib/core/utils/` to `lib/domain/rules/` (`eligibility_rules.dart`, `blood_compatibility_rules.dart`). Prune pass-through usecases: allow `CaseFeedCubit` to inject and query `BloodRequestRepository` directly, reserving UseCases strictly for multi-step domain orchestrations like `PledgeBloodDonationUseCase`.

---

### 7. Codebase Theme Symbol Mismatch (`AppTheme` vs `MonqizTheme`) - Severity: Major
* **Reviewer Lens:** `egm-codebase-details`
* **Affected Scope:** `line 379` (`lib/main.dart Modify`)
* **Discrepancy Description**: Line 379 specifies wrapping the app in `AppTheme.lightTheme`. In the active codebase (`monqiz_app/lib/core/theme/app_theme.dart`), the class is named `MonqizTheme` (`MonqizTheme.lightTheme`), exported via `monqiz_app/lib/core/design_system/design_system.dart`. Referencing `AppTheme` results in a compilation failure (`Undefined name 'AppTheme'`).
* **Rationale & Recommendation**: Change `AppTheme.lightTheme` to `MonqizTheme.lightTheme` in line 379 to match the existing codebase implementation.

---

### 8. Inconsistent Project Root Paths and Working Directory in Verification Commands - Severity: Nit
* **Reviewer Lens:** `egm-codebase-details`
* **Affected Scope:** `line 273`, `lines 277–380`, `lines 407–414`
* **Discrepancy Description**: Line 273 refers to `monqiz_app/pubspec.yaml`, whereas lines 277–380 use `lib/...` and `test/...` without the `monqiz_app/` directory prefix. In the workspace (`d:\My_Projects\monqiz\`), executing `flutter analyze` or `flutter test` from the workspace root fails because `pubspec.yaml` is nested inside `monqiz_app/`.
* **Rationale & Recommendation**: Normalize all file paths with `monqiz_app/` prefix (e.g., `monqiz_app/lib/core/...`), and update verification commands to specify the working directory:
  ```bash
  cd monqiz_app && flutter analyze
  cd monqiz_app && flutter test
  ```

---

### 9. Entity Naming and Interface Prefix Inconsistencies - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `lines 310–312`, `line 326`, `line 343`, `line 392`
* **Discrepancy Description**: In line 310, the entity file is named `request_acceptance_entity.dart`, but in line 326 it is referred to as `RequestAcceptance`, in line 392 as `Right(RequestAcceptance)`, and in line 133 as `PledgeEntity`. Furthermore, line 343 refers to implementing `IBloodRequestRepository` with a C#-style `I` prefix, while line 316 names the contract file `blood_request_repository.dart`.
* **Rationale & Recommendation**: Standardize domain entity naming as `RequestAcceptanceEntity` across all use cases and tests. Adopt Effective Dart guidelines for repository interfaces (`BloodRequestRepository` implemented by `BloodRequestRepositoryImpl`) without `I` prefixes.

---

### 10. Offline Storage Implementation Omitted from Implementation Tasks - Severity: Nit
* **Reviewer Lens:** `egm-implementation-readiness`
* **Affected Scope:** `line 264` (`NFRs`), `lines 270–345` (`Target Files`)
* **Discrepancy Description**: NFR line 264 mandates that accredited hospital directories and emergency hotline numbers (19888) remain readable offline when network connectivity drops. However, no offline storage mechanism, static asset file (`assets/data/hospitals.json`), or local data source is listed in the Target Files section.
* **Rationale & Recommendation**: Add `monqiz_app/assets/data/hospitals_fallback.json` to the target files, register it in `pubspec.yaml` assets, and implement an asset-backed fallback inside `HospitalRepositoryImpl` to satisfy the offline requirement without external database dependencies.

---

### 11. Trailing Document Generation Artifact - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `line 418`
* **Discrepancy Description**: Line 418 ends with an unformatted metadata artifact `*Drafted with EGM*`.
* **Rationale & Recommendation**: Remove the trailing artifact or format it into the document header metadata.
