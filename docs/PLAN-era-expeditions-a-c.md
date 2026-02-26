# PLAN: Era Expedition Progression (A + C)

Date: 2026-02-26
Status: Ready for implementation kickoff
Owner: Gameplay + UI
Scope: Fix expedition relevance by preventing worker starvation and unlocking expeditions per era

## 1) Goal

Build an expedition system that:
- stays useful after heavy worker merge/fit behavior,
- scales with era progression,
- has strong era-specific identity in copy and layout.

Decision:
- Apply A + C together.

## 2) Product Strategy (A + C)

### A) Operational Crew Reserve

Rule:
- Starting an expedition should always expose a practical next action.

Mechanics:
1. Auto-crew:
- Add `Auto Assemble Crew` on expedition cards.
- Fill with idle workers by priority:
- `common -> rare -> epic -> legendary -> paradox`

2. Quick Hire:
- If idle workers are insufficient, show `Hire Now`.
- Hire base workers from the expedition era to fill missing slots.

3. Clear state:
- Always show `Idle: X | Required: Y`.
- Never leave player in a dead-end start flow.

### C) Era Expedition Track

Rule:
- Each unlocked era adds exactly 1 expedition from that era.

Flow:
- New save: only Victorian expedition.
- Unlock `roaring_20s`: +1 new expedition.
- Unlock `atomic_age`: +1 new expedition.
- Repeat through `far_future`.

Availability:
- Earlier era expeditions remain playable.

Source of truth:
- `GameConstants.eraOrder`

Unlock rule:
- `available = catalog.where(slot.unlockEraIndex <= playerMaxEraIndex)`

## 3) Era Unlock Matrix

| Player max era | Available expeditions |
|---|---|
| `victorian` | `victorian` |
| `roaring_20s` | `victorian`, `roaring_20s` |
| `atomic_age` | `victorian`, `roaring_20s`, `atomic_age` |
| `cyberpunk_80s` | add `cyberpunk_80s` |
| `neo_tokyo` | add `neo_tokyo` |
| `post_singularity` | add `post_singularity` |
| `ancient_rome` | add `ancient_rome` |
| `far_future` | add `far_future` |

## 4) Expedition Identity Catalog

| Era ID | Expedition Name | Card Flavor Text | Layout Signature |
|---|---|---|---|
| `victorian` | Whitechapel Ember | "Soot, valves, and secrets beneath London." | Copper frame, soot texture, serif title |
| `roaring_20s` | Speakeasy Gold Run | "Temporal smuggling between jazz and art deco." | Art deco geometry, gold/black contrast |
| `atomic_age` | Isotope-51 Convoy | "Retro-futurist tests in a radioactive suburb." | Chrome badge, lab sticker cues |
| `cyberpunk_80s` | Neon Ghost Run | "Stolen payloads in the neon nights of 1984." | Neon grid, magenta/cyan glow |
| `neo_tokyo` | Shibuya-2247 Drop | "Extract data before district collapse." | Frosted glass, diagonal cuts |
| `post_singularity` | Void-Cloud Harvest | "Autonomous entities contest quantum memory." | Ethereal treatment, digital noise |
| `ancient_rome` | Forum Aquila | "Recover chrono-imperial relics beneath the Senate." | Marble/stone frame, imperial seal |
| `far_future` | Rift-9 Cartography | "Map cosmic fractures beyond known space." | Star parallax, holographic accents |

Copy standard:
- Title: 2-4 words.
- Flavor line: one sentence.
- Footer: risk, duration, required workers.

## 5) Technical Design

Target files:
- `lib/domain/entities/expedition.dart`
- `lib/domain/usecases/start_expedition_usecase.dart`
- `lib/presentation/ui/pages/expeditions_screen.dart`
- `lib/core/utils/expedition_utils.dart`
- `test/domain/usecases/expeditions_usecases_test.dart`
- `test/core/utils/expedition_utils_test.dart`

Domain contract changes:
1. Extend expedition slot metadata:
- `eraId`
- `unlockEraId`
- `unlockEraIndex`
- `headline`
- `layoutPreset`
- `requiredWorkers`
- `duration`
- `defaultRisk`

2. Add availability resolver:
- `List<ExpeditionSlot> getAvailableExpeditionSlots(GameState state)`

3. Guard start flow:
- Reject locked-era slot start attempts.

4. Add crew helpers:
- `autoSelectCrew(slot, workers)`
- `quickHireForCrewGap(slot, state)`

UI contract changes:
1. Render cards only from unlocked slot list.
2. Apply `EraTheme.fromId(slot.eraId)` styling.
3. Expose Auto-crew and Quick Hire CTAs.

## 6) AI-Executable Delivery Plan

### WIN-1: Build era slot catalog
Inputs:
- `GameConstants.eraOrder`

Steps:
1. Define 1 slot per era with stable `slotId`.
2. Attach identity metadata and layout preset.

Done when:
- Catalog count equals era count.

### WIN-2: Implement unlock resolver
Steps:
1. Compute `playerMaxEraIndex`.
2. Filter slots by unlock index.

Done when:
- New save returns exactly one slot (`victorian`).

### WIN-3: Enforce lock rules in start use case
Steps:
1. Validate slot belongs to unlocked list.
2. Return null for locked starts.

Done when:
- Locked slot cannot be started via UI or direct use case call.

### WIN-4: Add anti-starvation actions
Steps:
1. Add `Auto Assemble Crew`.
2. Add `Hire Now` for missing workers.

Done when:
- User can always move forward from a blocked start attempt.

### WIN-5: Era identity UI pass
Steps:
1. Bind slot metadata to card title/flavor.
2. Apply era layout preset and theme accents.

Done when:
- Each era card has distinct visual identity and copy.

### WIN-6: Tests and regression
Steps:
1. Add domain tests for unlock and lock enforcement.
2. Add widget tests for card identity and CTA states.
3. Run full expedition-related tests.

Done when:
- Expedition suite passes consistently.

## 7) Test Matrix

Domain tests:
1. `new save -> available slots == 1 (victorian)`
2. `unlock roaring_20s -> available slots == 2`
3. `unlock atomic_age -> available slots == 3`
4. `start locked slot -> null`
5. `auto-crew picks idle workers without duplicates`
6. `quick hire fills crew gap`

Widget tests:
1. Correct era title + flavor per card.
2. Cyberpunk card uses cyberpunk layout preset.
3. Missing crew state shows `Hire Now`.

Regression tests:
1. Deployed worker still cannot be used.
2. Resolve/claim remains idempotent.
3. Save/load preserves stable `slotId` and metadata.

## 8) Acceptance Criteria

1. With only Victorian unlocked, exactly 1 Victorian expedition exists.
2. Every newly unlocked era adds exactly 1 expedition.
3. Each expedition has era-specific copy and layout.
4. Start flow supports manual crew, auto-crew, and quick hire.
5. Domain + widget tests for this feature are green.

## 9) Risks and Mitigations

Risk:
- Save compatibility break from slot migration.
Mitigation:
- Keep old `slotId` stable and add defensive fallback mapping.

Risk:
- Economy inflation via cheap quick hire.
Mitigation:
- Reuse era hire base cost plus convenience multiplier.

Risk:
- Visual noise in expedition cards.
Mitigation:
- Enforce fixed hierarchy: title, one-line flavor, compact stat chips.

## 10) First PR Scope (recommended)

Implement only WIN-1 and WIN-2:
1. Era slot catalog
2. Unlock resolver based on `GameConstants.eraOrder`
3. Minimal tests for unlock count by era
