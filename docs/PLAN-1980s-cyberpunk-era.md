# PLAN: 1980s Cyberpunk Era

> **Project Goal:** Implement the highly anticipated 1980s Cyberpunk era (inspired by Blade Runner), focusing on thematic visuals, premium animations, new late-game technologies, and economic balance.
> **Project Type:** MOBILE/WEB (Flutter Cross-Platform)

---

## 🎼 Orchestration Strategy

This feature requires a coordinated multi-agent orchestration to handle the distinct aspects of the new era: visuals, logic/balance, and animations.

| Phase | Feature Focus | Primary Agents |
|-------|---------------|----------------|
| **Phase 1** | Asset Generation & Thematic UI | `frontend-specialist`, `game-developer` |
| **Phase 2** | Tech Tree & Economic Balance | `game-developer`, `test-engineer` |
| **Phase 3** | Premium Animations & Polish | `mobile-developer`, `frontend-specialist` |

---

## 🌃 PHASE 1: The Neon Sandbox (Visuals & Assets)
*Establish the core Blade Runner aesthetic for the new era.*

### WIN 1.1 — Cyberpunk Background & Environment
**Agent:** `frontend-specialist`
**Skills:** `frontend-design`, `game-art`
**Workflow:** `/enhance`
- **Task:** Generate a high-quality, Blade Runner-inspired 1980s Cyberpunk background asset. It should feature dark, rainy cityscapes, neon signs, and atmospheric depth, matching the `ThemeBackground` system.
- **Task:** Integrate the background into the project's asset pipeline (`assets/images/backgrounds/cyberpunk_80s.jpg`).
- **Task:** Verify the image scales correctly on both portrait and landscape device testing.

### WIN 1.2 — Era-Specific Worker Avatars
**Agent:** `frontend-specialist`
**Skills:** `frontend-design`, `game-art`
**Workflow:** `/enhance`
- **Task:** Generate distinct AI worker avatars for the Cyberpunk era across rarities (Common street hacker, Rare replicant model, Epic corporate operative).
- **Task:** Update the `WorkerAvatar` rendering system to pull these new era-specific icons when the worker's native era is `cyberpunk_80s`.

---

## ⚙️ PHASE 2: Neon Economy (Tech & Balance)
*Implement the underlying mechanics, stations, and tech upgrades.*

### WIN 2.1 — Cyberpunk Stations & Chamber Names
**Agent:** `game-developer`
**Skills:** `game-development`
**Workflow:** `/enhance`
- **Task:** Expand the `StationType` enum and `StationNameGenerator` to include Cyberpunk-themed stations (e.g., "Data Node", "Synth Lab", "Neon Core").
- **Task:** Define the base production rates, unlock costs, and paradox rates for these new stations in `StationData`. Ensure the cost curve scales appropriately from the Atomic Age.

### WIN 2.2 — Tech Tree Expansion
**Agent:** `game-developer` + `test-engineer`
**Skills:** `game-development`, `tdd-workflow`
**Workflow:** `/test`
- **Task:** Create new `TechType` entries specific to the 80s Cyberpunk era (e.g., "Cybernetics", "Neural Net", "Synth-Alloys").
- **Task:** Implement the cost and effect scaling for these new techs in `TechData`.
- **Task:** Write unit tests to verify that these new techs correctly apply their production, offline, or discount multipliers without breaking earlier eras.

---

## ✨ PHASE 3: Tears in Rain (Animations & Polish)
*Add premium feel with dynamic effects.*

### WIN 3.1 — Atmospheric Animations
**Agent:** `mobile-developer` + `frontend-specialist`
**Skills:** `mobile-design`, `frontend-design`
**Workflow:** `/enhance`
- **Task:** Implement a subtle CRT/scanline overlay effect that softly pulses when in the Cyberpunk era to sell the retro-futuristic vibe.
- **Task:** Add atmospheric particle effects (e.g., faint neon rain or digital static) overlaying the `FactoryScreen` specifically for this era.

### WIN 3.2 — UI Color Palettes
**Agent:** `frontend-specialist`
**Skills:** `frontend-design`
**Workflow:** `/enhance`
- **Task:** Define a specific `CyberpunkTheme` palette (e.g., Hot Magenta, Electric Cyan, Deep Purple/Black) to override the base Neon theme when the player operates within this era.
- **Task:** Ensure cards like `NeonChamberCard` react to the active era's specific accent colors.

---

## 🏁 Phase X: Final Verification
- [ ] **Lint & Types:** `dart analyze` passes cleanly.
- [ ] **Unit Tests:** `flutter test test/domain` all pass.
- [ ] **Visual Audit:** Validate that the CRT scanlines do not interfere with text legibility.
- [ ] **Balance Audit:** Confirm that the progression from Atomic Age -> Cyberpunk 80s is smooth and the CE requirements are mathematically sound.
