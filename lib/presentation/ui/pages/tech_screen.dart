import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';
import 'package:time_factory/presentation/ui/atoms/hud_segmented_progress_bar.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Tech screen — Temporal System Upgrade Console.
class TechScreen extends ConsumerWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = const NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final techs = ref.watch(currentEraTechsProvider);
    final currentEraId = ref.watch(
      gameStateProvider.select((s) => s.currentEraId),
    );

    final totalLevels = techs.fold<int>(0, (sum, tech) => sum + tech.level);
    final maxLevels = techs.fold<int>(0, (sum, tech) => sum + tech.maxLevel);
    final completedTechs = techs
        .where((tech) => tech.level >= tech.maxLevel)
        .length;
    final progress = maxLevels == 0
        ? 1.0
        : (totalLevels / maxLevels).clamp(0.0, 1.0);

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TechHudHeader(
            colors: colors,
            typography: typography,
            currentEraId: currentEraId,
            completedTechs: completedTechs,
            totalTechs: techs.length,
            progress: progress,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildListHeader(colors, typography, techCount: techs.length),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: techs.length + 1,
                itemBuilder: (context, index) {
                  if (index == techs.length) {
                    return const _EraAdvancementPanel();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _TechModuleCard(
                      tech: techs[index],
                      theme: theme,
                      moduleIndex: index,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(
    ThemeColors colors,
    ThemeTypography typography, {
    required int techCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          AppIcon(
            AppHugeIcons.grid_view,
            size: 14,
            color: colors.primary.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'SYSTEM MODULES',
              style: typography.bodyMedium.copyWith(
                fontSize: 11,
                color: colors.primary.withValues(alpha: 0.82),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
            ),
            child: Text(
              '$techCount ACTIVE',
              style: typography.bodyMedium.copyWith(
                fontSize: 10,
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TechHudHeader — HUD-style header with system info + segmented progress
// ---------------------------------------------------------------------------
class _TechHudHeader extends StatefulWidget {
  final ThemeColors colors;
  final ThemeTypography typography;
  final String currentEraId;
  final int completedTechs;
  final int totalTechs;
  final double progress;

  const _TechHudHeader({
    required this.colors,
    required this.typography,
    required this.currentEraId,
    required this.completedTechs,
    required this.totalTechs,
    required this.progress,
  });

  @override
  State<_TechHudHeader> createState() => _TechHudHeaderState();
}

class _TechHudHeaderState extends State<_TechHudHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.018).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.colors;
    final typography = widget.typography;
    final eraLabel = _formatEraLabel(widget.currentEraId).toUpperCase();
    final progressPct = (widget.progress * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Header icon with glow breathing
              _GlowBreathingIcon(color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TECH',
                      style: typography.titleLarge.copyWith(
                        height: 1.0,
                        fontSize: 22,
                        color: colors.primary,
                        letterSpacing: 1.8,
                        shadows: [
                          Shadow(
                            color: colors.primary.withValues(alpha: 0.70),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.techAugmentation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.titleLarge.copyWith(
                        height: 1.0,
                        fontSize: 18,
                        color: colors.primary,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: colors.primary.withValues(alpha: 0.70),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      eraLabel,
                      style: typography.bodyMedium.copyWith(
                        fontSize: 10,
                        color: colors.primary.withValues(alpha: 0.60),
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.50),
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppHugeIcons.science,
                          color: colors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.completedTechs}/${widget.totalTechs}',
                          style: typography.bodyMedium.copyWith(
                            fontSize: 12,
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SYS.TC1',
                    style: typography.bodyMedium.copyWith(
                      fontSize: 10,
                      color: colors.primary.withValues(alpha: 0.60),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // HUD segmented progress bar replaces LinearProgressIndicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: HudSegmentedProgressBar(
                    value: widget.progress,
                    color: colors.primary,
                    height: 7,
                    segmentCount: 12,
                    segmentGap: 2,
                  ),
                ),
                const SizedBox(width: 10),
                // Pulsing percentage label
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Text(
                    '$progressPct%',
                    style: typography.bodyMedium.copyWith(
                      fontSize: 13,
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          color: colors.primary.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glow Breathing Icon — Subtly pulsing header icon
// ---------------------------------------------------------------------------
class _GlowBreathingIcon extends StatefulWidget {
  final Color color;
  const _GlowBreathingIcon({required this.color});

  @override
  State<_GlowBreathingIcon> createState() => _GlowBreathingIconState();
}

class _GlowBreathingIconState extends State<_GlowBreathingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.50,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(
                  alpha: 0.3 * _glowAnimation.value,
                ),
                blurRadius: 12 * _glowAnimation.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: AppIcon(
            AppHugeIcons.memory,
            color: widget.color.withValues(
              alpha: 0.7 + (0.3 * _glowAnimation.value),
            ),
            size: 28,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// TechModuleCard — Module-style upgrade card with system ID, HUD progress
// ---------------------------------------------------------------------------
class _TechModuleCard extends ConsumerWidget {
  final TechUpgrade tech;
  final NeonTheme theme;
  final int moduleIndex;

  const _TechModuleCard({
    required this.tech,
    required this.theme,
    required this.moduleIndex,
  });

  String _moduleId(TechType type, int index) {
    switch (type) {
      case TechType.automation:
        return 'AUT-${(index + 1).toString().padLeft(2, '0')}';
      case TechType.efficiency:
        return 'EFF-${(index + 1).toString().padLeft(2, '0')}';
      case TechType.timeWarp:
        return 'TWP-${(index + 1).toString().padLeft(2, '0')}';
      case TechType.costReduction:
        return 'CRD-${(index + 1).toString().padLeft(2, '0')}';
      case TechType.offline:
        return 'OFL-${(index + 1).toString().padLeft(2, '0')}';
      case TechType.clickPower:
        return 'CLK-${(index + 1).toString().padLeft(2, '0')}';
      case TechType.eraUnlock:
        return 'ERA-${(index + 1).toString().padLeft(2, '0')}';
      case TechType.manhattan:
        return 'MHT-${(index + 1).toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final typography = theme.typography;
    final l10n = AppLocalizations.of(context)!;

    final techLevels = ref.watch(techLevelsProvider);
    final discountMultiplier = TechData.calculateCostReductionMultiplier(
      techLevels,
    );
    final nextCost = tech.getCost(discountMultiplier: discountMultiplier);
    final isMaxed = nextCost < BigInt.zero;
    final canAfford = ref.watch(
      gameStateProvider.select((s) => !isMaxed && s.chronoEnergy >= nextCost),
    );

    final progress = tech.maxLevel == 0
        ? 1.0
        : (tech.level / tech.maxLevel).clamp(0.0, 1.0);
    final accent = colors.primary;
    final costText = isMaxed ? l10n.max : NumberFormatter.formatCE(nextCost);

    // Module state
    final _ModuleState moduleState = isMaxed
        ? _ModuleState.maxed
        : (canAfford ? _ModuleState.upgradable : _ModuleState.locked);

    final moduleBorderColor = switch (moduleState) {
      _ModuleState.upgradable => accent.withValues(alpha: 0.50),
      _ModuleState.maxed => colors.success.withValues(alpha: 0.40),
      _ModuleState.locked => Colors.white.withValues(alpha: 0.15),
    };

    final moduleGlowColor = switch (moduleState) {
      _ModuleState.upgradable => accent.withValues(alpha: 0.16),
      _ModuleState.maxed => colors.success.withValues(alpha: 0.10),
      _ModuleState.locked => Colors.transparent,
    };

    final stateLabel = switch (moduleState) {
      _ModuleState.upgradable => 'READY',
      _ModuleState.maxed => 'MAXED',
      _ModuleState.locked => 'LOCKED',
    };

    final stateLabelColor = switch (moduleState) {
      _ModuleState.upgradable => accent,
      _ModuleState.maxed => colors.success,
      _ModuleState.locked => Colors.white54,
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050A10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: moduleBorderColor),
        boxShadow: [
          BoxShadow(color: moduleGlowColor, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Positioned.fill(child: _PanelAmbientBackground(accent: accent)),
            // Grid overlay for depth
            Positioned.fill(child: _GridOverlay(color: accent)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Module Header Row ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tech icon box
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.60),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _TechIcon(
                            techId: tech.id,
                            color: stateLabelColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Module ID + Category row
                            Row(
                              children: [
                                Text(
                                  _moduleId(tech.type, moduleIndex),
                                  style: typography.bodyMedium.copyWith(
                                    fontSize: 9,
                                    color: accent.withValues(alpha: 0.55),
                                    letterSpacing: 1.6,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.40),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _localizedEffect(context, tech.type),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: typography.bodyMedium.copyWith(
                                      fontSize: 9,
                                      color: accent.withValues(alpha: 0.60),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Module Name (primary focus)
                            Text(
                              tech.name.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.titleMedium.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Level + State badges
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(
                                color: accent.withValues(alpha: 0.55),
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'LVL ${tech.level}',
                              style: typography.bodyMedium.copyWith(
                                fontSize: 10,
                                color: accent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stateLabel,
                            style: typography.bodyMedium.copyWith(
                              fontSize: 8,
                              color: stateLabelColor.withValues(alpha: 0.80),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // --- Description (one line) ---
                  Text(
                    tech.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.bodySmall.copyWith(
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // --- HUD Segmented Progress Bar ---
                  HudSegmentedProgressBar(
                    value: progress,
                    color: stateLabelColor,
                    height: 5,
                    segmentCount: tech.maxLevel.clamp(1, 20),
                    segmentGap: 2,
                    label: '${(progress * 100).toStringAsFixed(0)}%',
                    labelStyle: typography.bodyMedium.copyWith(
                      fontSize: 10,
                      color: stateLabelColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // --- Separator ---
                  Container(height: 1, color: accent.withValues(alpha: 0.15)),
                  const SizedBox(height: 8),
                  // --- Effect Chip ---
                  _NeonChip(
                    icon: AppHugeIcons.bolt,
                    label: tech.bonusDescription,
                    color: colors.primary.withValues(alpha: 0.95),
                    theme: theme,
                  ),
                  const SizedBox(height: 6),
                  // --- Cost + Action Button Row ---
                  Row(
                    children: [
                      Expanded(
                        child: _NeonChip(
                          icon: AppHugeIcons.toll,
                          label: l10n.techCost(costText),
                          color: isMaxed
                              ? colors.primary
                              : (canAfford ? colors.success : Colors.white54),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 110),
                        child: GameActionButton(
                          label: isMaxed ? l10n.max : l10n.upgrade,
                          icon: isMaxed
                              ? AppHugeIcons.check_circle
                              : AppHugeIcons.upgrade,
                          color: accent,
                          enabled: canAfford,
                          isMaxed: isMaxed,
                          onTap: () => ref
                              .read(techProvider.notifier)
                              .purchaseUpgrade(tech.id),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ModuleState { upgradable, maxed, locked }

// ---------------------------------------------------------------------------
// GridOverlay — Subtle grid lines for depth
// ---------------------------------------------------------------------------
class _GridOverlay extends StatelessWidget {
  final Color color;
  const _GridOverlay({required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridPainter(color: color.withValues(alpha: 0.04)),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 16.0;
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// NeonChip — Info chip with icon + label
// ---------------------------------------------------------------------------
class _NeonChip extends StatelessWidget {
  final AppIconData icon;
  final String label;
  final Color color;
  final NeonTheme theme;

  const _NeonChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.bodyMedium.copyWith(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EraAdvancementPanel
// ---------------------------------------------------------------------------
class _EraAdvancementPanel extends ConsumerWidget {
  const _EraAdvancementPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = const NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final isComplete = ref.watch(isEraCompleteProvider);
    final nextEraId = ref.watch(nextEraIdProvider);
    if (nextEraId == null) return const SizedBox.shrink();

    final cost = ref.watch(nextEraCostProvider);
    final canAfford = ref.watch(canAffordNextEraProvider);
    final isReady = isComplete && canAfford;
    final nextEraLabel = _formatEraLabel(nextEraId).toUpperCase();
    final costLabel = NumberFormatter.formatCE(cost);
    final advanceLabel = l10n.advanceTo(nextEraLabel);

    final accent = isReady
        ? colors.primary
        : (isComplete ? Colors.white54 : colors.secondary);
    final helperLabel = !isComplete
        ? l10n.researchIncomplete
        : (canAfford
              ? l10n.systemUpgradesAvailable
              : l10n.needCEToConstruct(costLabel));

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF050A10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Positioned.fill(child: _PanelAmbientBackground(accent: accent)),
            Positioned.fill(child: _GridOverlay(color: accent)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: AppIcon(
                            isReady
                                ? AppHugeIcons.emoji_events
                                : (isComplete
                                      ? AppHugeIcons.hourglass_bottom
                                      : AppHugeIcons.lock_outline),
                            color: accent,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.45),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcon(
                                    AppHugeIcons.stars,
                                    size: 12,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    l10n.estimatedReward,
                                    style: typography.bodyMedium.copyWith(
                                      fontSize: 9,
                                      color: accent,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              advanceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.titleMedium.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              helperLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.bodyMedium.copyWith(
                                fontSize: 10,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: accent.withValues(alpha: 0.50)),
                    ),
                    child: Row(
                      children: [
                        AppIcon(
                          AppHugeIcons.diamond_outlined,
                          size: 16,
                          color: accent,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            '${l10n.eraUnlocked} • $nextEraLabel',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.bodyMedium.copyWith(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _NeonChip(
                    icon: AppHugeIcons.toll,
                    label: l10n.techCostCe(costLabel),
                    color: canAfford ? colors.success : Colors.white60,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: GameActionButton(
                      label: isReady
                          ? advanceLabel
                          : (isComplete
                                ? l10n.insufficientCE
                                : l10n.researchIncomplete),
                      icon: isReady
                          ? AppHugeIcons.rocket_launch
                          : AppHugeIcons.lock_outline,
                      color: accent,
                      enabled: isReady,
                      height: 46,
                      onTap: () {
                        ref
                            .read(gameStateProvider.notifier)
                            .advanceEra(nextEraId, cost);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelAmbientBackground extends StatelessWidget {
  final Color accent;

  const _PanelAmbientBackground({required this.accent});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.92),
                    Colors.black.withValues(alpha: 0.80),
                    Colors.black.withValues(alpha: 0.64),
                  ],
                  stops: const [0.0, 0.58, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -48,
            right: -34,
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.14),
                    blurRadius: 56,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -28,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.08),
                    blurRadius: 44,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utility functions
// ---------------------------------------------------------------------------
String _formatEraLabel(String eraId) {
  if (eraId == 'victorian') {
    return 'Steampunk Era';
  }

  final parts = eraId.split('_');
  return parts
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _localizedEffect(BuildContext context, TechType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case TechType.automation:
      return l10n.automationEffect;
    case TechType.efficiency:
      return l10n.efficiencyEffect;
    case TechType.timeWarp:
      return l10n.timeWarpEffect;
    case TechType.costReduction:
      return l10n.costReductionEffect;
    case TechType.offline:
      return l10n.offlineEffect;
    case TechType.clickPower:
      return l10n.clickPowerEffect;
    case TechType.eraUnlock:
      return l10n.eraUnlockEffect;
    case TechType.manhattan:
      return l10n.manhattanEffect;
  }
}

class _TechIcon extends StatelessWidget {
  final String techId;
  final Color color;
  final double size;

  const _TechIcon({
    required this.techId,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AppIcon(_techIconData(techId), color: color, size: size);
  }
}

AppIconData _techIconData(String techId) {
  switch (techId) {
    case 'steam_boilers':
      return AppHugeIcons.factory;
    case 'centrifugal_governor':
      return AppHugeIcons.engineering;
    case 'bessemer_process':
      return AppHugeIcons.precision_manufacturing;
    case 'jacquard_punchcards':
      return AppHugeIcons.memory;
    case 'clockwork_arithmometer':
      return AppHugeIcons.schedule;
    case 'pneumatic_hammer':
      return AppHugeIcons.precision_manufacturing;
    case 'ticker_tape':
      return AppHugeIcons.trending_up;
    case 'assembly_line':
      return AppHugeIcons.factory_outlined;
    case 'radio_broadcast':
      return AppHugeIcons.hub;
    case 'jazz_improvisation':
      return AppHugeIcons.music_note;
    case 'manhattan_project':
      return AppHugeIcons.science;
    case 'nuclear_fission':
      return AppHugeIcons.warning_amber;
    case 'transistors':
      return AppHugeIcons.memory;
    case 'plastic_molding':
      return AppHugeIcons.precision_manufacturing;
    case 'space_race':
      return AppHugeIcons.rocket_launch;
    case 'arpanet':
      return AppHugeIcons.public;
    case 'microchip_revolution':
      return AppHugeIcons.settings_input_component;
    case 'cybernetics':
      return AppHugeIcons.precision_manufacturing;
    case 'neural_net':
      return AppHugeIcons.psychology;
    case 'synth_alloys':
      return AppHugeIcons.science;
    case 'neon_overdrive':
      return AppHugeIcons.flash_on;
    case 'virtual_reality':
      return AppHugeIcons.remove_red_eye;
    case 'neural_mesh':
      return AppHugeIcons.psychology;
    case 'probability_compiler':
      return AppHugeIcons.schedule;
    case 'nanoforge_cells':
      return AppHugeIcons.precision_manufacturing;
    case 'swarm_autonomy':
      return AppHugeIcons.hub;
    case 'quantum_hibernation':
      return AppHugeIcons.schedule;
    case 'exo_mind_uplink':
      return AppHugeIcons.psychology;
    default:
      return AppHugeIcons.science;
  }
}
