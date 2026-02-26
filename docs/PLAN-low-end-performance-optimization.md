# PLAN: Low-End Mobile Performance Optimization

Date: 2026-02-26  
Status: Ready for implementation

## 1. Problem Statement

Performance on less powerful phones is currently below acceptable quality, mainly on the Factory experience. The main pressure points identified are:

- frequent global state churn and broad widget rebuilds
- unnecessary Flame worker sync triggers
- duplicate automation logic writing state too often
- expensive always-on visual layers and particle systems
- oversized image and animation assets

## 2. Goals and Success Metrics

This plan uses baseline-relative targets because device classes vary.

- reduce p95 frame time (build + raster) by at least 30% from baseline
- reduce janky frames by at least 50% from baseline
- reduce peak memory usage by at least 20% from baseline
- remove obvious hitching on Factory idle flow and high-automation flow

## 3. Scope

In scope:

- performance profiling and instrumentation
- state/rebuild optimization
- game loop optimization
- graphics quality scaling for low-end devices
- asset size and texture budget optimization
- high-cost screen-specific fixes

Out of scope:

- gameplay rebalance
- new features unrelated to performance
- redesign of core game systems

## 4. Implementation Phases

### Phase 0: Baseline Profiling (0.5 day)

- define target low-end test device(s) and test scenario
- profile in Flutter profile mode with DevTools
- record baseline metrics for Factory and Expeditions

Deliverable:

- `docs/PERF-BASELINE-low-end.md`

Acceptance criteria:

- baseline table with p95 frame time, jank %, peak memory, and notes is published

### Phase 1: State Churn and Rebuild Containment (1-2 days)

- stop writing `lastTickTime` into global state every second
- reduce broad `ref.watch(gameStateProvider)` usage in top-level screens/providers
- convert high-impact watches to `select(...)`
- ensure Flame worker sync is triggered by stable worker identity changes only

Primary files:

- `lib/presentation/state/game_state_provider.dart`
- `lib/presentation/ui/pages/factory_screen.dart`
- `lib/domain/entities/game_state.dart`
- `lib/presentation/state/tech_provider.dart`

Acceptance criteria:

- no full-screen rebuild pattern driven by the 1s tick
- worker sync is not called on currency-only ticks

### Phase 2: Automation and Loop De-duplication (1 day)

- keep a single source of truth for automation CE production
- remove state-writing auto-click path from Flame update loop
- keep Flame auto-click as visual-only feedback
- cap/throttle high-frequency visual spawn logic

Primary files:

- `lib/presentation/game/time_factory_game.dart`
- `lib/presentation/state/game_state_provider.dart`
- `lib/core/constants/tech_data.dart`

Acceptance criteria:

- automation path produces correct CE and does not cause excessive state writes
- high automation does not create update-loop spikes

### Phase 3: Graphics Quality Tier and Runtime Gating (1-2 days)

- add performance mode setting (`auto`, `high`, `low`)
- in `low` mode: disable or reduce scanline/glitch intensity and worker particle complexity
- add worker visual LOD based on active worker count
- reduce background animation workload for weak devices

Primary files:

- `lib/presentation/ui/pages/settings_screen.dart`
- `lib/presentation/ui/pages/factory_screen.dart`
- `lib/presentation/ui/templates/steampunk_background.dart`
- `lib/presentation/ui/atoms/scanline_overlay.dart`
- `lib/presentation/ui/atoms/glitch_overlay.dart`
- `lib/presentation/game/components/worker_avatar.dart`

Acceptance criteria:

- low mode shows measurable frame-time and jank improvement vs high mode on same device
- visual quality remains acceptable and readable

### Phase 4: Asset Budget Reduction (1-2 days)

- downscale oversized backgrounds to practical mobile resolution targets
- resize oversized worker icons (current 2048x2048 assets are excessive for runtime usage)
- apply compression strategy (PNG optimization/WebP where safe)
- simplify or replace heavy lottie assets if required

Primary assets:

- `assets/images/backgrounds/**`
- `assets/images/icons/**`
- `assets/lottie/**`

Acceptance criteria:

- reduced app memory pressure during Factory load and play
- reduced stutter during first render and asset-heavy transitions

### Phase 5: Screen-Specific Hotspots (0.5-1 day)

- Expeditions: stop full-screen `setState()` timer refresh each second
- update only countdown widgets with localized state
- review achievement checker cadence and avoid unnecessary heavy recalculation

Primary files:

- `lib/presentation/ui/pages/expeditions_screen.dart`
- `lib/presentation/state/achievement_provider.dart`
- `lib/presentation/ui/molecules/achievement_listener.dart`

Acceptance criteria:

- expeditions screen does not rebuild full content tree every second
- achievement checks are limited to meaningful state changes

### Phase 6: Validation and Release Gate (0.5 day)

- re-profile using the same scenario and compare to baseline
- verify no regressions in core gameplay and persistence
- document before/after metrics and final recommendation

Deliverable:

- `docs/PERF-RESULTS-low-end.md`

Acceptance criteria:

- target metrics in Section 2 are achieved or documented with explicit tradeoff notes

## 5. Task Execution Order

Execute in this order:

1. Phase 0 baseline
2. Phase 1 state containment
3. Phase 2 automation cleanup
4. Phase 3 graphics mode
5. Phase 4 assets
6. Phase 5 screen hotspots
7. Phase 6 validation

## 6. Risks and Mitigations

- risk: visual downgrade harms UX
- mitigation: keep `high` mode available and default to `auto`

- risk: production math divergence after automation changes
- mitigation: validate with unit tests and snapshot comparisons

- risk: compressed assets cause quality artifacts
- mitigation: define per-asset quality thresholds and review on target devices

## 7. Definition of Done

- baseline and final performance reports exist in `docs/`
- low-end performance targets are met or gaps are explicitly documented
- no critical gameplay regression in manual click, automation, save/load, expeditions
- implementation can be shipped behind a safe default (`auto` performance mode)
