# PLAN: Single Chamber Era Progression + Layout/App Bar Redesign

Owner: Gameplay + UI
Status: in_progress

## Scope
- Move game flow to a single active chamber model.
- On era upgrade, auto-upgrade the chamber to the newest era chamber and remove the old one.
- Redesign layout and app bar using best practices and the workflow in `.agent/skills/flutter-skills/flutter-ui-design-steps.md`.

## 1. Single Chamber Progression (Only One Chamber)

### Objective
Ensure the player always has exactly one chamber. Era progression upgrades that chamber in place (or replaces it) and old chamber data does not remain visible or referenced.

### Iteration 1.1 - Domain rules and migration
- Define canonical rule: `stations` must contain exactly one active chamber entry.
- Add normalization/migration for old saves with multiple chambers.
- Decide preservation behavior on era upgrade:
  - Keep chamber level and assigned workers where valid.
  - Preserve production-affecting upgrades that are not chamber-type specific.

Done when:
- Loading legacy save with multiple chambers results in one valid chamber.
- No crashes or orphan station references.

### Iteration 1.2 - Era upgrade chamber replacement
- In era upgrade flow, map era to chamber type.
- Replace current chamber with latest era chamber.
- Remove old chamber entry and any dangling worker station references.

Done when:
- After era upgrade, only one chamber exists and it matches unlocked era.
- Old chamber no longer appears in UI or state.

### Iteration 1.3 - UI behavior and guardrails
- Update chamber screen to assume single chamber model.
- Remove multi-chamber affordances from UI actions/navigation.
- Add defensive guards to block creation of extra chambers.

Done when:
- Player can only interact with one chamber path.
- No duplicate chamber cards/widgets appear.

### Iteration 1.4 - Verification
- Add/adjust tests for:
  - save normalization,
  - era upgrade replacement,
  - single chamber invariant.
- Add regression test for upgrade path with assigned workers.

Done when:
- All chamber/era tests pass.
- Single chamber invariant holds in all tested flows.

## 2. Layout Adjustments + App Bar Redesign (Flutter UI Design Steps)

### Objective
Restructure layout so all elements are correctly placed across device sizes and redesign the app bar using production-grade Flutter best practices.

### Iteration 2.1 - Context analysis (Step 1)
- Audit current screens (especially chambers/main tabs):
  - visual hierarchy,
  - spacing/alignment,
  - missing loading/empty/error states,
  - accessibility gaps.
- Capture before screenshots and problem list.

Done when:
- Documented issue list with severity and target screens.

### Iteration 2.2 - Visual hierarchy + app bar concept (Step 2)
- Redesign app bar with clear structure:
  - clear title and context,
  - primary action priority,
  - consistent iconography,
  - predictable back/navigation behavior.
- Re-group top-level screen content for stronger hierarchy.

Done when:
- New app bar layout approved in mock/implementation draft.
- Primary actions are obvious at first glance.

### Iteration 2.3 - Design system alignment (Step 3)
- Replace hardcoded dimensions/colors with theme tokens.
- Standardize spacing, radius, elevation, and typography.
- Align with Material 3 conventions in existing design language.

Done when:
- App bar and key layout blocks use shared tokens/theme values.
- Hardcoded style hotspots are removed from touched screens.

### Iteration 2.4 - Responsiveness (Step 4)
- Validate layout on compact, normal, and tablet widths.
- Fix overflow, clipping, and unsafe text scaling behavior.
- Ensure app bar actions and title remain stable across breakpoints.

Done when:
- No overflow warnings on target sizes.
- Core screens remain usable and readable on small/large devices.

### Iteration 2.5 - Accessibility pass (Step 5)
- Ensure minimum touch targets (48dp).
- Improve contrast where needed.
- Add semantic labels/focus behavior for app bar actions and key controls.

Done when:
- Accessibility checklist passes for updated screens.

### Iteration 2.6 - Flutter refactor + critique pass (Steps 6-7)
- Extract reusable app bar/layout components.
- Simplify widget trees and improve maintainability.
- Run final critique pass and apply final polish improvements.

Done when:
- Reusable components are in place.
- Updated screens feel production-ready and consistent.

## Delivery Sequence
1. Complete Section 1 (single chamber invariant) before UI polish.
2. Execute Section 2 iteratively from 2.1 to 2.6.
3. After each iteration: run tests, capture screenshots, and record what changed.

## Progress (2026-02-27)
- Completed:
  - Section 1.1, 1.2, 1.3, 1.4
  - Section 2.2 app bar concept implementation (global resource header + chambers header)
  - Section 2.3 design token alignment on touched headers/layouts
  - Section 2.4 responsiveness pass for factory HUD and bottom dock
  - Section 2.5 accessibility improvements (48dp touch targets + semantics on updated controls)
- In progress:
  - Section 2.1 formal issue list documentation with screenshots
  - Section 2.6 final extraction/cleanup pass for reusable layout wrappers

## Acceptance Criteria
- Exactly one chamber exists at all times.
- Era upgrade always upgrades/replaces the chamber to the newest era type.
- Old chamber data is removed and never rendered.
- App bar redesign is implemented using Flutter best practices and design-step workflow.
- Updated layouts are responsive, accessible, and token-aligned.
