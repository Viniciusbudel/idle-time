# Product Requirements Document (PRD): UI Atoms Refactoring

## 1. Objective
Refactor all individual UI Atoms located in `lib/presentation/ui/atoms/` to strictly align with the new "neon futuristic game HUD" aesthetic established across the application's dialogs and main screens. The goal is to enforce rigid geometric styling, eliminate generic or legacy UI traits, and achieve 100% cohesion in the app's visual language.

## 2. Scope
This refactoring applies to the following 13 components in `lib/presentation/ui/atoms/`:

1. `achievement_toast.dart`
2. `animated_number.dart`
3. `artifact_drop_banner.dart`
4. `cyber_button.dart`
5. `game_action_button.dart`
6. `glitch_overlay.dart`
7. `hud_segmented_progress_bar.dart`
8. `merge_effect_overlay.dart`
9. `save_indicator.dart`
10. `scanline_overlay.dart`
11. `system_monitor_text.dart`
12. `void_hiring_overlay.dart`
13. `worker_tile.dart`

## 3. Core Design Principles & Strict Requirements

### 3.1. Geometry & Layout
*   **Border Radii:** Strictly enforce `BorderRadius.circular(4)` as the maximum curve. Replace any instances of `circular(8)`, `circular(12)`, or pill-shaped geometries.
*   **Segmented Structures:** UI elements should look like terminal panels or tactical readouts. If using custom clippers (e.g., in `cyber_button.dart`), ensure the clip shape is strictly angular (chamfered corners are acceptable).

### 3.2. Color Palette & Theming
*   **Backgrounds:** Use deep cyber black (`Color(0xFF03070C)`) for enclosed containers, banners, and tiles instead of simple transparent blacks or grays.
*   **Neon Accents:** Rely on the `NeonTheme` and `TimeFactoryColors` (Acid Green, Voltage Yellow, Hot Magenta, Electric Cyan).
*   **Alpha Values:** Emphatically replace deprecated `.withOpacity()` calls with the newer `.withValues(alpha: X)` syntax for consistent color manipulation.
*   **Glow Effects:** Use discrete `BoxShadow` glows tied to neon accent colors when an atom is in an active, focused, or distinct state. Keep the blur radius sharp rather than overly muddy (e.g., `blurRadius: 10`, `spreadRadius: 0` or `1`).

### 3.3. Typography
*   **Fonts:** Apply the `Orbitron` font-family natively to major text/labels via `TextStyle(fontFamily: 'Orbitron', ...)`. Use `letterSpacing: 1.5` or `2.0` to establish a technical feel.
*   **Secondary Text:** For body/monospace content (like animated numbers or monitor texts), ensure `TimeFactoryTextStyles.bodyMono` or `.numbers` is used along with uppercase transformations (`.toUpperCase()`).

### 3.4. Overlays & Visual Effects
*   `glitch_overlay.dart`, `merge_effect_overlay.dart`, `scanline_overlay.dart`: Ensure these overlays feel natively tuned to the new color scheme. Adjust blending modes or alpha channels if they currently wash out the new deep black backgrounds.

## 4. Specific Component Modifications

### Buttons (`cyber_button.dart` & `game_action_button.dart`)
*   Review if `cyber_button.dart` and `game_action_button.dart` overlap in utility.
*   If `cyber_button` uses `CustomClipper` with a chamfered edge, ensure the border/outline perfectly matches the clip (this usually requires a `CustomPaint` or equivalent trick rather than `BoxDecoration` borders which get clipped incorrectly).
*   Ensure all buttons use the Orbitron font.
*   Apply subtle neon hover/pressed effects or active color fills to button backgrounds.

### Status Indicators (`achievement_toast.dart`, `artifact_drop_banner.dart`, `save_indicator.dart`)
*   Implement `0xFF03070C` backgrounds for the core toast/banner body.
*   Wrap in 1px neon borders that match the toast type/rarity.
*   Apply 4px corner radii. Use Orbitron for the main text.

### Tiles & Layout Parts (`worker_tile.dart`, `hud_segmented_progress_bar.dart`)
*   `worker_tile.dart`: Bring this in line with `WorkerDetailDialog`'s top-level info header. Remove any generic rounded card look. Add left/right border accents (e.g., a thick 3px left border in the rarity color).
*   `hud_segmented_progress_bar.dart`: Ensure the gaps between segments and segment colors are extremely crisp inside 4px containers.

## 5. Development Steps Checklist

*   [ ] **Step 1:** Audit `game_action_button.dart` and `cyber_button.dart`. Refactor to 4px borders, Orbitron typography, and `.withValues(alpha:)`.
*   [ ] **Step 2:** Refactor Notification & Banners (`achievement_toast.dart`, `artifact_drop_banner.dart`, `save_indicator.dart`).
*   [ ] **Step 3:** Refactor List/Grid Items (`worker_tile.dart`). Ensure backgrounds are `.withValues()` of rarity colors against deep black grids.
*   [ ] **Step 4:** Refactor HUD Specifics (`hud_segmented_progress_bar.dart`, `system_monitor_text.dart`, `animated_number.dart`). Update sizing, typography, and crisp segmenting.
*   [ ] **Step 5:** Final pass on visual effects overlays (`glitch_overlay.dart`, `merge_effect_overlay.dart`, `scanline_overlay.dart`, `void_hiring_overlay.dart`).
*   [ ] **Step 6:** Run `UI/UX Audit` and standard code linting. Ensure zero semantic errors and correct widget imports.

## 6. Success Criteria
*   Opening any screen referencing the above atoms exhibits no stylistic discrepancies compared to the updated `ExpeditionsScreen` and refactored Dialogs.
*   Total absence of `circular(8)` or `circular(12)` in favor of `circular(4)`.
*   Successful conversion of `.withOpacity()` -> `.withValues(alpha: ...)`.
*   No standard Android/Material dropshadows—only targeted neon `BoxShadow`s or none.
