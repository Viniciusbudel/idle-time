import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/presentation/game/time_factory_game.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/pages/tech_screen.dart';
import 'package:time_factory/presentation/ui/pages/chambers_screen.dart';
import 'package:time_factory/presentation/ui/pages/gacha_screen.dart';
import 'package:time_factory/presentation/ui/pages/prestige_tab.dart';
import 'package:time_factory/presentation/ui/organisms/ce_header_bar.dart';
import 'package:time_factory/presentation/ui/organisms/glass_bottom_dock.dart';
import 'package:time_factory/presentation/ui/widgets/chaos_button.dart';
import 'package:time_factory/presentation/ui/atoms/save_indicator.dart';
import 'package:time_factory/presentation/ui/atoms/scanline_overlay.dart';
import 'package:time_factory/presentation/ui/atoms/glitch_overlay.dart';
import 'package:time_factory/presentation/ui/atoms/system_monitor_text.dart';
import 'package:time_factory/presentation/ui/templates/theme_background.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/era_unlock_dialog.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/presentation/ui/molecules/time_warp_indicator.dart';
import 'package:time_factory/presentation/ui/molecules/auto_click_indicator.dart';
import 'package:time_factory/presentation/ui/molecules/daily_objective_panel.dart';
import 'package:time_factory/presentation/ui/molecules/tutorial_overlay.dart';
import 'package:time_factory/core/constants/tutorial_keys.dart';
import 'package:time_factory/presentation/ui/molecules/achievement_listener.dart';
import 'package:time_factory/presentation/ui/dialogs/daily_login_dialog.dart'; // NEW
import 'package:time_factory/presentation/state/artifact_drop_event_provider.dart';
import 'package:time_factory/presentation/state/performance_mode_provider.dart';
import 'package:time_factory/presentation/ui/atoms/artifact_drop_banner.dart';

class FactoryScreen extends ConsumerStatefulWidget {
  const FactoryScreen({super.key});

  @override
  ConsumerState<FactoryScreen> createState() => _FactoryScreenState();
}

class _FactoryScreenState extends ConsumerState<FactoryScreen> {
  late final TimeFactoryGame _game;
  int _selectedTab = 1; // Default to Factory (1)

  // Chaos Button Randomization
  final Random _rng = Random();
  Alignment _chaosAlignment = Alignment.bottomRight;

  @override
  void initState() {
    super.initState();
    _game = TimeFactoryGame(ref);
    _randomizeChaosPosition();

    // Check for daily rewards after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(gameStateProvider.notifier);
      final state = ref.read(gameStateProvider);
      // Show if available and tutorial is passed "Welcome" (step > 0)
      if (notifier.isDailyRewardAvailable && state.tutorialStep > 0) {
        DailyLoginDialog.show(context);
      }
    });
  }

  void _randomizeChaosPosition() {
    // Avoid the very edges to prevent being unclickable or hidden by safe areas
    // x: -0.8 to 0.8, y: -0.6 to 0.6 (avoid dock/header areas roughly)
    setState(() {
      _chaosAlignment = Alignment(
        (_rng.nextDouble() * 1.6) - 0.8,
        (_rng.nextDouble() * 1.2) - 0.6,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only watch what affects this screen's structure (tab, era)
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final performanceMode = ref.watch(performanceModeProvider);
    final lowPerformanceMode = _isLowPerformanceMode(
      performanceMode,
      size,
      mediaQuery.devicePixelRatio,
    );
    final globalTheme = ref.watch(themeProvider);
    _game.setLowPerformanceMode(lowPerformanceMode);

    // Determine active theme based on tab:
    // Tab 1 (Factory) -> Era Theme (global)
    // All others -> Neon Theme (reverted)
    final activeTheme = _selectedTab == 1 ? globalTheme : const NeonTheme();

    // Listen to worker map changes and derive active workers from the
    // stable map reference. This avoids false-positive syncs caused by
    // activeWorkers list allocation on each state read.
    ref.listen(gameStateProvider.select((s) => s.workers), (previous, next) {
      if (_game.isMounted) {
        final activeWorkers = next.values
            .where((worker) => worker.isDeployed)
            .toList();
        _game.syncWorkers(activeWorkers, animate: true);
      }
    });

    // Listen to current era changes for visual updates (Reactor Swap)
    ref.listen(gameStateProvider.select((s) => s.currentEraId), (
      previous,
      next,
    ) {
      if (previous != next && _game.isMounted) {
        _game.updateEra(next);
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

    // Listen to drop events
    ref.listen(artifactDropEventProvider, (previous, next) {
      if (next != null) {
        ArtifactDropBanner.show(context, next);
      }
    });

    return AchievementListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
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
                    reducedMotion: lowPerformanceMode,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),

              // 2. Game Layer
              if (_selectedTab == 1)
                Positioned.fill(
                  key: TutorialKeys.reactor,
                  child: RepaintBoundary(child: GameWidget(game: _game)),
                ),

              // 3. Main Content Column
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Global Resource Header Bar
                      if (_selectedTab != 0)
                        ResourceAppBar( ),

                      // Tab Content
                      Expanded(
                        key: TutorialKeys.mainContent,
                        child: _buildCurrentTab(lowPerformanceMode),
                      ),
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
              if (!lowPerformanceMode)
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
                  return GlitchOverlay(
                    isActive: isChaosActive,
                    intensity: lowPerformanceMode ? 0.6 : 1.0,
                  );
                },
              ),

              // 7. Save Indicator
              Positioned(
                top: _saveIndicatorTop(size),
                right: 8,
                child: const SafeArea(child: SaveIndicator()),
              ),

              // 8. Chaos Trigger Button (Factory Tab Only)
              if (_selectedTab == 1)
                Align(
                  alignment: _chaosAlignment,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0), // Safety margin
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
                            _randomizeChaosPosition(); // Move it for next time!
                          },
                        );
                      },
                    ),
                  ),
                ),

              // 9. Tutorial Overlay
              TutorialOverlay(
                key: ValueKey('tutorial_overlay_$_selectedTab'),
                currentTab: _selectedTab,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the current tab content
  Widget _buildCurrentTab(bool lowPerformanceMode) {
    switch (_selectedTab) {
      case 0:
        return const ChambersScreen();
      case 1:
        return _buildFactoryTab(lowPerformanceMode);
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
  Widget _buildFactoryTab(bool lowPerformanceMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactWidth = constraints.maxWidth < 400;
        final compactHeight = constraints.maxHeight < 600;
        final sidePadding = compactWidth ? 12.0 : 16.0;
        final topPadding = compactHeight ? 14.0 : 20.0;
        final monitorBottomOffset = compactHeight ? 124.0 : 152.0;
        final objectivesPanelWidth =
            (constraints.maxWidth * (compactWidth ? 0.58 : 0.44))
                .clamp(180.0, 240.0)
                .toDouble();

        return Stack(
          children: [
            if (!lowPerformanceMode)
              Positioned(
                top: topPadding,
                left: sidePadding,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TimeWarpIndicator(),
                    SizedBox(height: 6),
                    AutoClickIndicator(),
                  ],
                ),
              ),
            Positioned(
              top: topPadding,
              right: sidePadding,
              child: DailyObjectivePanel(expandedWidth: objectivesPanelWidth),
            ),
            if (!compactHeight)
              Positioned(
                bottom: monitorBottomOffset,
                right: sidePadding,
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
      },
    );
  }

  double _saveIndicatorTop(Size size) {
    if (_selectedTab == 0) return 8;
    if (size.width < 420) return 96;
    return 112;
  }

  bool _isLowPerformanceMode(
    PerformanceMode mode,
    Size size,
    double devicePixelRatio,
  ) {
    switch (mode) {
      case PerformanceMode.low:
        return true;
      case PerformanceMode.high:
        return false;
      case PerformanceMode.auto:
        return _isLowEndViewport(size, devicePixelRatio);
    }
  }

  bool _isLowEndViewport(Size size, double devicePixelRatio) {
    final shortestSide = size.shortestSide;
    if (shortestSide <= 390) return true;
    if (shortestSide <= 430 && devicePixelRatio <= 2.2) return true;
    return false;
  }
}
