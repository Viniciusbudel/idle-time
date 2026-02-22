# ARCHIVE: Time Factory GTM Feature Plan

Date: 2026-02-22
Scope: Whole-app product + technical audit and next-feature plan to reach GTM.

## 1) Current App Snapshot (What Exists Today)

### Core game already implemented
- Idle loop with manual tap, passive production, stations, worker hiring/summon, worker merge, era progression.
- Prestige/paradox systems with upgrade spend.
- Temporal artifact system: drops, inventory, equip/unequip, worker power impact.
- Daily login rewards and achievements.
- Offline earnings calculation and "welcome back" dialog.
- Local persistence via `SharedPreferences`.
- Local notifications for re-engagement.
- Multiple era themes and substantial UI polish.
- Localization in English and Portuguese.

### Codebase and quality status
- `lib/` has broad domain/usecase separation and Riverpod state architecture.
- Test suite is present and currently passing (`flutter test` passed with 52 tests).
- Static analysis has many warnings/info items (notably deprecated `withOpacity`, Flame deprecations, unused code/imports).

### GTM readiness gaps (critical)
- No analytics, no crash reporting, no event schema, no A/B hooks.
- No monetization stack (IAP/ads/store products/economy safeguards).
- No backend/live-ops layer (events, remote config, offers, balancing flags, cloud save).
- Release config still template-grade:
  - Android package id: `com.example.idle`
  - Debug signing used for release type
  - App naming/branding placeholders in Android/iOS/Web metadata
- No legal/compliance surface (privacy policy, terms, consent flow).
- Inconsistent product metadata (e.g., pubspec version vs in-app settings version string).
- Some stale debugging/testing artifacts in repo (`test_output.txt` history includes failing run from old state).

## 2) GTM Outcome Definition

Target GTM = "public soft launch ready":
- Reliable release builds on Android + iOS.
- Instrumented retention funnel (D0/D1/D7), economy events, and crash/error visibility.
- Monetization MVP live and measurable.
- Core early-game loop tuned to reduce first-session churn.
- Live balancing updates without full binary redeploy.

## 3) Product Strategy for Next Features

### North-star loop
- Session start -> claim daily/login reward -> perform 1 meaningful progression action -> optional spend/ad engagement -> leave with next-session hook.

### KPI targets for soft launch
- D1 retention: >= 30%
- D7 retention: >= 10%
- Tutorial completion: >= 70%
- Crash-free users: >= 99.5%
- ARPDAU baseline: establish and grow week over week

## 4) Feature Roadmap to GTM (With Small Wins)

## Phase 0 - GTM Foundations (Must Do First)

### 0.1 Release and identity hardening
- Replace package/bundle IDs and app labels across Android/iOS/Web.
- Configure real release signing and CI release profile.
- Align versioning in pubspec, settings UI, and store metadata.

Small wins:
- [ ] Set Android `applicationId` and iOS bundle id to production values.
- [ ] Replace `"idle"` names in manifest/plist/web manifest with branded product names.
- [ ] Add build flavor notes in `README` or `docs`.
- [ ] Remove debug signing from release build config.

### 0.2 Observability and analytics baseline
- Add analytics SDK + crash reporting.
- Create event taxonomy for core funnel and economy.

Small wins:
- [ ] Track events: app_open, session_start/end, tutorial_step, summon, hire, merge, tech_buy, era_advance, prestige, offline_claim.
- [ ] Add crash logging + handled exception logging.
- [ ] Add lightweight debug overlay to verify event emission in dev builds.

### 0.3 Compliance and trust basics
- Add privacy policy/terms links in Settings.
- Add notification permission rationale copy and consent-friendly flow.

Small wins:
- [ ] Add "Privacy" and "Terms" entries to `SettingsScreen`.
- [ ] Add first-run permission prompt timing rule (do not ask at cold start immediately).
- [ ] Create "Data deletion / reset" copy aligned with legal language.

## Phase 1 - First-Session Retention and Clarity

### 1.1 Tutorial and early progression cleanup
- Current tutorial scaffolding exists; finish strict progression UX and reduce confusion.

Small wins:
- [ ] Gate key actions by tutorial step where needed.
- [ ] Add explicit "next action" CTA card for the first 10 minutes.
- [ ] Add fail-safe tutorial skip + restore.
- [ ] Add tutorial completion analytics event and drop-off dashboard.

### 1.2 Economy readability and player feedback
- Improve legibility of why production changed and what to do next.

Small wins:
- [ ] Add persistent "production breakdown" panel (base/tech/artifact/station bonuses).
- [ ] Add "best next upgrade" suggestion chip.
- [ ] Add clearer inventory-full messaging and quick action (scrap/sell planned hook).

### 1.3 Resolve known UX debt
- Command Center still has worker-detail navigation TODO.

Small wins:
- [ ] Wire `CommandCenterTab` upgrade action to worker detail/equip flow.
- [ ] Standardize terminology ("hire", "summon", "unit", "worker") across screens.

## Phase 2 - Monetization MVP + Live Ops Control

### 2.1 Monetization v1 (non-pay-to-win baseline)
- Offer convenience/value purchases aligned with idle genre norms.

Small wins:
- [ ] Add rewarded video placeholder flow (double offline reward OR bonus shards).
- [ ] Add starter IAP pack (shards + cosmetic/boost) with strict balancing cap.
- [ ] Add no-ads / supporter SKU if ad layer is introduced.
- [ ] Instrument conversion events per placement.

### 2.2 Live tuning capability
- Add remote-config style multipliers for drop rates, costs, and event timing.

Small wins:
- [ ] Externalize configurable values: anomaly spawn interval, reward multipliers, offer prices.
- [ ] Add safe defaults in code if remote fetch fails.
- [ ] Add server timestamp usage for daily-reward anti-time-travel integrity (if backend introduced).

## Phase 3 - Mid-Game Content for D7 and Beyond

### 3.1 Era expansion and content cadence
- Existing plans already cover additional era content; convert into release cadence.

Small wins:
- [ ] Ship one "mini content patch" per 2-3 weeks (new tech nodes + one station behavior twist).
- [ ] Add event modifier week (e.g., increased anomaly spawn).
- [ ] Add one mastery objective chain per era for long-tail goals.

### 3.2 Meta progression and social proof
- Strengthen player return reasons and long-term goals.

Small wins:
- [ ] Add streak recovery token (once/week).
- [ ] Add milestone profile badges tied to achievements.
- [ ] Add optional leaderboard-ready event logging schema (even before live leaderboard launch).

## Phase 4 - Soft Launch Operations

### 4.1 Build pipeline and release ops
Small wins:
- [ ] Add CI steps: format/lint/test/build artifacts.
- [ ] Enforce "no new warnings" gate for touched files.
- [ ] Create release checklist doc with rollback steps.

### 4.2 Soft launch playbook
Small wins:
- [ ] Launch in one pilot market first.
- [ ] Run 2 balancing updates in first 14 days.
- [ ] Weekly review ritual: retention funnel, economy inflation, conversion, crash clusters.

## 5) Suggested 6-Week Execution Order

### Weeks 1-2
- Phase 0 complete (release identity + analytics + compliance baseline).
- Phase 1.1 tutorial fixes.

### Weeks 3-4
- Phase 1.2 and 1.3 UX clarity + TODO debt closure.
- Phase 2.1 monetization MVP scaffolding.

### Weeks 5-6
- Phase 2.2 live tuning control.
- Phase 4 release pipeline + soft launch prep.

## 6) Priority Backlog (Top 15 Small Wins)

1. Replace production package/bundle IDs.
2. Configure release signing (remove debug release signing).
3. Add crash reporting SDK.
4. Add core event analytics for progression funnel.
5. Add privacy/terms entries and links in settings.
6. Fix `CommandCenterTab` worker detail navigation TODO.
7. Add tutorial completion/drop-off instrumentation.
8. Add production breakdown UI block.
9. Add "best next action" recommendation in HUD.
10. Add rewarded-offline bonus flow.
11. Add first IAP SKU and purchase telemetry.
12. Externalize balancing constants for remote tuning.
13. Standardize app version display in settings.
14. Clean stale debug artifacts and align QA documentation.
15. Reduce analyzer warnings in touched modules as a policy gate.

## 7) Risks and Mitigations

- Risk: Economy inflation breaks progression pacing.
  - Mitigation: Ship remote-config multipliers + weekly balance cadence.
- Risk: Poor attribution of retention changes.
  - Mitigation: Event taxonomy before major feature rollout.
- Risk: Store rejection (metadata/compliance).
  - Mitigation: finalize legal links, permission rationale, and release checklist before submission.
- Risk: Too many parallel initiatives before instrumentation.
  - Mitigation: freeze new major content until Phase 0 metrics pipeline is live.

## 8) Definition of GTM Ready (Exit Criteria)

- Release candidates signed and store-preparable for Android/iOS.
- Core telemetry dashboards answering: retention, progression bottlenecks, monetization conversion.
- Monetization MVP live with kill-switch or remote-disable path.
- Critical UX debt closed in early-game onboarding and worker management flow.
- Operational plan documented for first 30 days post-launch.

