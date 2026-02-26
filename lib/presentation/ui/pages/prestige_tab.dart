import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/game_constants.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/prestige_upgrade.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/paradox_confirmation_dialog.dart';

class PrestigeTab extends ConsumerWidget {
  const PrestigeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final theme = const NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final requiredCe = BigInt.from(GameConstants.prestigeMinimumCE);
    final currentCe = gameState.lifetimeChronoEnergy;
    final progress = currentCe >= requiredCe
        ? 1.0
        : (currentCe.toDouble() / requiredCe.toDouble()).clamp(0.0, 1.0);

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            l10n: l10n,
            colors: colors,
            typography: typography,
            gameState: gameState,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 130),
                children: [
                  _buildCollapsePanel(
                    context,
                    l10n: l10n,
                    colors: colors,
                    typography: typography,
                    notifier: notifier,
                    gameState: gameState,
                    requiredCe: requiredCe,
                    currentCe: currentCe,
                    progress: progress,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildShopHeader(colors: colors, typography: typography),
                  const SizedBox(height: AppSpacing.sm),
                  ...PrestigeUpgradeType.shopCatalog.map((type) {
                    final level = gameState.paradoxPointsSpent[type.id] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _UpgradeCard(
                        type: type,
                        title: _getUpgradeName(context, type),
                        description: _getUpgradeDescription(
                          context,
                          type,
                          gameState,
                        ),
                        level: level,
                        availablePoints: gameState.availableParadoxPoints,
                        onBuy: () {
                          HapticFeedback.selectionClick();
                          notifier.buyPrestigeUpgrade(type);
                        },
                        theme: theme,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required ThemeTypography typography,
    required GameState gameState,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: _NeonPanel(
        accent: colors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppIcon(AppHugeIcons.military_tech, size: 22),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.prestige,
                    style: typography.titleLarge.copyWith(
                      color: colors.secondary,
                      fontSize: 22,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _InlineBadge(
                  icon: AppHugeIcons.stars,
                  label:
                      '${gameState.availableParadoxPoints} ${l10n.paradoxPointsAbbrev}',
                  color: colors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.prestigeDescription,
              style: typography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.76),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Equipped artifacts are preserved on surviving workers and returned to inventory if workers reset.',
              style: typography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.62),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            _InlineBadge(
              icon: AppHugeIcons.repeat,
              label: l10n.prestigesCount(gameState.totalPrestiges),
              color: colors.primary,
            ),
            const SizedBox(height: 8),
            _InlineBadge(
              icon: AppHugeIcons.bolt,
              label:
                  'Click +${gameState.paradoxClickBonusPercent}% from Paradox',
              color: colors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsePanel(
    BuildContext context, {
    required AppLocalizations l10n,
    required ThemeColors colors,
    required ThemeTypography typography,
    required GameStateNotifier notifier,
    required GameState gameState,
    required BigInt requiredCe,
    required BigInt currentCe,
    required double progress,
  }) {
    final canPrestige = gameState.canPrestige;
    final accent = canPrestige ? colors.success : colors.secondary;

    return _NeonPanel(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                AppHugeIcons.warning_amber_rounded,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.timelineCollapse,
                  style: typography.titleMedium.copyWith(
                    color: accent,
                    fontSize: 15,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              _InlineBadge(
                icon: AppHugeIcons.auto_awesome,
                label:
                    '+${gameState.prestigePointsToGain} ${l10n.paradoxPointsAbbrev}',
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: accent,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${NumberFormatter.formatCE(currentCe)} / ${NumberFormatter.formatCE(requiredCe)} CE',
            style: typography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              enabled: canPrestige,
              label: l10n.initiateCollapse,
              child: FilledButton(
                onPressed: canPrestige
                    ? () {
                        HapticFeedback.heavyImpact();
                        ParadoxConfirmationDialog.show(
                          context,
                          onConfirm: () => notifier.prestige(),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: canPrestige
                      ? colors.secondary
                      : Colors.white.withValues(alpha: 0.15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppIcon(
                      AppHugeIcons.dangerous,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.initiateCollapse,
                      style: typography.buttonText.copyWith(letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopHeader({
    required ThemeColors colors,
    required ThemeTypography typography,
  }) {
    return Row(
      children: [
        AppIcon(
          AppHugeIcons.shopping_bag_outlined,
          color: colors.primary,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'PARADOX SHOP',
          style: typography.titleMedium.copyWith(
            color: colors.primary,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  String _getUpgradeName(BuildContext context, PrestigeUpgradeType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case PrestigeUpgradeType.chronoMastery:
        return l10n.chronoMasteryName;
      case PrestigeUpgradeType.eraInsight:
        return l10n.eraInsightName;
      case PrestigeUpgradeType.riftStability:
        return l10n.riftStabilityName;
      case PrestigeUpgradeType.timekeepersFavor:
        return l10n.timekeepersFavorName;
      case PrestigeUpgradeType.temporalMemory:
        return l10n.offlineBonusName;
    }
  }

  String _getUpgradeDescription(
    BuildContext context,
    PrestigeUpgradeType type,
    GameState gameState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case PrestigeUpgradeType.chronoMastery:
        return l10n.chronoMasteryDescription;
      case PrestigeUpgradeType.eraInsight:
        return l10n.eraInsightDescription;
      case PrestigeUpgradeType.riftStability:
        return l10n.riftStabilityDescription;
      case PrestigeUpgradeType.timekeepersFavor:
        final safe = (gameState.expeditionLuckDeltaForRisk(ExpeditionRisk.safe) *
                100)
            .toStringAsFixed(1);
        final risky =
            (gameState.expeditionLuckDeltaForRisk(ExpeditionRisk.risky) * 100)
                .toStringAsFixed(1);
        final volatile = (gameState
                    .expeditionLuckDeltaForRisk(ExpeditionRisk.volatile) *
                100)
            .toStringAsFixed(1);
        return 'Expedition success boost: Safe +$safe%, Risky +$risky%, Volatile +$volatile%';
      case PrestigeUpgradeType.temporalMemory:
        return l10n.offlineBonusDescription;
    }
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({
    required this.type,
    required this.title,
    required this.description,
    required this.level,
    required this.availablePoints,
    required this.onBuy,
    required this.theme,
  });

  final PrestigeUpgradeType type;
  final String title;
  final String description;
  final int level;
  final int availablePoints;
  final VoidCallback onBuy;
  final NeonTheme theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final typography = theme.typography;
    final l10n = AppLocalizations.of(context)!;

    final maxLevel = type.maxLevel;
    final isMaxed = maxLevel != null && level >= maxLevel;
    final cost = isMaxed ? 0 : type.getCost(level);
    final canAfford = !isMaxed && availablePoints >= cost;
    final previewLevel = isMaxed ? level : (level + 1);
    final previewPrefix = isMaxed ? 'CURRENT' : 'NEXT';

    final accent = isMaxed
        ? colors.success
        : (canAfford ? colors.primary : Colors.white54);

    return _NeonPanel(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: AppIcon(type.icon, color: accent, size: 22),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isMaxed ? l10n.max : '${l10n.lvl} $level',
                style: typography.bodySmall.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$previewPrefix: ${type.getEffectDescription(previewLevel)}',
            style: typography.bodySmall.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                isMaxed
                    ? '${l10n.cost}: ${l10n.max}'
                    : '${l10n.cost}: $cost ${l10n.paradoxPointsAbbrev}',
                style: typography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 42,
                child: Semantics(
                  button: true,
                  enabled: canAfford && !isMaxed,
                  label: isMaxed
                      ? l10n.upgradeMaxed(title)
                      : l10n.upgradeCostsPp(title, cost),
                  child: FilledButton.tonal(
                    onPressed: canAfford ? onBuy : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent.withValues(alpha: 0.15),
                      foregroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          isMaxed
                              ? AppHugeIcons.check_circle
                              : AppHugeIcons.upgrade,
                          color: accent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isMaxed
                              ? l10n.max
                              : (canAfford ? l10n.upgrade : l10n.locked),
                          style: typography.bodySmall.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NeonPanel extends StatelessWidget {
  const _NeonPanel({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050A10),
        borderRadius: radius,
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(color: accent.withValues(alpha: 0.08)),
              ),
            ),
            Padding(padding: const EdgeInsets.all(AppSpacing.sm), child: child),
          ],
        ),
      ),
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final AppIconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const grid = 24.0;
    for (double x = 0; x < size.width; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}
