# PLAN: Roaring 20s Era Unlock (Art Deco Assembly Line)

This plan outlines the implementation of the "Roaring 20s" era, focusing on the refined transition mechanics requested by the user.

## Phase 1: Domain & Data
- [ ] **Difficulty Scaling**: Increase `eraUnlockThresholds` in `GameConstants.dart`.
    - `roaring_20s`: 1,000,000 (1M) - Target hours of gameplay.
    - `atomic_age`: 1,000,000,000 (1B).
- [ ] **Tech Upgrades**: Add a new tier of tech upgrades to `TechData` for the `roaring_20s` era.
- [ ] **Worker Scaling**: 
    - Implement `upgradeToCurrentEra()` method in `Worker` / `GameState` to allow existing workers to gain the current era's multipliers.
    - Update `SummonWorkerUseCase` to only pull from the `currentEraId`.

## Phase 2: Visual Implementation
- [ ] **Procedural Worker Painter**: Implement `ArtDecoWorkerPainter`.
- [ ] **Reactor Swap**: Update `ReactorComponent` to load `lottieSteamPunkReactor` (despite the name, it's the requested "Machine Age" reactor for 20s) when in Roaring 20s.
- [ ] **Background Transition**: Update `FactoryScreen` to swap the `ThemeBackground` era ID immediately upon unlock.

## Phase 3: Transition UI
- [ ] **Era Unlock Button**: Create a high-fidelity "ERA ADVANCEMENT" button in `TechScreen`.
    - Visibility: Only displays when ALL current era techs are maxed.
    - Style: Art Deco / Neon hybrid, using the specified "button style" requirements.
- [ ] **State Trigger**: Update `GameStateNotifier.advanceEra` to:
    - Verify all techs are maxed.
    - Deduct the new (higher) CE cost.
    - Switch `currentEraId`.

## Phase 4: Refinement
- [ ] **Worker Level Up UI**: Add "Level Up for Era" option in the worker management UI (or as a bulk option).
- [ ] **Verification**: Ensure the "soft reset" feel (Visuals change, but progress continues/accelerates).

## Verification Checklist
- [ ] Max out Victorian Techs (Pressurized Boilers, etc.).
- [ ] Verify "Unlock Roaring 20s" button appears.
- [ ] Confirm Factory background and Lottie reactor swap upon clicking.
- [ ] Confirm new workers summoned are from the Roaring 20s era.
- [ ] Verify existing workers can be "Upgraded" to the new era.
