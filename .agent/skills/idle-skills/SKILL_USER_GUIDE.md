# Flutter + Flame Game UI Skill - User Guide

## What This Skill Does

This skill helps AI assistants create beautiful, professional game user interfaces using Flutter and the Flame game engine. It includes:

- **Ready-to-use component templates**: Buttons, health bars, score displays, timers, panels, and more
- **Animation patterns**: Entrance/exit animations, transitions, particle effects, and microinteractions
- **Layout systems**: Responsive positioning, grid layouts, safe areas, and aspect ratio handling
- **Complete menu implementations**: Main menu, pause menu, settings, game over screens
- **HUD components**: Score counters, combo meters, mini-maps, segmented health bars
- **Dialog system**: Modal dialogs with animations and customization
- **Particle effects**: Pre-configured presets for explosions, confetti, sparkles, and more
- **Theme template**: Comprehensive styling configuration for consistent UI

## What Gets Triggered

The skill automatically activates when you ask the AI to:

- Create game menus (main menu, pause, settings, game over)
- Build HUD elements (health bars, score displays, timers)
- Design game UI layouts
- Add game animations or particle effects
- Work with Flutter + Flame for game development
- Create buttons, panels, or other game UI components

## How to Use This Skill

### Installation

1. Upload the `flutter-flame-game-ui.skill` file to your AI assistant
2. The skill will be available for all your Flutter + Flame game UI tasks

### Example Requests

**Basic UI Creation:**
- "Create a main menu for my game with Play, Settings, and Exit buttons"
- "Build a HUD with health bar, score counter, and timer"
- "Design a pause menu with resume and quit options"

**Advanced Features:**
- "Create an animated achievement popup with particle effects"
- "Build a responsive inventory grid that works on different screen sizes"
- "Add a combo counter with smooth animations and reset timer"

**Custom Components:**
- "Create a custom button with press animations and hover effects"
- "Design a segmented health bar that loses segments with animation"
- "Build a mini-map component for my game"

### What You'll Get

When you ask for game UI, the AI will:

1. **Use best practices** from the skill's extensive documentation
2. **Apply professional animations** with proper timing and easing curves
3. **Ensure responsive layouts** that work across different devices
4. **Include performance optimizations** like object pooling and efficient rendering
5. **Follow the component architecture** patterns from Flame engine

### Structure of the Skill

```
flutter-flame-game-ui/
├── SKILL.md                          # Main guidance document
├── references/                       # Detailed documentation
│   ├── ui_components.md             # Ready-to-use component templates
│   ├── animation_patterns.md        # Complex animation sequences
│   ├── animation_curves.md          # Easing curve reference
│   ├── layout_systems.md            # Responsive positioning
│   ├── menu_patterns.md             # Complete menu implementations
│   ├── hud_components.md            # HUD element templates
│   └── dialog_system.md             # Modal dialog system
└── assets/                          # Reusable resources
    ├── particles/
    │   └── presets.json             # Particle effect configurations
    └── theme_template.dart          # Game UI theme configuration
```

### Tips for Best Results

1. **Be specific**: Mention the type of UI element you need (button, health bar, menu, etc.)
2. **Describe the behavior**: Tell the AI if you want animations, transitions, or special effects
3. **Mention platform**: Specify if you're targeting mobile, desktop, or web
4. **Reference examples**: Ask for patterns similar to the templates in the skill

### Customization

The skill includes a theme template (`assets/theme_template.dart`) that you can customize with:
- Color schemes
- Typography styles
- Spacing values
- Animation durations
- Button styles
- And more!

Copy this template to your project and modify it to match your game's visual style.

## Technical Details

**Framework**: Flutter with Flame game engine
**Component System**: Uses Flame's component-based architecture
**Animation System**: Flame's effect system with easing curves
**Performance**: Optimized for 60 FPS on mobile devices

## Support

This skill was created using Anthropic's skill creation system. It contains condensed best practices from extensive testing and iteration with Flutter + Flame game development.

If you encounter any issues or want to extend the skill, you can:
1. Edit the SKILL.md or reference files
2. Add new component templates
3. Create additional particle effect presets
4. Expand the theme configuration

## Example Output

When you ask to create a main menu, the AI will generate complete, production-ready code including:
- Proper component structure
- Smooth entrance animations
- Responsive positioning
- Touch/click handling
- Professional visual styling
- Performance optimizations

All based on proven patterns from the skill's documentation.

---

**Ready to create beautiful game UIs?** Just ask your AI assistant to build what you need, and the skill will guide it to produce professional results!
