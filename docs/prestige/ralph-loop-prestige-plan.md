# FEATURE: Prestige Shop + Reset Integrity

Owner: Economy + Progression + Persistence
Branch: feature/prestige-integrity-fixes
Status: active

---

## GLOBAL RULES

- Only implement one story at a time.
- Do not refactor unrelated modules.
- All acceptance criteria must pass before marking story as done.
- Update story status in this file after completion.
- Commit after each completed story.
- Any balance change must include before/after numbers in PR notes.

---

# STORIES

---

## STORY-1: Remove Start Era and Paradox Entries From Prestige Shop
status: done

Description:
Remove the Start Era and Paradox purchase entries from the prestige shop catalog and block any legacy purchase path for those ids.

Acceptance:
- Prestige shop no longer renders Start Era entry.
- Prestige shop no longer renders Paradox entry.
- Attempting to purchase removed ids from stale UI or old save path is ignored safely.
- Existing saves with those upgrades do not crash and are normalized on load.

Done when:
- Shop list and purchase handler tests pass.
- Manual check confirms both entries are absent.

---

## STORY-2: Add Paradox-Based Click Power Bonus (+10%)
status: done

Description:
Apply click power scaling from paradox balance using the same progression model used by production, with +10% per configured step.

Acceptance:
- Click power multiplier includes paradox bonus.
- Paradox bonus math matches production model structure.
- Tooltip or summary text reflects click bonus source.
- Unit tests cover zero paradox, single step, and multi-step values.

Done when:
- Production and click formulas produce expected values in tests.
- No regressions in existing production bonus behavior.

---

## STORY-3: Wire Prestige Luck Percent To Expeditions + Text Update
status: done

Description:
Ensure prestige luck percent upgrades affect expedition outcomes and rename any misleading prestige shop text to explicitly mention expedition luck.

Acceptance:
- Luck upgrade increases expedition luck calculations.
- Prestige shop label uses expedition wording (not generic luck wording).
- UI shows the real configured value for safe/risk/volatile contexts.
- Unit/integration tests prove luck delta changes expedition result distribution.

Done when:
- Expedition logic test suite passes with luck modifier assertions.
- Manual shop text review confirms updated labels.

---

## STORY-4: Preserve Equipped Worker Artifacts Through Prestige
status: todo

Description:
Fix prestige reset flow so worker artifact assignments do not vanish. If a worker is reset, artifact must return to inventory deterministically.

Acceptance:
- Equipped artifacts remain attached when worker persists across prestige.
- If worker is recreated/reset, artifact is restored to inventory and can be reassigned.
- No duplicate artifacts and no lost artifacts after prestige.
- Save/load after prestige keeps artifact state consistent.

Done when:
- Persistence tests cover equip -> prestige -> load path.
- Manual QA confirms no vanish cases.

---

## STORY-5: Reset Tech Progress Correctly On Prestige
status: todo

Description:
Ensure prestige resets all technology progression that should be reset, including previously maxed tech state.

Acceptance:
- All tech levels return to baseline after prestige.
- Maxed flags and cached completion states are cleared.
- Tech UI reflects reset state immediately.
- Re-progression after prestige works from clean baseline.

Done when:
- Tech reset tests pass for partial and fully maxed trees.
- Manual run confirms no tech remains maxed after prestige.

---

## STORY-6: Validate Prestige Percent Modifiers End-To-End
status: todo

Description:
Audit and verify that all prestige percent modifiers are applied once, in the correct order, and reflected correctly in UI text.

Acceptance:
- Documented formula chain exists for production, click, expedition luck, and related prestige bonuses.
- Snapshot tests validate expected values for representative profiles.
- UI strings show computed values that match runtime formulas.
- No double-application or missing application of prestige percentages.

Done when:
- End-to-end balance verification checklist is complete.
- QA sign-off confirms expected outputs in live gameplay checks.
