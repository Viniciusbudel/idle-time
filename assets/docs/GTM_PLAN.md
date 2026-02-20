# 🚀 Go-to-Market Plan: Time Factory — Paradox Industries

🤖 **Agents:** `@project-planner` · `@frontend-specialist` · `@backend-specialist` · `@mobile-developer` · `@game-developer`

---

## Executive Summary

Time Factory depends on a dark cyberpunk-steampunk aesthetic. The core loop works, but significant polish and content depth ar/ needed for market readiness.

**Current State:** Pre-alpha (v1.0.0+1)
**Target:** Google Play Store + (later) Apple App Store

---

## 📊 Feature Audit — What Exists Today

### ✅ Working Features

| Feature | Screen | Status |
|---------|--------|--------|
| CE production loop | Factory | ✅ Working |
| Manual tap to earn | Factory | ✅ Working |
| Worker hiring (CE cost) | Gacha | ✅ Working |
| Worker summoning (Shard cost) | Gacha | ✅ Working |
| Worker deploy/undeploy to stations | Chambers | ✅ Working |
| Station purchase & upgrade | Chambers | ✅ Working |
| Station merging | Chambers | ✅ Working |
| Worker merging (3→1 rarity up) | Gacha | ✅ Working |
| Tech tree per era | Tech | ✅ Working |
| Prestige (timeline collapse) | Prestige | ✅ Basic |
| Era advancement (Victorian → Roaring 20s) | Tech | ✅ Working |
| Offline earnings | System | ✅ Fixed |
| Time warp visually | Factory | ✅ New |
| Auto-click visually | Factory | ✅ New |
| Auto-create station on era advance | System | ✅ New |
| i18n (EN + PT) | All | ✅ Working |
| Auto-save (30s interval) | System | ✅ Working |
| Paradox system | Factory | ✅ Basic |
| Worker refit | Command Center | ✅ Exists |

### ⚠️ Partial / Needs Work

| Feature | Issue |
|---------|-------|
| Prestige upgrade shop | Prestige | ✅ Working |
| Command Center | Command Center | ✅ Working |
| Worker avatars | Victorian icons present ✅ in `assets/images/icons`. Roaring 20s+ missing. |
| Sound effects | `assets/sfx/` is empty |
| Music | `assets/music/` is empty |
| Eras 3-8 | Enums defined but no content (no techs, no stations, no visuals) |
| Paradox events | Basic trigger/end — no mini-game or meaningful interaction |
| Test coverage | ~5 test files, no widget tests, no integration tests |

### ❌ Missing Entirely

| Feature | Priority |
|---------|----------|
| Tutorial / Onboarding | ✅ Working |
| Settings screen | ✅ Working |
| Achievements / Milestones | 🟡 High |
| Notifications (offline earnings ready) | 🟡 High |
| Analytics (Firebase/Amplitude) | 🟡 High |
| Monetization (ads / IAP) | 🟡 High |
| Store listing (icon, screenshots, description) | 🔴 Critical |
| App icon & splash screen | 🔴 Critical |
| Haptic feedback | 🟢 Medium |
| Rate app prompt | 🟢 Medium |
| Cloud save | 🟢 Medium |
| Daily login rewards | 🟢 Medium |
| Leaderboards | 🔵 Low |
| Social sharing | 🔵 Low |

---

## 🐛 Known Bugs & Issues

| # | Bug | Severity | File(s) |
|---|-----|----------|---------|
| 1 | ~~Offline reward bugs~~ | ~~Critical~~ | ~~`main.dart`, `game_state.dart`~~ ✅ Fixed |
| 2 | ~~Command Center efficiency is mocked~~ | ~~Medium~~ | ~~`command_center_tab.dart`~~ ✅ Fixed |
| 3 | ~~Worker upgrade button does nothing~~ | ~~Medium~~ | ~~`command_center_tab.dart`~~ ✅ Fixed |
| 4 | ~~`_getWorkerStatus` returns mock data~~ | ~~Low~~ | ~~`command_center_tab.dart`~~ ✅ Fixed |
| 5 | ~~`kIsWeb` redefined locally~~ | ~~Low~~ | ~~`gacha_screen.dart`~~ ✅ Fixed |
| 6 | ~~43 `withOpacity` deprecation warnings~~ | ~~Low~~ | ~~Multiple files~~ ✅ Fixed |
| 7 | ~~Loop Reset Timer shows hardcoded `0:45`~~ | ~~Medium~~ | ~~`factory_screen.dart`~~ ✅ Removed |

---

## 🗺️ Release Roadmap

### Milestone 1: MVP Polish (2-3 weeks)
> Goal: Make the existing features work properly and feel polished

- [x] **Fix all bugs** listed above (#2-7)
- [x] **Prestige upgrade shop** — spend Paradox Points on permanent bonuses
- [x] **Settings screen** — sound toggle, language, reset progress, credits
- [x] **Tutorial / Onboarding** — 5-step guided intro explaining core loop
- [ ] **App icon & splash screen** — steampunk-themed branding
- [x] Generate **worker avatar assets** for Roaring 20s+ (Victorian done)
- [x] Replace all `withOpacity` → `withValues` across codebase
- [x] **Haptic feedback** on tap, upgrades, era advances

### Milestone 2: Content & Engagement (2-3 weeks)
> Goal: Add content depth and retention mechanics

- [x] **Achievements system** — 20+ milestones with rewards
- [/] **Daily login rewards** — 7-day cycle with escalating prizes
- [ ] **Notifications** — "Your factory earned X CE while you were away!"
- [ ] **Paradox mini-events** — interactive events during paradox spikes
- [ ] **Sound effects** — tap, upgrade, era change, prestige, gacha pull
- [ ] **Background music** — ambient tracks per era
- [ ] **Worker detail screen** — tap worker to see stats, upgrade, refit
- [x] **Content: Era 3 (Atomic Age)** (See [PLAN-atomic-age.md](file:///C:/Users/Vini_/.gemini/antigravity/brain/e0416022-556a-4168-9fb9-13279af3e501/PLAN-atomic-age.md))
    - [x] Tech Tree (Nuclear Fission, Transistors, etc.)
    - [x] Station (Nuclear Reactor)
    - [x] Assets (Backgrounds, Icons)
    - [x] Logic (Unlock via Manhattan Project)

### Milestone 3: Monetization & Analytics (1-2 weeks)
> Goal: Revenue and data-driven improvement

- [ ] **Firebase Analytics** — track screens, events, funnel
- [ ] **Rewarded video ads** — optional 2x earnings boost, free gacha pull
- [ ] **IAP: Remove ads** — one-time purchase
- [ ] **IAP: Shard packs** — Time Shard bundles
- [ ] **IAP: Starter pack** — one-time discounted bundle
- [ ] **Rate app prompt** — after 3 days, gentle ask
- [ ] **Crash reporting** — Firebase Crashlytics

### Milestone 4: Store Launch (1 week)
> Goal: Ship it

- [ ] **Store listing** — title, description, keywords, screenshots, feature graphic
- [ ] **Privacy policy** page (required for Play Store)
- [ ] **Play Store submission** — signed APK/AAB, content rating questionnaire
- [ ] **Cloud save** via Firebase Auth + Firestore (or Google Play Games)
- [ ] **Proguard/R8 rules** for release build
- [ ] **Integration tests** for critical paths (production loop, prestige, era advance)

---

## User Review Required

> [!IMPORTANT]
> **I need your input on these design decisions:**

### Q1: Monetization Strategy
Which monetization model do you prefer?
- **A — Ads only:** Rewarded video ads (optional 2x boost, free gacha)
- **B — IAP only:** Shard packs, Remove Ads pass, Starter Pack
- **C — Hybrid:** Both ads + IAP (most common for idle games)
- **D — Premium:** Paid app, no ads, no IAP

### Q2: Which Milestone to Start With?
- **A — Sequential:** M1 → M2 → M3 → M4 (safest, 6-9 weeks total)
- **B — MVP Fast-Track:** M1 + essential M4 items only (~3-4 weeks to store)
- **C — Cherry-Pick:** Tell me your top 5 priorities and I'll build around them

### Q3: Do You Want to Launch on iOS Too?
- **A — Android only** (faster, cheaper)
- **B — Android + iOS** (broader reach, needs Apple Developer account $99/yr)

### Q4: Eras Scope for Launch
All 8 eras are defined in enums but only 2 have content. How many for v1?
- **A — 2 eras** (Victorian + Roaring 20s) — ship faster
- **B — 3 eras** (+ Atomic Age) — more content for reviews
- **C — 4+ eras** — delays launch significantly

### Q5: Cloud Save / Accounts?
- **A — Local only** (simpler, ship faster)
- **B — Google Play Games** (auto-save to cloud, leaderboards)
- **C — Firebase Auth** (email/Google sign-in, cross-device sync)
