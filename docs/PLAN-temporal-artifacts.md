# PLAN: Temporal Artifacts — Continuation

> **Feature:** Equippable RPG items for workers, dropped from Temporal Anomalies.
> **Status as of 2026-02-19:** Foundation complete. Remaining work is the Anomaly spawn system and production polish.

---

## 🎼 Orchestration Report

| # | Agent | Focus Area |
|---|-------|------------|
| 1 | `game-developer` | Flame component for Temporal Anomaly spawning |
| 2 | `mobile-developer` | Touch UX for artifact slots and inventory UI |
| 3 | `project-planner` | Roadmap, task sequencing, and verification |

---

## ✅ Already Done

| Area | Status |
|------|--------|
| `WorkerArtifact` entity with rarity/era bonus | ✅ Done |
| `Worker.equippedArtifacts` (max 5 slots) | ✅ Done |
| `GameState.inventory` + serialization | ✅ Done |
| `equipArtifact` / `unequipArtifact` in provider | ✅ Done |
| `addArtifactToInventory` in provider | ✅ Done |
| `WorkerDetailDialog` — 5 Neon Cyberpunk slots | ✅ Done |
| `ArtifactInventoryDialog` — grid + search + equip | ✅ Done |
| `mergeWorkers` returns artifacts to inventory | ✅ Done |

---

## 🔧 Remaining Work — Small Wins

> Each step is independently verifiable. Work bottom-up through the list.

---

### WIN 1 — Fix Failing Test (Blocker)
**Agent:** `game-developer` / `debugger`
**Skills:** `systematic-debugging`, `testing-patterns`
**Workflow:** `/debug`

- [ ] Fix `MegaChamberCard displays critical stats` test failure in `test/presentation/ui/widgets/mega_chamber_card_test.dart`
- [ ] The failure stems from the removal of `worker.level` — update test fixtures to use the new artifact-based model

**Verify:** `flutter test test/presentation/ui/widgets/mega_chamber_card_test.dart` → green

---

### WIN 2 — Artifact Unit Tests
**Agent:** `test-engineer`
**Skills:** `testing-patterns`, `tdd-workflow`
**Workflow:** `/test`

- [ ] Create `test/domain/worker_artifact_test.dart`:
  - Test `WorkerArtifact.generate()` for all 5 rarities
  - Test `Worker.currentProduction` with 0, 1, and 5 artifacts equipped
  - Test era-match bonus: artifact era == worker era → +10%
  - Test `GameStateNotifier.equipArtifact` adds to worker, removes from inventory
  - Test `GameStateNotifier.unequipArtifact` does the reverse
  - Test inventory cap (100 items) rejects new artifacts

**Verify:** `flutter test test/domain/worker_artifact_test.dart` → all passing

---

### WIN 3 — Artifact Name Registry
**Agent:** `game-developer`
**Skills:** `clean-code`, `game-development`
**Workflow:** `/enhance`

- [ ] Create `lib/domain/entities/artifact_name_registry.dart` with a pool of lore-appropriate names per rarity:
  - `common` → e.g., "Rusted Cog", "Cracked Lens", "Worn Sprocket"
  - `rare` → e.g., "Resonance Coil", "Phase Lens", "Flux Amplifier"
  - `epic` → e.g., "Temporal Regulator", "Paradox Filter", "Quantum Gyroscope"
  - `legendary` → e.g., "Tachyon DriveCore", "Void Capacitor", "Chrono Sigil"
  - `paradox` → e.g., "Singularity Engine", "Reality Anchor"
- [ ] Wire `WorkerArtifact.generate()` to use the registry instead of hardcoded names

**Verify:** Spawn 10 artifacts of each rarity, verify unique names appear

---

### WIN 4 — ArtifactInventoryDialog UX Polish
**Agent:** `mobile-developer`
**Skills:** `mobile-design`, `frontend-design`
**Workflow:** `/enhance`

- [ ] Add rarity filter chips at top of `ArtifactInventoryDialog` (ALL / ★ / ★★ / ★★★ / ★★★★)
- [ ] Show stats tooltip on long-press: `+X base power`, `+Y% production`, era bonus flag
- [ ] Show slot-full warning in the EQUIP button when worker has 5 artifacts (currently just disables)
- [ ] Animate the EQUIP action — brief green flash on the slot in `WorkerDetailDialog` after equip

**Verify:** Open inventory, long-press an artifact, see stat tooltip. Tap EQUIP on a full worker, see clear error state.

---

### WIN 5 — Temporal Anomaly Component (Core Drop System)
**Agent:** `game-developer`
**Skills:** `game-development`, `clean-code`
**Workflow:** `/enhance`

This is the primary remaining feature. Implements artifact drops via a tappable black hole on the `FactoryScreen`.

- [ ] Create `lib/presentation/game/components/temporal_anomaly_component.dart` as a `PositionComponent` (Flame):
  - Pulsing black hole visual using `CircleComponent` with glow + particle ring
  - 10-second lifespan via countdown timer — auto-removes if missed
  - On tap: calls `addArtifactToInventory` with a `WorkerArtifact.generate()` drop, weighted by `paradoxLevel`
- [ ] Create `lib/domain/usecases/roll_artifact_drop_usecase.dart`:
  - Calculates rarity based on current `paradoxLevel` (high Paradox → better drops)
  - Returns a `WorkerArtifact` using the name registry
- [ ] Add a `_anomalySpawnTimer` to `TimeFactoryGame`:
  - Spawn interval: Random between 120-300 seconds (2-5 min)
  - If `paradoxLevel > 0.8`: halve the interval (60-150s)
  - Max 1 active anomaly at a time
- [ ] Wire `addArtifactToInventory` result → show a brief toast/banner notification

**Verify:** Start game, wait or use debug-add-currency to raise production. A black hole spawns after a few minutes. Tap it — new artifact appears in inventory.

---

### WIN 6 — Anomaly Notification Banner
**Agent:** `mobile-developer`
**Skills:** `mobile-design`, `frontend-design`
**Workflow:** `/enhance`

- [ ] Create `lib/presentation/ui/atoms/artifact_drop_banner.dart`:
  - Slides in from top with rarity color glow
  - Shows artifact name + rarity tier + icon
  - Auto-dismisses after 3 seconds
- [ ] Trigger banner from `FactoryScreen` when `addArtifactToInventory` succeeds

**Verify:** Tap anomaly, see banner slide in, auto-hide after 3s.

---

### WIN 7 — Production Stats Display in WorkerDetailDialog
**Agent:** `mobile-developer`
**Skills:** `mobile-design`
**Workflow:** `/enhance`

- [ ] Show a "Total Power" stat bar in `WorkerDetailDialog`:
  - Displays `worker.currentProduction` (with artifacts applied)
  - Shows breakdown: Base + Artifact Bonuses + Era Multiplier
- [ ] Slot icons: use unique `IconData` per artifact type (gear, lens, coil, crystal, orb) instead of `auto_awesome`

**Verify:** Equip/unequip an artifact and see the "Total Power" number change in real-time.

---

### WIN 8 — Dart Analyze + Lint Pass
**Agent:** `project-planner` / `debugger`
**Skills:** `clean-code`
**Workflow:** `/debug`

- [ ] Run `dart analyze` → fix all warnings/errors introduced by the artifact system
- [ ] Remove unused imports from modified files
- [ ] Ensure `const` is used where possible in artifact/widget constructors

**Verify:** `dart analyze` → 0 errors, 0 warnings

---

## 🏁 Done When

- [ ] All 8 wins completed
- [ ] `flutter test` → all tests pass
- [ ] `dart analyze` → 0 errors
- [ ] Player can: receive artifact drop from anomaly → open inventory → equip to worker → see production increase

---

## 🔗 Related Files

| File | Purpose |
|------|---------|
| [`worker_artifact.dart`](../lib/domain/entities/worker_artifact.dart) | Core entity + `generate()` factory |
| [`worker.dart`](../lib/domain/entities/worker.dart) | `equippedArtifacts`, `currentProduction` |
| [`game_state.dart`](../lib/domain/entities/game_state.dart) | `inventory` field |
| [`game_state_provider.dart`](../lib/presentation/state/game_state_provider.dart) | equip/unequip/add methods |
| [`worker_detail_dialog.dart`](../lib/presentation/ui/dialogs/worker_detail_dialog.dart) | 5-slot UI |
| [`artifact_inventory_dialog.dart`](../lib/presentation/ui/dialogs/artifact_inventory_dialog.dart) | Inventory picker |
| [`time_factory_game.dart`](../lib/presentation/game/time_factory_game.dart) | Flame game loop (spawn timer goes here) |
| [`factory_screen.dart`](../lib/presentation/ui/pages/factory_screen.dart) | Host for anomaly component |
