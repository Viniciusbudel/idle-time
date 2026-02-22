# PLAN: User-Value Feature Expansion Guide

Date: 2026-02-22
Scope: Feature opportunities based on the current state of `time_factory`.

## Implementation Progress (Current Branch)

- Feature 0 (Progression Consistency): Completed.
- Feature 1 (Objective Board daily MVP): Completed and wired in Factory UI.
- Feature 2 (Artifact Forge core): Completed.
- Implemented: salvage flow, dust currency, craft flow, pity mechanic, and era-targeted craft selector.
- Remaining in Feature 2: balance tuning pass only (numbers calibration, no missing mechanics).
- Feature 3 (Temporal Expeditions): Kickoff in progress.
- Implemented in kickoff: expedition entities, state persistence, start/resolve/claim use cases, and notifier hooks.
- Implemented next: dedicated Expeditions screen (start/active/claim flow) and offline return summary integration.
- Implemented polish pass: segmented expedition flow (Missions/Active/Completed), compact expandable mission cards, and reward preview on selected risk.
- Implemented risk outcome pass: expedition success probability now uses assigned worker rarity + artifact loadout, and failed expeditions permanently remove assigned workers and their equipped artifacts.
- Remaining in Feature 3: balance pass and optional artifact-drop resolution hook on expedition claim.

## 1) Current State Analysis

### What is already strong
- Core idle loop is solid: tap + passive production + stations + workers + tech + prestige.
- Mid-loop systems already exist: artifacts, worker merge, era progression, daily rewards, achievements.
- Retention basics exist: offline rewards dialog + local notifications.
- UX foundation is strong: tabbed flow, polished neon UI, tutorial overlay, EN/PT localization.

### Main product gaps to unlock more user value
- No mission/objective system to guide "what to do next" after tutorial.
- Artifact loop has no late-game sink (no salvage/crafting path for overflow inventory).
- Long-term progression after current era content is thin (later eras are mostly placeholders).
- No asynchronous social/progression comparison loop (leaderboards, ghost rivals, events).
- No cross-device continuity (save is local only).

### Foundation issues to fix before major features
- Era unlock flow is inconsistent (`CheckEraUnlocksUseCase` exists but is not wired into runtime progression).
- Era threshold sources are inconsistent across files (multiple values/paths).
- Late-era placeholder values exist (example: `far_future` threshold handling), which can cause odd progression behavior.

## 2) Priority Order (Recommended)

1. Progression Consistency Pass (foundation)
2. Objective Board (daily/weekly missions)
3. Artifact Forge (salvage + craft)
4. Expeditions (idle worker assignment)
5. Era Mastery (post-era progression)
6. Paradox Operations (high-risk timed events)
7. Cloud Save + account sync

---

## 3) Step-by-Step Feature Guides

## Feature 0: Progression Consistency Pass (Must-Do First)

User value:
- Removes confusing unlock behavior and avoids "why did this unlock/not unlock" moments.

Implementation steps:
1. Choose one single era unlock source of truth (recommended: `GameConstants.eraUnlockThresholds`).
2. Align threshold logic in:
- `lib/core/constants/game_constants.dart`
- `lib/domain/usecases/check_era_unlocks_usecase.dart`
- `lib/presentation/state/tech_provider.dart` (next era cost provider)
3. Wire unlock validation into the active progression path (or delete dead path if unlocks are purely tech-gated).
4. Add guardrails for placeholder/final era values to avoid negative/invalid cost scenarios.
5. Add tests for each era transition path.

Definition of done:
- Era unlock rules are deterministic and identical across UI, state, and use case logic.

---

## Feature 1: Objective Board (Daily + Weekly Missions)

User value:
- Gives clear short-term goals every session and improves retention.

Implementation steps:
1. Add mission domain models:
- `MissionType`, `MissionDefinition`, `MissionProgress`, `MissionReward`.
2. Add mission state to `GameState`:
- Active missions, mission reset timestamps, claimed state.
3. Create use cases:
- Generate daily/weekly missions.
- Track progress from existing actions (hire, merge, summon, tech buy, prestige).
- Claim mission rewards.
4. Hook progress updates into existing notifiers/actions in `GameStateNotifier`.
5. Build mission UI:
- New panel in Factory tab header or a dedicated mission drawer.
- Quick claim and "go to action" buttons.
6. Add reset logic (midnight local or fixed UTC strategy).
7. Add tests:
- Mission generation, progress increments, claim idempotency, reset behavior.

Fast MVP mission set:
- Hire 3 workers
- Perform 1 merge
- Buy 2 tech upgrades
- Reach X CE production

Definition of done:
- Player can always see 3-5 active objectives and claim rewards reliably.

---

## Feature 2: Artifact Forge (Salvage + Craft)

User value:
- Makes duplicate/low-rarity artifacts useful and adds control over progression.

Implementation steps:
1. Add new currency (`artifactDust`) to `GameState`.
2. Add salvage use case:
- Convert artifact rarity -> dust value.
3. Add craft use case:
- Spend dust for targeted artifact roll (rarity-targeted or era-targeted).
4. Add pity mechanic:
- Track craft streak and guarantee higher rarity after N crafts.
5. Add UI:
- New tab/section in `ArtifactInventoryDialog` for Salvage and Craft.
6. Add balance data table:
- Salvage values and craft costs by rarity.
7. Add tests for economy safety:
- No negative balances, cap handling, pity resets correctly.

Definition of done:
- Artifact inventory has a meaningful sink and players can intentionally progress builds.

---

## Feature 3: Temporal Expeditions (Assign Idle Workers to Timed Runs)

User value:
- Adds strategic idle decisions while offline and creates return anticipation.

Implementation steps:
1. Create expedition entities:
- `Expedition`, `ExpeditionSlot`, `ExpeditionReward`, `ExpeditionRisk`.
2. Add expedition state in `GameState`:
- Active runs, start/end timestamps, selected worker IDs.
3. Implement use cases:
- Start expedition (validations: workers must be idle).
- Resolve expedition rewards on completion.
- Claim rewards.
4. Integrate with offline flow:
- On app resume, resolve any completed expeditions and show summary in offline dialog.
5. Build UI:
- New Expeditions screen with 2-3 mission cards and duration choices.
6. Reward types:
- CE, shards, artifact chance, rare worker fragments.
7. Tests:
- Time-based completion correctness and anti-double-claim protection.

Definition of done:
- User can start expedition, leave app, return, and claim rewards once.

---

## Feature 4: Era Mastery (Post-Era Long-Term Progression)

User value:
- Keeps old eras meaningful and adds prestige-like depth without hard reset fatigue.

Implementation steps:
1. Add `eraMasteryLevels` map in `GameState` keyed by era ID.
2. Add mastery XP sources:
- Completing era tech, merging same-era workers, expedition success in that era.
3. Create mastery perks per era:
- Example: Victorian mastery boosts offline gains, Atomic mastery boosts automation.
4. Extend production calculators:
- Apply mastery multipliers in one controlled place (avoid duplicate multiplier stacking).
5. Add Mastery UI:
- Per-era progress bars and unlocked perks.
6. Add regression tests for multiplier stacking order.

Definition of done:
- Each era has a visible mastery track that permanently rewards continued play.

---

## Feature 5: Paradox Operations (Timed Risk/Reward Events)

User value:
- Adds high-intensity moments that break routine and create excitement.

Implementation steps:
1. Add operation event definitions:
- Start condition, risk modifiers, reward table.
2. Trigger opportunities using existing paradox level logic.
3. Create operation flow:
- Player chooses risk tier.
- Temporary debuffs/buffs applied for event duration.
- On completion, grant scaled rewards.
4. UI:
- Event banner + operation panel + countdown.
5. Integrate with artifact drops:
- Boost drop quality during high-risk operations.
6. Add tests around event lifecycle and reward payout safety.

Definition of done:
- Operations appear predictably, are opt-in, and pay clear risk-adjusted rewards.

---

## Feature 6: Cloud Save + Cross-Device Continuity

User value:
- Protects progress and enables play across devices.

Implementation steps:
1. Define save schema versioning and migration strategy.
2. Add auth provider (anonymous first, optional full account link later).
3. Implement cloud sync service:
- Upload on checkpoint, download on launch, conflict resolver (latest/manual merge).
4. Add settings controls:
- Last sync time, force sync, conflict warning UI.
5. Keep local fallback path (offline-safe).
6. Add integration tests for save migration and conflict resolution.

Definition of done:
- User progress survives reinstall/device switch with explicit conflict handling.

---

## 4) Suggested Execution Timeline (8-10 weeks)

Week 1:
- Feature 0 (consistency pass)

Weeks 2-3:
- Feature 1 (Objective Board)

Weeks 4-5:
- Feature 2 (Artifact Forge)

Weeks 6-7:
- Feature 3 (Expeditions)

Weeks 8-9:
- Feature 4 (Era Mastery)

Week 10:
- Feature 5 kickoff (Paradox Operations MVP)

Parallel track (when backend bandwidth exists):
- Feature 6 (Cloud Save)

---

## 5) What to Build First If You Want Fastest User Impact

If you only start 2 features now:
1. Objective Board
2. Artifact Forge

Why:
- They immediately improve session clarity and long-term reward satisfaction using your current systems with minimal architectural disruption.
