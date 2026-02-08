# How to Add Skills to Your Project for AI Agents

This guide explains how to structure your Flutter/Flame project so that AI coding assistants (like Claude, GitHub Copilot, Cursor, etc.) can read your game design documents and development guidelines.

---

## 📁 OPTION 1: Skills Directory (Recommended for Claude)

If you're using **Claude.ai** or **Claude Code**, you can add skills that Claude will automatically detect and reference.

### Project Structure:

```
your_project/
├── .claude/                    # Claude-specific configuration
│   └── skills/
│       ├── TIME_FACTORY_SKILL.md
│       └── IDLE_GAME_SKILL.md
├── lib/
├── assets/
├── pubspec.yaml
└── README.md
```

### Setup Steps:

1. **Create the `.claude` directory in your project root:**
   ```bash
   mkdir -p .claude/skills
   ```

2. **Add your skill files:**
   ```bash
   # Copy the skill files
   cp TIME_FACTORY_SKILL.md .claude/skills/
   cp IDLE_GAME_SKILL.md .claude/skills/
   ```

3. **When using Claude Code or Claude.ai:**
   - Claude will automatically detect these files
   - You can reference them by saying: "Read the TIME_FACTORY_SKILL before implementing X"
   - Or simply: "Follow the project skill guidelines"

---

## 📁 OPTION 2: Docs Directory (Universal for All AI Tools)

For broader compatibility with various AI assistants, use a standard documentation structure.

### Project Structure:

```
your_project/
├── docs/
│   ├── design/
│   │   ├── GDD.md                    # Game Design Document
│   │   └── balancing.md
│   ├── development/
│   │   ├── ARCHITECTURE.md           # Technical architecture
│   │   ├── STYLE_GUIDE.md            # Code style + UI/UX
│   │   └── SKILL_IDLE_GAME.md        # Idle game patterns
│   └── assets/
│       └── asset_guide.md
├── lib/
├── assets/
├── .ai/                              # AI-specific instructions
│   └── instructions.md
├── pubspec.yaml
└── README.md
```

### Setup Steps:

1. **Create the directory structure:**
   ```bash
   mkdir -p docs/{design,development,assets}
   mkdir -p .ai
   ```

2. **Add your documents:**
   ```bash
   cp TIME_FACTORY_GDD.md docs/design/GDD.md
   cp TIME_FACTORY_SKILL.md docs/development/STYLE_GUIDE.md
   cp IDLE_GAME_SKILL.md docs/development/SKILL_IDLE_GAME.md
   ```

3. **Create an AI instructions file:**
   
   Create `.ai/instructions.md`:
   ```markdown
   # AI Development Instructions
   
   When working on this project, ALWAYS:
   
   1. Read `docs/design/GDD.md` for game vision and mechanics
   2. Read `docs/development/STYLE_GUIDE.md` for code patterns and UI guidelines
   3. Read `docs/development/SKILL_IDLE_GAME.md` for idle game architecture
   
   ## Quick Reference
   - All colors: Use `TimeFactoryColors` constants
   - All text: Use `TimeFactoryTextStyles` constants
   - All currency: Use `BigInt`, never `double`
   - All UI: Apply neon glow + scanlines
   - All numbers: Format with `NumberFormatter.formatCE()`
   
   ## Before Implementing
   1. Check the relevant documentation section
   2. Follow the established patterns
   3. Maintain the cyberpunk aesthetic
   4. Test on mid-range devices
   ```

4. **Add to your README.md:**
   ```markdown
   ## 🤖 For AI Assistants
   
   Before generating code, please read:
   - `docs/design/GDD.md` - Full game design
   - `docs/development/STYLE_GUIDE.md` - Development patterns
   - `.ai/instructions.md` - Quick reference
   ```

---

## 📁 OPTION 3: Cursor/VSCode AI (Cursor Rules)

If using **Cursor IDE** or similar tools with `.cursorrules` support:

### Setup:

1. **Create `.cursorrules` in your project root:**
   ```bash
   touch .cursorrules
   ```

2. **Add content to `.cursorrules`:**
   ```
   # Time Factory: Paradox Industries - Development Rules
   
   ## Documentation
   Read these files before generating code:
   - docs/design/GDD.md - Game vision
   - docs/development/STYLE_GUIDE.md - Code patterns
   - docs/development/SKILL_IDLE_GAME.md - Architecture
   
   ## Core Rules
   
   ### Code Style
   - Use BigInt for all currency/resources (NEVER double)
   - Use Riverpod for state management
   - Use freezed for immutable models
   - Fixed time step: 30 TPS for game logic
   
   ### UI Requirements
   - All colors from TimeFactoryColors
   - All text from TimeFactoryTextStyles
   - Apply neon glow to all interactive elements
   - Add scanline overlay to all screens
   - Haptic feedback on all taps
   
   ### Visual Effects
   - Particle effects for CE gains
   - Glitch shader at high paradox (>70%)
   - Animated number displays
   - CRT scanlines always visible
   
   ### Performance
   - Target: 60 FPS on Pixel 4a
   - Update UI max 10 Hz (not every frame)
   - Compress saves with gzip
   - Cache expensive calculations
   
   ### Testing
   - Works offline with progress calculation
   - Save/load preserves exact state
   - No memory leaks after 30 min
   - All numbers formatted with suffixes
   
   ## File Structure
   Follow Clean Architecture:
   - core/ - Constants, utils, services
   - domain/ - Entities, repositories, use cases
   - data/ - Models, repository implementations
   - presentation/ - UI + Flame game components
   
   ## References
   - Cyberpunk aesthetic: Blade Runner 2049
   - Narrative: H.G. Wells' Time Machine
   - Game balance: docs/design/GDD.md
   ```

---

## 📁 OPTION 4: GitHub Copilot (Copilot Instructions)

For **GitHub Copilot**:

### Setup:

1. **Create `.github/copilot-instructions.md`:**
   ```bash
   mkdir -p .github
   touch .github/copilot-instructions.md
   ```

2. **Add content:**
   ```markdown
   # GitHub Copilot Instructions for Time Factory
   
   ## Project Context
   This is a cyberpunk idle game built with Flutter/Flame.
   
   ## Documentation
   Before suggesting code:
   1. Check docs/design/GDD.md for game mechanics
   2. Check docs/development/STYLE_GUIDE.md for patterns
   3. Check docs/development/SKILL_IDLE_GAME.md for architecture
   
   ## Code Standards
   
   ### Currency Handling
   ```dart
   // ✅ CORRECT
   BigInt chronoEnergy = BigInt.from(1000);
   chronoEnergy += BigInt.from(500);
   
   // ❌ WRONG
   double chronoEnergy = 1000.0;
   ```
   
   ### UI Components
   ```dart
   // ✅ CORRECT - Uses theme constants
   Container(
     decoration: BoxDecoration(
       border: Border.all(color: TimeFactoryColors.electricCyan),
       boxShadow: [
         BoxShadow(
           color: TimeFactoryColors.electricCyan.withOpacity(0.5),
           blurRadius: 20,
         ),
       ],
     ),
   )
   
   // ❌ WRONG - Hardcoded colors
   Container(
     decoration: BoxDecoration(
       border: Border.all(color: Colors.blue),
     ),
   )
   ```
   
   ### Number Formatting
   ```dart
   // ✅ CORRECT
   Text(NumberFormatter.formatCE(amount))
   
   // ❌ WRONG
   Text(amount.toString())
   ```
   
   ## When Generating Code
   - Always include neon glow effects
   - Always add haptic feedback to taps
   - Always use Riverpod providers
   - Always handle BigInt carefully
   - Always add particle effects for feedback
   ```

---

## 🎯 HOW TO USE WITH AI ASSISTANTS

### When Chatting with Claude:

```
You: "Read the TIME_FACTORY_SKILL and implement the worker card UI"

Claude: [Reads .claude/skills/TIME_FACTORY_SKILL.md]
        [Generates code following all the patterns and styles]
```

### When Using Cursor:

```
# Cursor will automatically read .cursorrules
# Just ask normally:

"Create the paradox meter widget"

# Cursor reads the rules and applies:
# - TimeFactoryColors
# - Neon glow effects
# - Proper state management
```

### When Using GitHub Copilot:

```
// Copilot reads .github/copilot-instructions.md
// Start typing and it suggests code that follows your patterns:

class ParadoxMeter extends ConsumerWidget {
  // [Copilot suggests implementation using your colors/styles]
```

### When Using AI Chat Tools (ChatGPT, etc.):

```
You: "I'm working on Time Factory. Here are the guidelines:
     [paste relevant sections from SKILL.md]
     
     Now implement the prestige screen."
```

---

## 📝 RECOMMENDED SETUP (Complete)

Here's the full structure I recommend:

```
time_factory/
├── .claude/                          # For Claude AI
│   └── skills/
│       ├── TIME_FACTORY_SKILL.md
│       └── IDLE_GAME_SKILL.md
│
├── .cursorrules                      # For Cursor IDE
│
├── .github/
│   └── copilot-instructions.md       # For GitHub Copilot
│
├── docs/
│   ├── design/
│   │   ├── GDD.md                    # Full game design
│   │   ├── narrative.md
│   │   └── balancing.xlsx
│   ├── development/
│   │   ├── ARCHITECTURE.md
│   │   ├── STYLE_GUIDE.md
│   │   └── PATTERNS.md
│   └── assets/
│       ├── color_palette.png
│       └── ui_mockups/
│
├── .ai/
│   └── instructions.md               # Universal AI guide
│
├── lib/
│   ├── core/
│   ├── domain/
│   ├── data/
│   └── presentation/
│
├── README.md
└── pubspec.yaml
```

### Create This Structure:

```bash
# Create all directories
mkdir -p .claude/skills
mkdir -p .github
mkdir -p docs/{design,development,assets}
mkdir -p .ai
mkdir -p lib/{core,domain,data,presentation}

# Copy skill files
cp TIME_FACTORY_SKILL.md .claude/skills/
cp IDLE_GAME_SKILL.md .claude/skills/
cp TIME_FACTORY_GDD.md docs/design/GDD.md

# Create AI instruction files
# (Create .cursorrules, copilot-instructions.md, etc. as shown above)
```

---

## 🚀 QUICK START COMMANDS

### For Claude Users:
```bash
# Setup for Claude
mkdir -p .claude/skills
cp TIME_FACTORY_SKILL.md .claude/skills/
cp IDLE_GAME_SKILL.md .claude/skills/

# Then in Claude:
# "Read the TIME_FACTORY_SKILL before starting"
```

### For Cursor Users:
```bash
# Create rules file
cat > .cursorrules << 'EOF'
Read docs/development/STYLE_GUIDE.md before generating code.
Always use TimeFactoryColors and TimeFactoryTextStyles.
Always use BigInt for currency, never double.
Apply neon glow to all interactive UI elements.
EOF

# Add docs
mkdir -p docs/development
cp TIME_FACTORY_SKILL.md docs/development/STYLE_GUIDE.md
```

### For VS Code + Copilot:
```bash
# Create Copilot instructions
mkdir -p .github
cp TIME_FACTORY_SKILL.md .github/copilot-instructions.md
```

---

## 💡 PRO TIPS

1. **Keep docs updated**: When you change patterns, update the skill files
2. **Reference in commits**: "Implemented according to TIME_FACTORY_SKILL section 3.2"
3. **Onboarding**: New AI sessions start with "Read the project skills"
4. **Version control**: Commit `.claude/`, `.cursorrules`, etc. to git
5. **Team alignment**: Everyone uses the same AI instructions

---

## ✅ VERIFICATION

To verify your AI can see the docs:

### Claude:
```
"List all skill files you can see in this project"
```

### Cursor:
```
CMD/CTRL + Shift + P → "Cursor: Show Rules"
```

### Copilot:
```
Check if .github/copilot-instructions.md exists in repo
```

---

## 🎉 YOU'RE READY!

Now when you ask any AI assistant to help code, just say:

**"Follow the TIME_FACTORY_SKILL guidelines and implement [feature]"**

The AI will:
✅ Use correct colors and styles  
✅ Follow architecture patterns  
✅ Handle BigInt properly  
✅ Add visual effects  
✅ Maintain the cyberpunk aesthetic  

Happy coding! ⚡🕰️
