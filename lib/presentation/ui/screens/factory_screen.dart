import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/presentation/game/time_factory_game.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/screens/tech_screen.dart';
import 'package:time_factory/presentation/ui/screens/chambers_screen.dart';
import 'package:time_factory/presentation/ui/screens/gacha_screen.dart';
import 'package:time_factory/presentation/ui/tabs/prestige_tab.dart';
import 'package:time_factory/presentation/ui/widgets/ce_header_bar.dart';
import 'package:time_factory/presentation/ui/widgets/glass_bottom_dock.dart';
import 'package:time_factory/presentation/ui/widgets/chaos_button.dart';
import 'package:time_factory/presentation/ui/widgets/save_indicator.dart';
import 'package:time_factory/presentation/ui/widgets/scanline_overlay.dart';
import 'package:time_factory/presentation/ui/widgets/glitch_overlay.dart';
import 'package:time_factory/presentation/ui/widgets/loop_reset_timer.dart';
import 'package:time_factory/presentation/ui/widgets/system_monitor_text.dart';
import 'package:time_factory/presentation/ui/widgets/theme_background.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/era_unlock_dialog.dart';
import 'package:time_factory/core/theme/neon_theme.dart';

class FactoryScreen extends ConsumerStatefulWidget {
  const FactoryScreen({super.key});

  @override
  ConsumerState<FactoryScreen> createState() => _FactoryScreenState();
}

class _FactoryScreenState extends ConsumerState<FactoryScreen> {
  late final TimeFactoryGame _game;
  int _selectedTab = 1; // Default to Factory (1)

  @override
  void initState() {
    super.initState();
    _game = TimeFactoryGame(ref);
  }

  @override
  Widget build(BuildContext context) {
    // Only watch what affects this screen's structure (tab, era)
    final size = MediaQuery.of(context).size;
    final globalTheme = ref.watch(themeProvider);

    // Determine active theme based on tab:
    // Tab 1 (Factory) -> Era Theme (global)
    // All others -> Neon Theme (reverted)
    final activeTheme = _selectedTab == 1 ? globalTheme : NeonTheme();

    // Listen to worker changes to sync with Flame, avoiding rebuilds
    ref.listen(gameStateProvider.select((s) => s.activeWorkers), (
      previous,
      next,
    ) {
      if (_game.isMounted) {
        _game.syncWorkers(next);
      }
    });

    // Listen to era unlocks
    ref.listen(gameStateProvider.select((s) => s.unlockedEras), (
      previous,
      next,
    ) {
      if (previous != null && next.length > previous.length) {
        // Find the new era
        final newEra = next.difference(previous).first;
        final theme = EraTheme.fromId(newEra);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EraUnlockDialog(
            eraTheme: theme,
            onTravel: () {
              ref.read(gameStateProvider.notifier).switchToEra(newEra);
            },
          ),
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: activeTheme.colors.background,
        body: Stack(
          children: [
            // 1. Dynamic Backgrounds
            Positioned.fill(
              child: RepaintBoundary(
                // Only animate if selected tab is Factory (1)
                child: ThemeBackground(
                  forceStatic: _selectedTab != 1,
                  child: const SizedBox.shrink(),
                ),
              ),
            ),

            // 2. Game Layer
            if (_selectedTab == 1)
              Positioned.fill(
                child: RepaintBoundary(child: GameWidget(game: _game)),
              ),

            // 3. Main Content Column
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Global Resource Header Bar
                    if (_selectedTab != 0) const ResourceAppBar(),

                    // Tab Content
                    Expanded(child: _buildCurrentTab(size)),
                  ],
                ),
              ),
            ),

            // 4. Bottom Command Dock
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: GlassBottomDock(
                  selectedIndex: _selectedTab,
                  onItemSelected: (index) =>
                      setState(() => _selectedTab = index),
                  themeOverride: activeTheme,
                ),
              ),
            ),

            // 5. Scanline Overlay
            const Positioned.fill(
              child: RepaintBoundary(
                child: ScanlineOverlay(opacity: 0.015, lineSpacing: 4),
              ),
            ),

            // 6. Glitch Overlay (Chaos Event)
            Consumer(
              builder: (context, ref, child) {
                final isChaosActive = ref.watch(
                  gameStateProvider.select((s) => s.paradoxEventActive),
                );
                return GlitchOverlay(isActive: isChaosActive);
              },
            ),

            // 7. Save Indicator
            const Positioned(
              top: 8,
              right: 8,
              child: SafeArea(child: SaveIndicator()),
            ),

            // 8. Chaos Trigger Button
            Positioned(
              right: 16,
              bottom: 220,
              child: Consumer(
                builder: (context, ref, child) {
                  final paradoxLevel = ref.watch(
                    gameStateProvider.select((s) => s.paradoxLevel),
                  );
                  final isChaosActive = ref.watch(
                    gameStateProvider.select((s) => s.paradoxEventActive),
                  );

                  if (paradoxLevel < 0.8 || isChaosActive) {
                    return const SizedBox.shrink();
                  }

                  return ChaosButton(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).embraceChaos();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the current tab content
  Widget _buildCurrentTab(Size size) {
    switch (_selectedTab) {
      case 0:
        return const ChambersScreen();
      case 1:
        return _buildFactoryTab(size);
      case 2:
        return const GachaScreen();
      case 3:
        return const TechScreen();
      case 4:
        return const PrestigeTab();
      default:
        return const SizedBox.shrink();
    }
  }

  /// Factory Tab - Reactor Dashboard
  Widget _buildFactoryTab(Size size) {
    return Stack(
      children: [
        // Loop Reset Timer (top center)
        const Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: RepaintBoundary(
              child: LoopResetTimer(
                timeRemaining: Duration(minutes: 0, seconds: 45),
              ),
            ),
          ),
        ),

        // System Monitor Text (bottom right)
        Positioned(
          bottom: 160,
          right: 16,
          child: Consumer(
            builder: (context, ref, child) {
              final paradoxLevel = ref.watch(
                gameStateProvider.select((s) => s.paradoxLevel),
              );
              return SystemMonitorText(gridIntegrity: 1.0 - paradoxLevel);
            },
          ),
        ),
      ],
    );
  }
}
