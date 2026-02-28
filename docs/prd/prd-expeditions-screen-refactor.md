# Expeditions Screen – Temporal Operations Console Redesign PRD

## Objective
Redesign the Expeditions screen to eliminate the “mobile app list” feeling and transform it into a high-authority temporal mission control console. The new layout must align with the neon futuristic aesthetic already established in Tech and Chamber screens while increasing game immersion, hierarchy clarity, and system identity.

The screen should feel like a corporate AI-controlled operations dashboard inside a cyberpunk idle game — not like a task manager or expandable list UI.

---

## Scope

### In Scope
- Replace standard app header with System HUD header
- Restructure mission cards into dossier-style modules
- Redesign mission filters (Available / Active / Completed)
- Improve crew status visualization
- Improve risk/reward visual hierarchy
- Redesign action buttons to feel like game commands
- Add subtle micro-animations
- Maintain neon futuristic identity

### Out of Scope
- Changing business logic
- Modifying expedition math or backend logic
- Navigation redesign
- Pixel art conversion
- Heavy GPU effects

---

## Current Problems

1. Header feels like a normal mobile page (back arrow + centered title).
2. Mission status chips look like app filters.
3. Mission cards feel like expandable settings blocks.
4. Risk and reward lack visual hierarchy.
5. Crew assignment feels instructional rather than tactical.
6. Buttons look like form submissions.

---

## Design Direction

This screen represents:

Temporal Operations Control Matrix

The player is managing risk-heavy time missions under a megacorp AI system.

The UI must communicate:
- Live mission supervision
- Tactical risk vs reward decisions
- Crew deployment authority
- System-level telemetry
- Operational seriousness

It must NOT resemble:
- A productivity task list
- A standard mobile expandable card layout

---

## Structural Redesign

### 1. System HUD Header (Replace App Bar)

Replace the current simple title header with a framed system block containing:

Line 1:
TEMPORAL OPERATIONS // MISSION CONTROL
Optional system ID (OPS_03)

Line 2:
SYS STATUS: STANDBY
ACTIVE MISSIONS: 0

Line 3:
CREW STATUS SUMMARY (Idle / Deployed / Ready)

Visual Requirements:
- Framed neon panel
- Thin border stroke
- Subtle glow (low intensity)
- Technical divider lines
- Optional small pulsing online indicator
- No large rounded corners
- No standard app padding style

---

### 2. Crew Status Matrix (Replace Chip Row)

Instead of pill-style filter chips:

Display a telemetry-style status matrix:

CREW STATUS MATRIX  
IDLE: 8 | DEPLOYED: 0 | READY: 0

Requirements:
- Horizontal segmented bar or structured layout
- Small animated status lights
- Clear visual grouping
- No segmented toggle appearance

---

### 3. Mission Filter Redesign

Replace segmented control style tabs with system-mode selector:

MISSION FILTER  
[ AVAILABLE ] [ ACTIVE ] [ COMPLETED ]

Requirements:
- Look like selectable system modes
- Active state uses underline glow or frame bracket
- Avoid toggle-switch appearance
- Keep consistent with Tech screen visual authority

---

### 4. Mission Card Redesign (Dossier Style)

Each mission becomes a structured mission dossier module.

Structure:

MISSION: WHITECHAPEL EMBER  
CLASS: VICTORIAN / COPPER  
DURATION: 30m  

RISK INDEX: 5%  
REWARD YIELD: 637.8K CE  

CREW REQUIRED: 1  
CREW AVAILABLE: 8  

CREW ASSIGNMENT MATRIX  
[ + ] [ SLOT 1 ]  

[ AUTO ASSIGN ]  
[ DEPLOY MISSION ]

---

### Visual Hierarchy Inside Card

Priority order:
1. Mission name
2. Reward yield
3. Risk index
4. Crew requirement
5. Action button

Reduce:
- Long descriptions (truncate to 1 line)
- Instructional sentences
- Excess secondary text

---

### 5. Risk and Reward Visualization

Replace plain text with telemetry bars.

RISK  
Segmented bar with yellow/orange/red tones

REWARD  
Segmented cyan bar

Both bars:
- Hard border
- Solid fill
- No heavy gradients
- Optional subtle fill animation on render

---

### 6. Crew Assignment Redesign

Replace text instructions with visual slot system.

CREW ASSIGNMENT MATRIX:
- Empty slots clearly visible
- Highlight filled slots
- Idle crew count displayed clearly
- Remove instructional text paragraph

Must feel like tactical allocation, not UI instruction.

---

### 7. Action Buttons Redesign

Primary Button:
DEPLOY MISSION

Secondary Button:
AUTO ASSEMBLE CREW

Requirements:
- Game-style action buttons
- Strong border
- Icon (optional ⚡ or ▶)
- Press feedback:
  - Scale to 0.96
  - Glow intensifies briefly
- Disabled state:
  - Desaturated
  - Still framed

Must NOT look like form submission buttons.

---

### 8. Visual Depth Enhancements

Optional but recommended:
- Subtle grid background
- Low opacity noise layer
- Thin scanline overlay
- Corner frame accents on mission cards
- Slight elevation contrast

Avoid:
- Large blur shadows
- Excessive glow
- Flat card stacking

---

### 9. Micro Animations

Keep subtle and performance-safe.

Required:
- Header online indicator pulse
- Risk/reward bar fill animation (initial render only)
- Production-style shimmer on reward (very subtle)
- Button press feedback

Do NOT:
- Animate every mission constantly
- Use heavy shader effects
- Animate full list simultaneously

---

## Performance Constraints

- Maintain smooth scrolling
- Use lightweight animations (opacity, scale, translate)
- Avoid multiple active animation controllers per card
- No large blur or shader-based glow
- Maintain stable frame rate on mid-range devices

---

## Acceptance Criteria

The redesign is complete when:

- Header feels like a mission control HUD
- Crew status looks like system telemetry
- Mission cards feel like tactical dossiers
- Risk/reward visually dominate over description text
- Crew assignment feels strategic
- Buttons feel like game commands
- Visual identity matches Tech and Chamber screens
- No logic changes
- No performance regressions

---

## Final Intent

The Expeditions screen must feel like a live corporate temporal operations dashboard where the player deploys crews into dangerous time missions under system supervision.

It must communicate:
Authority  
Risk management  
Tactical deployment  
System oversight  

It must not resemble:
A mobile expandable list interface or productivity app page.