---
title: "PRD: App-Wide Dialogs Refactor to Neon Ops HUD"
status: "Pending"
target_directory: "lib/presentation/ui/dialogs/"
---

# Objective
Refactor all existing dialogs across the app (in `lib/presentation/ui/dialogs/` and inline dialogs where applicable) to match the new "neon futuristic game HUD" operations dashboard aesthetic. The goal is to strip away the soft, mobile-friendly curves (e.g., 16px border radii) and replace them with strict, high-authority cyberpunk terminal visuals (4px border radii, strict typography, segmented layouts, and tactical depth) to align with recent refactors like the Expeditions, Chamber, and Tech screens.

# Current State Analysis
Dialogs currently live mainly in `lib/presentation/ui/dialogs/` (12 files, e.g., `worker_result_dialog.dart`, `offline_dialog.dart`, `assign_worker_dialog.dart`).
Current attributes to deprecate:
*   Large border radii (`BorderRadius.circular(16)` or `24`).
*   Standard Material buttons (`ElevatedButton`, `OutlinedButton`, `TextButton`).
*   Soft, generic drop-shadows.
*   Basic `Text` headers lacking system identity or corporate game styling.

# Global Aesthetic Rules (The "Ops HUD" Standard)
1.  **Crisp Borders & Tactical Radii**: All main dialog containers must use `BorderRadius.circular(4)`. No soft corners.
2.  **Color Palette**:
    *   **Background**: Deep cyber black/blue, e.g., `Color(0xFF03070C)` or `c.primary.withValues(alpha: 0.05)` layered.
    *   **Borders**: Thin 1px to 2px borders using glowing theme accents (`combinedAccent`, `rarityColor`, `TimeFactoryColors.voltageYellow`, or `c.primary.withValues(alpha: 0.35)`).
    *   **BoxShadow**: Highly controlled, targeted glows rather than generic drop shadows (e.g., `blurRadius: 12`, `withValues(alpha: 0.1)`).
3.  **Typography & Hierarchy**:
    *   **Titles**: Use `Orbitron` font, uppercase, strict letter spacing (e.g., `letterSpacing: 1.5`), and bold weights.
    *   **System Identifiers**: Include small, mono-spaced system tags in dialog headers (e.g., `> SYS.DLG`, `OVERRIDE_CONFIRM`).
    *   **Body Text**: Use `NeonTheme().typography.bodyMedium`, mono-style numbers.
4.  **Action Buttons**: Replace *all* Material buttons with `GameActionButton` (or equivalent game button widgets like `CyberButton` if applicable) configured with `isGlowing` states, tactical heights (e.g., `height: 48`), and neon accents.
5.  **Divider Lines**: Use 1px, low-opacity primary colors (`c.primary.withValues(alpha: 0.1)`) instead of standard `Divider()`.

# Targeted Files & Refactor Plan

## Phase 1: Core System Dialogs
These dialogs are frequently seen by the user and dictate the flow of the game.
1.  **`offline_dialog.dart`**
    *   Refactor main container to 4px radius, neon frame.
    *   Style the "Time Passed" and "Resources Yielded" as tactical metrics pods.
    *   Replace action buttons with `GameActionButton` (e.g., "INITIALIZE SYSTEMS").
2.  **`daily_login_dialog.dart`**
    *   Rebuild day-cards as dossier-style slots (similar to Expedition cards).
    *   Convert "Claim" buttons.
3.  **`worker_result_dialog.dart`** & **`worker_detail_dialog.dart`**
    *   Add a visual HUD scanning effect or border brackets around the worker portrait.
    *   Display rarity color as the primary dialog border accent.
    *   Change standard typography to `Orbitron` titles.

## Phase 2: Action & Confirmation Dialogs
High-stakes operations that need to look like override system prompts.
1.  **`paradox_confirmation_dialog.dart`** & **`upgrade_confirmation_dialog.dart`**
    *   Style these as "WARNING/CRITICAL" system prompts (using `Colors.redAccent` or `TimeFactoryColors.voltageYellow`).
    *   Replace standard Cancel/Confirm buttons with paired `GameActionButton`s. Add a `System Alert` mono header.
2.  **`era_unlock_dialog.dart`**
    *   Make it feel like a "NEW TEMPORAL TARGET ACQUIRED" screen. High visual glow.
3.  **`expedition_reward_dialog.dart`**
    *   Align with the Expeditions screen active/completed card aesthetic. 4px borders, itemized loot list with small rarity chips.

## Phase 3: Technical Dialogs & Management Sheets
1.  **`assign_worker_dialog.dart`**, **`fit_worker_dialog.dart`**, **`deploy_worker_dialog.dart`**
    *   Convert worker list tiles into HUD data rows.
    *   Use the new neon socket representations (like in Expeditions) where applicable.
2.  **`artifact_inventory_dialog.dart`**
    *   A massive dialog that needs grid refactoring. Use 4px bordered grids for artifacts, dark sub-backgrounds for item slots, and custom glowing borders for active items.

# Implementation Requirements
*   **No Logic Changes**: Purely UI and UX presentation updates. The internal logic and state management connected to Riverpod must remain entirely untouched.
*   **API Compatibility**: Continue to use `showDialog` or `showModalBottomSheet`. Just update the returned `Dialog(child: ...)` contents.
*   **Constant Styling**: Always lean heavily into `.withValues(alpha: ...)` for transparent layering instead of solid colors, ensuring strong visual depth. Utilize `TimeFactoryColors` and `AppHugeIcons`.

# Definition of Done
*   All files in `lib/presentation/ui/dialogs/` have been updated to the 4px border radius Ops HUD style.
*   No standard Material `ElevatedButton`, `OutlinedButton`, or `TextButton` remains in these dialogs.
*   Code passes styling lints (e.g., unused variables removed, `const` constructors where possible).
*   Visual regressions or out-of-style rounded corners are entirely removed from the app's pop-ups.
