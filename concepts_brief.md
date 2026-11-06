# Monqiz Mobile App Architecture & Screen Flow

* **Author:** Khalid Omr
* **Date:** 2026-11-06

## Overview

Monqiz (منقذ) is an emergency blood donation mobile application (Flutter, targeting iOS & Android) built to bridge critical blood shortages in Egypt and the MENA region. The mobile client interfaces with an existing .NET 9 Web API backend mapped directly to the domain schema (`User`, `Address`, `Hospital`, `Request`, `DonationAddress`, `RequestAcceptance`). The platform connects two primary user roles—urgent blood requesters (patients, relatives) and voluntary donors—under accredited hospital supervision, enforcing clinical safety intervals and local geofenced case matching.

## Analysis

### 1. Data Contract Alignment with ERD
* **User Entity:** Captures identity, contact (`Email`, `PhoneNumber`), physical attributes (`BloodType`, `Gender`, `BirthDate`), and donation cadence (`LastDonationDate`, `Status`).
* **Request & Hospital Entities:** Blood requests (`UnitsNeeded`, `BloodType`, `RequiredDate`, `Status`, `Details`) are bound to a verified `Hospital` (`Name`, `LocationUrl`, `PhoneNumber`, `AddressId`).
* **Pledge State Machine:** `RequestAcceptance` models the donor fulfillment lifecycle (`Pending` -> `Accepted` -> `Completed` / `Cancelled`).
* **Geographic Coverage:** `Address` and `DonationAddress` enable M:N matching between donors and preferred donation zones (Governorate / City).

### 2. Mobile Architecture & Design System Fit
* **Design Tokens & Atoms:** The app already includes a custom Flutter design system in `lib/core/design_system` (RTL Arabic-first, Cairo/Tajawal fonts, `AppColors.primary` emergency crimson, healthcare indicators, `MonqizBloodRequestCard`, and form inputs).
* **Architecture Strategy:** Feature-First layered architecture (Presentation -> Domain -> Data -> Core) with reactive state management (`flutter_bloc` or `riverpod`).

## Goals vs. Non-Goals

### In-Scope Goals
* **Emergency Discovery Feed:** Real-time feed of urgent blood requests filtered by compatible blood types and selected governorates/cities.
* **Smart Eligibility Calculator:** On-device computation of donor donation interval eligibility based on `LastDonationDate`, gender, and age.
* **Request Creation Workflow:** Streamlined, multi-step emergency posting workflow selecting accredited hospital, required units, and urgency timeframe.
* **Pledge & Routing Flow:** Direct pledge commitment (`RequestAcceptance`) with 1-tap navigation to hospital location (`LocationUrl`) and direct phone dialing.
* **Donor Passport & History:** Digital donor profile tracking pledge statuses, blood type verification badge, and past donation records.

### Out-of-Scope Non-Goals
* In-app medical testing or direct electronic health record (EHR) sync.
* Direct hospital administration portal (hospital management is handled via the separate web portal).
* In-app blood transport logistics or dispatch delivery tracking.

## Alternatives Weighed

* **Generic blood matching vs. Hospital-supervised requests:** Rejected unverified peer-to-peer requests to avoid black-market scams and safety risks; all requests must bind to a verified `Hospital` entity per ERD architecture.
* **Single-step request form vs. Stepped wizard:** Single-step forms caused cognitive overload during emergencies; a staged 3-step bottom sheet / stepper was prioritized for speed under pressure.

## Key Decisions & Staging for Next Steps

* **State Management Selection:** Finalize between `flutter_bloc` and `riverpod`.
* **Push Notification & Geofencing Pipeline:** Define real-time alert mechanics for urgent blood requests matching donor blood group and governorate.
* **Offline-first Caching:** Define local cache strategy for hospital directory and emergency hotline access during connectivity outages.
