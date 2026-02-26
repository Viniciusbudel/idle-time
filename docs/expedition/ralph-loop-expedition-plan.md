# FEATURE: Era Expedition Progression (A + C)

Owner: Gameplay + UI
Branch: feature/era-expeditions
Status: active

---

## GLOBAL RULES

- Only implement one story at a time.
- Do not refactor unrelated modules.
- All acceptance criteria must pass before marking story as done.
- Update story status in this file after completion.
- Commit after each completed story.

---

# STORIES

---

## STORY-1: Build Era Slot Catalog
status: todo

Description:
Define exactly one expedition slot per era using GameConstants.eraOrder.

Acceptance:
- Catalog contains exactly 1 slot per era.
- slotId is stable and deterministic.
- Each slot contains:
    - eraId
    - unlockEraId
    - unlockEraIndex
    - headline
    - layoutPreset
- Unit test confirms catalog count == era count.

Done when:
- Test passes.
- No UI code modified.

---

## STORY-2: Implement Unlock Resolver
status: todo

Description:
Filter expedition slots by playerMaxEraIndex.

Acceptance:
- new save returns exactly 1 slot (victorian)
- unlocking roaring_20s returns 2 slots
- unlocking atomic_age returns 3 slots
- Resolver logic isolated in:
  lib/domain/usecases/get_available_expeditions.dart
- Unit tests cover 3 era progression cases.

Done when:
- Tests pass
- No hardcoded era branching

---

## STORY-3: Enforce Lock Rule in Start Use Case
status: todo

Description:
Prevent starting locked slots.

Acceptance:
- Locked slot start returns null
- UI reflects locked state
- Attempting forced start does nothing
- Test covers locked attempt

Done when:
- Domain tests pass
- UI visually reflects locked state

---

## STORY-4: Add Auto Crew + Quick Hire
status: todo

Acceptance:
- Auto crew fills idle workers in correct priority
- Quick hire fills gap using era base workers
- No duplicate workers
- Domain tests pass

Done when:
- Blocked state always offers forward action