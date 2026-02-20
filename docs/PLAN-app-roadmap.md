# Roadmap and Step-by-Step Implementation Guide

## Overview
This plan outlines the step-by-step execution to take the app from its current state to a fully polished, market-ready release. It focuses on completing **Milestone 2 (Content & Engagement)**, **Milestone 3 (Monetization & Analytics)**, and **Milestone 4 (Store Launch)**. 

## Project Type
MOBILE (Flutter + Flame)

## Success Criteria
- Daily login rewards, notifications, and worker details are fully implemented.
- Sound effects and background music are integrated.
- Firebase Analytics and Crashlytics are actively monitoring app health.
- Monetization (ads/IAP) is fully functional.
- The app successfully builds with Proguard/R8 and is ready for the Play Store.

## Tech Stack
- **Framework:** Flutter
- **Game Engine:** Flame
- **State Management:** Riverpod
- **Backend/Analytics:** Firebase (Analytics, Crashlytics, Auth/Firestore for Cloud Save)
- **Audio:** flame_audio / audioplayers

## Task Breakdown

### 1. Finish Milestone 2: Content & Engagement

**Task 1.1: Complete Daily Login Rewards**
- [x] **Agent:** `@mobile-developer`
- [x] **Skills:** `app-builder`, `clean-code`
- [x] **INPUT:** Use the existing `daily_login_dialog.dart` and internal login tracking logic.
- [x] **OUTPUT:** A functional daily login system that rewards players for consecutive days (e.g., CE, Shards, or Workers).
- [x] **VERIFY:** Change device time or mock time progression -> Verify prompt appears -> Verify rewards are added to state.

**Task 1.2: Implement Local Notifications**
- **Agent:** `@mobile-developer`
- **Skills:** `app-builder`
- **INPUT:** Integrate `flutter_local_notifications`.
- **OUTPUT:** Notifications trigger when offline earnings reach capacity or a specific event occurs.
- **VERIFY:** Trigger a mock offline earnings event -> App sends local notification -> Tap notification opens app.

**Task 1.3: Audio Implementation (SFX & Music)**
- **Agent:** `@game-developer`
- **Skills:** `flame-audio`
- **INPUT:** Source/generate audio files for `assets/sfx/` and `assets/music/`.
- **OUTPUT:** Audio manager playing ambient music per era and SFX on UI taps, upgrades, and prestige.
- **VERIFY:** Build app -> Toggle sound in settings -> Verify audio plays and stops appropriately.

**Task 1.4: Worker Detail Screen**
- **Agent:** `@mobile-developer`
- **Skills:** `frontend-design`, `clean-code`
- **INPUT:** Existing worker data models.
- **OUTPUT:** A bottom sheet or dialog showing worker stats, upgrade costs, and refit options.
- **VERIFY:** Tap worker in Chamber -> Detail screen opens -> Interactions update game state.

**Task 1.5: Paradox Mini-events**
- **Agent:** `@game-developer`
- **Skills:** `game-development`
- **INPUT:** Existing Paradox triggering system.
- **OUTPUT:** An active mini-game (e.g., tap anomaly to contain it) during paradox spikes.
- **VERIFY:** Force paradox spike -> Mini-game starts -> Success/Failure states yield correct outcome.

---

### 2. Milestone 3: Monetization & Analytics

**Task 2.1: Firebase Analytics & Crashlytics**
- **Agent:** `@mobile-developer`
- **Skills:** `firebase-integration`
- **INPUT:** Configure Firebase project for Android/iOS.
- **OUTPUT:** App logs custom events (era advanced, gacha pulled) and captures fatal/non-fatal crashes.
- **VERIFY:** Trigger test crash -> Check Crashlytics console. Log event -> Check Analytics DebugView.

**Task 2.2: Ad Integration (Rewarded)**
- **Agent:** `@mobile-developer`
- **Skills:** `monetization`
- **INPUT:** Integrate `google_mobile_ads`.
- **OUTPUT:** Optional UI buttons for "Watch Ad for 2x Earnings" and "Watch Ad for Free Gacha".
- **VERIFY:** Load test ad -> Watch ad -> Verify reward callback executes.

**Task 2.3: In-App Purchases (IAP)**
- **Agent:** `@mobile-developer`
- **Skills:** `monetization`
- **INPUT:** Integrate `in_app_purchase`. Configure SKUs in Play Console.
- **OUTPUT:** Shop screen with "Remove Ads", "Starter Pack", and "Shard Packs".
- **VERIFY:** Perform test purchase (sandbox) -> Verify entitlement is granted and persisted.

**Task 2.4: Rate App Prompt**
- **Agent:** `@mobile-developer`
- **Skills:** `app-builder`
- **INPUT:** Integrate `in_app_review`.
- **OUTPUT:** Gentle prompt after the user reaches Era 2 or plays for 3 cumulative days.
- **VERIFY:** Mock trigger condition -> Verify system review dialog appears.

---

### 3. Milestone 4: Store Launch Readiness

**Task 3.1: Cloud Save Configuration**
- **Agent:** `@backend-specialist` + `@mobile-developer`
- **Skills:** `firebase-integration`
- **INPUT:** Firebase Auth (Anonymous + Google/Apple Sign-in) and Firestore.
- **OUTPUT:** User data syncs to the cloud securely.
- **VERIFY:** Play on Device A -> Sync -> Load on Device B -> Verify identical state.

**Task 3.2: Integration Tests & CI/CD**
- **Agent:** `@test-engineer`
- **Skills:** `testing-patterns`
- **INPUT:** Existing game state and critical path flows.
- **OUTPUT:** Widget and integration tests covering prestige, era transition, and offline calculation.
- **VERIFY:** Run `flutter test integration_test` -> All pass green.

**Task 3.3: Release Build Configuration (Proguard/R8)**
- **Agent:** `@mobile-developer`
- **Skills:** `deployment-procedures`
- **INPUT:** Configure `proguard-rules.pro` and signing keys.
- **OUTPUT:** A signed localized release App Bundle (`.aab`).
- **VERIFY:** Build release -> Run minified app on physical device -> Ensure no missing classes/crashes.

## Phase X: Verification
- [ ] Code is formatted and linted (`flutter analyze`).
- [ ] No `withOpacity` usages remaining.
- [ ] App starts cleanly with no critical exceptions in console.
- [ ] E2E or Integration Tests pass for the production loop.
- [ ] Release APK/AAB builds successfully.
