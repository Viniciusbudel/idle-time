# PLAN: Paradox Shop Expansion + Next Era Tech Trees

Date: 2026-02-22
Scope: Expand late-game progression with new Paradox Shop upgrades and full tech sets for `neo_tokyo`, `post_singularity`, `ancient_rome`, and `far_future`.

## 1) Goals

- Make Paradox Points more strategic after early prestige upgrades are maxed.
- Fill content gaps for post-`cyberpunk_80s` eras with meaningful choices.
- Tie new systems to existing loops: expeditions, artifact forge, mastery, and offline returns.
- Keep formulas deterministic and easy to rebalance in one place.

## 2) Paradox Shop Expansion

Current shop model is `PrestigeUpgradeType` with capped levels and quadratic-ish costs. Extend it with these upgrades:

1. `causal_insurance`
- Effect: reduce expedition failure worker loss by `10%` per level.
- Cap: `5`.
- Hook: expedition failure resolution.

2. `dust_arbitrage`
- Effect: artifact salvage dust gain `+8%` per level.
- Cap: `10`.
- Hook: salvage flow.

3. `rift_cartographer`
- Effect: expedition success chance `+3%` per level.
- Cap: `8`.
- Hook: expedition start chance calculation.

4. `mission_overclock`
- Effect: daily mission rewards `+6%` per level.
- Cap: `6`.
- Hook: daily mission claim use case.

5. `mastery_catalyst`
- Effect: era mastery XP gains `+10%` per level.
- Cap: `5`.
- Hook: all mastery XP award paths.

6. `echo_bank`
- Effect: keep `2%` of current CE on prestige per level.
- Cap: `5` (hard global cap `10%` effective keep for safety if later stacked).
- Hook: prestige reset transfer.

Balance note:
- Costs should start above existing mid-tier upgrades and ramp faster than `chrono_mastery` to avoid obvious always-buy picks.

## 3) New Tech Sets For Next Eras

Add one complete pack per era: 4 progression techs + 1 capstone unlock (except `far_future`, which gets an endgame capstone reward tech).

`neo_tokyo`
1. `neon_logistics_mesh` (`automation`)
2. `shard_refinery_grid` (`efficiency`)
3. `street_market_algorithms` (`costReduction`)
4. `holo_shift_fabricators` (`timeWarp`)
5. `singularity_gate` (`eraUnlock`) -> unlocks `post_singularity`

`post_singularity`
1. `self_editing_factories` (`efficiency`)
2. `causal_prediction_core` (`offline`)
3. `synthetic_retrocausality` (`automation`)
4. `entangled_blueprints` (`costReduction`)
5. `rome_paradox_protocol` (`eraUnlock`) -> unlocks `ancient_rome`

`ancient_rome`
1. `imperial_bureaucracy` (`costReduction`)
2. `legionary_discipline` (`efficiency`)
3. `janus_oracles` (`offline`)
4. `aqueduct_temporalis` (`automation`)
5. `omega_relic_engine` (`eraUnlock`) -> unlocks `far_future`

`far_future`
1. `chronoforge_nanites` (`efficiency`)
2. `timeline_fork_scheduler` (`automation`)
3. `entropy_harvester` (`offline`)
4. `omega_memory_lattice` (`timeWarp`)
5. `apex_continuum` (`manhattan`-style endgame capstone, no further era unlock)

## 4) Implementation Phases

Phase A: Paradox Shop
1. Extend `PrestigeUpgradeType`.
2. Add effect application hooks in use cases/notifier paths.
3. Add UI labels and localization entries.
4. Add unit tests for each upgrade effect and caps.

Phase B: Era Tech Content (Neo Tokyo + Post Singularity)
1. Add tech definitions to `TechData.initialTechs`.
2. Extend multiplier calculators in `TechData`.
3. Add/adjust `bonusDescription` handling for new tech IDs.
4. Add era completion and unlock flow tests.

Phase C: Era Tech Content (Ancient Rome + Far Future)
1. Add remaining tech packs.
2. Add far-future capstone behavior and endgame messaging.
3. Rebalance costs and multipliers with regression tests.

## 5) Acceptance Criteria

- Paradox Shop has at least 5 new viable upgrades with distinct roles.
- Each next era has visible, purchasable tech progression and clear capstone.
- No negative resource flow or uncapped multiplier runaway.
- Tests cover upgrade hooks, tech multipliers, unlock gating, and persistence.
