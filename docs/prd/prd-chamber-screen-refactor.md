# Chamber Screen – Game Feel Refactor (Neon Futuristic HUD)

## Objective
Refactor the Chamber Screen to feel more like a **game system console** while preserving the app’s **neon futuristic identity**. The goal is to remove the “mobile app header” vibe and replace it with a **system HUD**, improve hierarchy, and give more space/importance to the Chamber module. Additionally, move **“Manage Units”** outside the Chamber card to reduce competition for space and focus.

---

## Scope
### In Scope
- Replace the current AppBar with a **System HUD Header**
- Make Chamber section more dominant (“Hero Module”)
- Move **Manage Units** outside Chamber module
- Improve telemetry styling (stats + status)
- Add subtle micro-animations (game feel)
- Maintain existing bottom navigation layout and behavior

### Out of Scope
- Pixel art conversion
- Business logic changes (production math, upgrades, expedition logic)
- Navigation redesign
- Heavy GPU effects (large blur/glow everywhere)

---

## Current Issues
1. **AppBar feels like a standard app header**
   - Flat, minimal, lacks “system console” identity
   - Doesn’t communicate live telemetry / control panel feel
2. **Hierarchy competition**
   - Chamber content competes with UI actions like “Manage Units”
   - Production value does not feel like the main focus
3. **Game feel missing**
   - Missing subtle motion/telemetry cues (scan, pulse, status indicators)
   - Buttons feel like form actions rather than game actions

---

## Target UX / Visual Intent
The Chamber Screen should feel like:
> A live temporal production chamber monitored by a megacorp AI system, inside an idle game.

Not:
> A mobile app page with a title and filters.

---

## New Layout Structure (High Level)
Replace:
- AppBar (app-like)
With:
- **System HUD Header** (game-like)

Move:
- “Manage Units” OUT of the Chamber block and into its own section for clarity and space.

New structure:
1) System HUD Header  
2) Chamber Hero Module  
3) Stats Telemetry Bar  
4) Unit Control Panel (Manage Units)  
5) Protocol Matrix  
6) Bottom Navigation (unchanged)

---

## Requirements

### 1) System HUD Header (Replace AppBar)
#### Purpose
Create a strong “game HUD” header that frames the screen as a **temporal system console**.

#### Header Content (3-line structure)
Line 1 – System Identity:
- Small label: `LOOP SYSTEM`
- Main title: `CHAMBER`
- Optional ID: `CHMBR_01` / `SYS.LC1`

Line 2 – Telemetry:
- `EXPEDITIONS: 0 ACTIVE`
- `SYS STATUS: ONLINE`
- Small animated “online” indicator dot (pulse)

Line 3 – Operational Chips:
- `6 IDLE`
- `0 ACTIVE`
- `SYS.LC1`
These must look like **system chips**, not filter buttons.

#### Visual Style Requirements
- Framed neon panel (thin stroke)
- Subtle inner glow (only header frame, not everything)
- Technical divider lines (1px)
- Optional micro-grid behind header only
- Avoid large rounded corners and app-like spacing

#### Micro Animation
- Online dot: pulsing opacity or scale (very subtle)
- Header frame: faint “breathing glow” (slow, low amplitude)

---

### 2) Chamber Hero Module (Main Machine Block)
#### Purpose
Make the Chamber feel like the core machine under control.

#### Changes
- Increase vertical dominance (more spacing around it)
- Production display becomes the **largest focal element**
- Use telemetry frame around production value (HUD container)
- Keep system status visible inside module: `SYSTEM: ONLINE`

#### Chamber Content Layout
- Title: `DUAL HELIX CHAMBER`
- Era label (small): `ERA: ROARING 20s` (or current)
- Production display: `4 / SEC` (largest element)
- Status chip: `SYSTEM: ONLINE`

#### Micro Animation
- Production number pulse: scale 1.0 → 1.02 → 1.0 loop (2–3s)
- Optional subtle digital flicker (rare, low opacity shift)

---

### 3) Stats Telemetry Redesign (Efficiency / Stability)
#### Purpose
Stats should look like game telemetry instead of flat info boxes.

#### Requirements
- Replace flat stat tiles with **telemetry bars**
- Each stat row contains:
  - Icon
  - Label
  - Segmented bar fill
  - Value at the end

Example format:
- `EFFICIENCY | ████████ 120%`
- `STABILITY  | ████████ 99.9%`

Rules:
- Hard border, solid fill
- Minimal/no gradients
- Optional scan sweep on first render (1 pass, subtle)

---

### 4) Move “Manage Units” Outside the Chamber
#### Purpose
“Manage Units” is a management action; it should not compete with the chamber’s machine identity.

#### New Section: Unit Control Panel
- Section title: `UNIT CONTROL`
- One primary action button: `MANAGE UNITS`

Design Requirements:
- Smaller framed panel than Chamber hero
- Game-style action button (not app button)
- Press feedback:
  - scale 0.96
  - brightness/glow increase
- Clear separation from production module

---

### 5) Protocols Section Improvements
Keep functionality but make it more “system-like”.

Changes:
- Rename section label to: `PROTOCOL MATRIX`
- Add a thin divider line below the label
- Use consistent chip styling for protocol slots
- Keep density slightly tighter (less padding than app UI)
- Ensure “2/3 ACTIVE” badge looks like telemetry, not a standard pill button

---

## Visual System Rules (Game HUD)
- Increase technical identity:
  - IDs, system labels, small technical dividers
  - framed panels with consistent stroke thickness
- Use glow selectively:
  - hero value, active button, header frame
  - avoid glowing every border
- Prefer crisp edges:
  - smaller radii (0–8)
  - avoid overly rounded cards
- Spacing:
  - multiples of 4 (4/8/12/16)
  - slightly denser than typical mobile UI

---

## Micro Animations (Required)
All animations must be subtle and performance-safe.
- Header online dot pulse (always)
- Production value pulse (always)
- Optional progress/scan sweep for stats (on first render)
- Button press feedback (interaction)

Constraints:
- Do NOT animate every component constantly
- Do NOT animate entire lists simultaneously
- Avoid heavy blur shaders and expensive repaints

---

## Performance Constraints
- Must maintain smooth scrolling and interaction (target 60 FPS)
- Prefer lightweight animations (opacity/scale/translate)
- No large blur/glow effects across big surfaces
- Limit concurrent animation controllers

---

## Acceptance Criteria
The refactor is complete when:
1. AppBar is replaced with a **System HUD Header** (3-line telemetry)
2. Chamber becomes the dominant hero module
3. Production value is the primary focal element and has subtle pulse
4. “Manage Units” is removed from Chamber and placed into its own Unit Control panel
5. Efficiency/Stability stats use telemetry bars with clear hierarchy
6. Protocols section is labeled and framed as a “matrix”
7. Micro animations exist but do not distract or hurt performance
8. Visual identity remains neon futuristic and consistent with the rest of the app
9. No business logic behavior changes

---

## Final Intent Statement
The Chamber Screen must look and feel like a **live monitored machine console** inside a neon cyberpunk idle game—technical, interactive, authoritative—without losing the app’s futuristic brand language.