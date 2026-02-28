# Product Requirements Document (PRD)

## Project Title
Tech Screen Game Feel Refactor

## Author
[Your Name]

## Status
Draft

## Target Version
Next Minor UI Release

---

# 1. Overview

The current Tech Screen maintains the neon futuristic aesthetic of the app but visually resembles a sci-fi settings or configuration interface rather than a game upgrade system.

This project aims to refactor the Tech Screen UI to:

- Increase “game feel”
- Reinforce upgrade-module identity
- Improve visual hierarchy
- Add subtle game-style micro-interactions
- Maintain existing neon futuristic branding

The goal is NOT to redesign the app’s identity, but to enhance the Tech Screen so it feels like an upgrade console inside an idle game.

---

# 2. Problem Statement

Users currently experience the Tech Screen as:

- Visually clean but “app-like”
- Similar to configuration panels
- Lacking strong interactive feedback
- Missing game-style telemetry and module identity

This reduces perceived depth and engagement compared to the Factory screen and overall game concept.

---

# 3. Goals

### Primary Goals
- Transform upgrade cards into technical “modules”
- Replace generic progress bar with HUD-style segmented telemetry
- Replace form-style buttons with game-style action buttons
- Introduce subtle micro-animations
- Increase sense of depth via HUD overlays

### Secondary Goals
- Improve information hierarchy
- Reduce visual flatness
- Reinforce “Temporal System Control Panel” identity

---

# 4. Non-Goals

- Converting the screen to pixel art
- Changing business logic
- Modifying upgrade mechanics
- Altering navigation architecture
- Adding heavy GPU effects
- Changing app-wide theme

---

# 5. Target User Experience

The Tech Screen should feel like:

> A corporate temporal system upgrade matrix inside a cyberpunk idle game.

It should communicate:
- Active modules
- Technical system IDs
- System state
- Upgrade readiness
- Telemetry feedback

It should NOT feel like:
- A configuration/settings page
- A form-based UI
- A static information list

---

# 6. Functional Requirements

## 6.1 Replace Upgrade Cards with Module Panels

Each upgrade item must display:

- Module ID (e.g. MOD-05, SYS_1C1)
- Category label
- Level indicator (LVL X)
- Module name (primary focus)
- One-line description (truncate if needed)
- Primary effect (visually emphasized)
- Cost indicator
- Action button

### Module States
- UPGRADABLE
- MAXED
- LOCKED

Each state must have a visually distinct style.

---

## 6.2 Replace Progress Bar

The current progress bar must be replaced with a HUD-style segmented bar.

Requirements:
- Hard border
- Solid fill
- Optional tick segments
- Percentage label
- Optional scanline animation

No soft material gradients.

---

## 6.3 Replace MAX Button

The action button must:

- Look like a game interaction element
- Include icon (⚡ or ▶)
- Provide press feedback (scale 0.96)
- Have distinct active/disabled states
- Avoid material form appearance

---

## 6.4 Add Micro Animations

Subtle animations required:

- Main energy value pulse (1–2% scale loop)
- Header icon glow breathing
- Progress bar scanline sweep
- Very subtle random flicker on active upgrade button

All animations must:
- Be subtle
- Avoid distraction
- Maintain 60 FPS
- Avoid animating all list items simultaneously

---

## 6.5 Add Subtle Depth Layers

Optional but recommended:

- Low-opacity grid overlay
- Light grain/noise layer
- Subtle scanlines

Opacity must remain low to preserve readability.

---

# 7. Visual Requirements

## 7.1 Color

- Maintain neon futuristic palette
- Do not introduce new era-based palettes
- Increase contrast slightly
- Use glow selectively (not globally)

## 7.2 Layout

- Use spacing multiples of 4
- Reduce overly large corner radii
- Avoid overly rounded cards
- Increase visual density slightly

## 7.3 Hierarchy

Priority order:
1. Module Name
2. Primary Effect
3. Status
4. Cost
5. Description

Descriptions must be limited to one line.

---

# 8. Technical Requirements (Flutter)

## Required New Components

- NeonHudScaffold
- TechHudHeader
- HudProgressBarSegmented
- TechModuleCard
- GameActionButton

## Performance Constraints

- Maintain smooth scrolling
- Avoid rebuild-heavy animation patterns
- Avoid large blur shaders
- Limit animation controllers

---

# 9. Success Metrics

This refactor is successful if:

- Screen feels like a game system, not a settings page
- Modules look installable and technical
- Upgrade interaction feels responsive
- Telemetry (progress + values) feels dynamic
- No performance regressions occur
- Visual consistency with neon identity is maintained

---

# 10. Risks

| Risk | Mitigation |
|------|------------|
| Overuse of glow | Limit glow to key elements |
| Performance degradation | Keep animations lightweight |
| Overcomplication | Keep design minimal but structured |
| Visual clutter | Limit description length |

---

# 11. Acceptance Criteria

- All upgrade items use module-style layout
- Progress bar replaced with segmented HUD version
- Action buttons redesigned and interactive
- Micro animations implemented
- Depth overlays implemented or validated
- No functional regression
- QA validated smooth performance

---

# 12. Timeline (Suggested)

Phase 1 – Component Creation  
Phase 2 – Module Refactor  
Phase 3 – Animation Integration  
Phase 4 – Visual Polish  
Phase 5 – QA & Performance Testing  

---

# 13. Final Design Intent

The Tech Screen should visually communicate:

A living, corporate-grade temporal system upgrade console  
inside a neon cyberpunk idle game.

It must feel interactive, technical, and game-oriented —
without abandoning the app’s futuristic neon identity.