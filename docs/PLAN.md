# PLAN: Next Evolutionary Steps for Time Factory

> **Project Goal:** Elevate the current playable loop into a production-ready game by finalizing persistence, core retention loops (Prestige), and player onboarding.
> **Date:** Current Session

---

## 🎼 Orchestration Strategy

This roadmap requires a coordinated multi-agent orchestration. The plan is broken down into thematic "Features", each with specific small wins and recommended agents/skills.

| Phase | Feature Focus | Primary Agents |
|-------|---------------|----------------|
| **Phase 1** | Paradox (Prestige) UI | `frontend-specialist`, `game-developer`, `mobile-developer` |
| **Phase 2** | Offline Polish | `frontend-specialist`, `game-developer` |

---

## 🌀 PHASE 1: The Paradox Event (Prestige System)
*The core loop reset mechanic needs a visual and mechanical payoff.*

### WIN 1.1 — Prestige Reset Logic Validation
**Agent:** `game-developer` + `test-engineer`
**Skills:** `game-development`, `tdd-workflow`
**Workflow:** `/test`
- [x] **Task:** Write unit tests ensuring that triggering a Paradox correctly resets `chronoEnergy`, `workers`, `stations`, and `unlockedEras`, while preserving `timeShards`, `inventory`, and `paradoxPoints`.
- [x] **Task:** Verify `prestigePointsToGain` scaling math.

### WIN 1.2 — Paradox Upgrade Tree UI
**Agent:** `frontend-specialist` + `mobile-developer`
**Skills:** `frontend-design`, `mobile-design`
**Workflow:** `/enhance`
- [x] **Task:** Build the `ParadoxScreen`. A visually distinct UI (e.g., deeply distorted neon/cyber void theme) where players spend Paradox Points on the `PrestigeUpgrade` enum (Chrono Mastery, Rift Stability, etc.).
- [x] **Task:** Implement the "Initiate Parodox" confirmation sequence with heavy haptic feedback and epic screen shakes/animations.

---

## 💤 PHASE 3: Offline Progress Polish
*Make the player feel rewarded for coming back.*

### WIN 3.1 — "Welcome Back" Diagnostics Screen
**Agent:** `mobile-developer`
**Skills:** `mobile-design`
**Workflow:** `/enhance`
- [x] **Task:** Currently, offline progress just happens. We need a rich `OfflineSummaryDialog` that plays on app resume.
- [x] **Task:** Visually break down the offline gains: 
  - Base Generation
  - Offline Efficiency Penalty/Bonus (e.g., 10% base + Tech buffs)
  - Time Elapsed (Capped at maximum allowed offline hours)

---

## 🎓 PHASE 4: Onboarding & Tutorial
*Reduce early-game churn by guiding the player through the first era.*

### WIN 4.1 — Interactive Overlay System
**Agent:** `frontend-specialist`
**Skills:** `frontend-design`
**Workflow:** `/enhance`
- **Task:** Extend the `tutorialStep` tracking in `GameState`.
- **Task:** Create glowing overlay spotlights on key UI elements:
  1. "Tap to gather initial energy"
  2. "Hire your first worker"
  3. "Assign worker to a Chamber"
  4. "Upgrade Tech to advance Era"
- **Task:** Disable certain UI buttons until their respective tutorial step is active to prevent player confusion.

---

## 🏁 How to Proceed
If you approve this plan, we will transition to **PHASE 2: IMPLEMENTATION** (Orchestration Mode) and begin executing **Phase 1 (Cloud Save)** or any other Phase you prioritize first!
