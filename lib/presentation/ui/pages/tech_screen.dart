import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:time_factory/core/ui/app_icons.dart';

/// Tech screen aligned with Chambers neon visual language.
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
          _buildHeader(
            context,
            colors,
            typography,
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
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _NeonTechCard(tech: techs[index], theme: theme),
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
              'RESEARCH NODES',
              style: typography.bodyMedium.copyWith(
                fontSize: 11,
                color: colors.primary.withValues(alpha: 0.82),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
            ),
            child: Text(
              '$techCount',
              style: typography.bodyMedium.copyWith(
                fontSize: 11,
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeColors colors,
    ThemeTypography typography, {
    required String currentEraId,
    required int completedTechs,
    required int totalTechs,
    required double progress,
  }) {
    final l10n = AppLocalizations.of(context);
    final eraLabel = _formatEraLabel(currentEraId).toUpperCase();
    final progressPct = (progress * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: AppIcon(
                  AppHugeIcons.memory,
                  color: colors.primary,
                  size: 28,
                ),
              ),
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
                      l10n?.techAugmentation ?? 'AUGMENTATION',
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
                      borderRadius: BorderRadius.circular(4),
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
                          '$completedTechs/$totalTechs',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.primary.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: colors.primary,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$progressPct%',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 12,
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
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

class _NeonTechCard extends ConsumerWidget {
  final TechUpgrade tech;
  final NeonTheme theme;

  const _NeonTechCard({required this.tech, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final typography = theme.typography;
    final l10n = AppLocalizations.of(context);

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
    final accent = _techAccent(theme, tech.type);
    final costText = isMaxed ? 'MAX' : NumberFormatter.formatCE(nextCost);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050A10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(child: _PanelAmbientBackground(accent: accent)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: _TechIcon(
                            techId: tech.id,
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
                            Text(
                              _localizedEffect(context, tech.type),
                              style: typography.bodyMedium.copyWith(
                                fontSize: 10,
                                color: accent.withValues(alpha: 0.70),
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tech.name.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: typography.titleMedium.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.65),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LVL ${tech.level}',
                          style: typography.bodyMedium.copyWith(
                            fontSize: 11,
                            color: accent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tech.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography.bodySmall.copyWith(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      color: accent,
                      backgroundColor: Colors.white10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: accent.withValues(alpha: 0.20)),
                  const SizedBox(height: 8),
                  _NeonChip(
                    icon: AppHugeIcons.bolt,
                    label: tech.bonusDescription,
                    color: colors.primary.withValues(alpha: 0.95),
                    theme: theme,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _NeonChip(
                          icon: AppHugeIcons.toll,
                          label: '${l10n?.cost ?? 'COST'}: $costText',
                          color: isMaxed
                              ? colors.primary
                              : (canAfford ? colors.success : Colors.white54),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 110),
                        child: _buildUpgradeButton(
                          context,
                          ref,
                          accent,
                          canAfford: canAfford,
                          isMaxed: isMaxed,
                          label: isMaxed ? 'MAX' : (l10n?.upgrade ?? 'UPGRADE'),
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

  Widget _buildUpgradeButton(
    BuildContext context,
    WidgetRef ref,
    Color accent, {
    required bool canAfford,
    required bool isMaxed,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isMaxed
              ? accent.withValues(alpha: 0.45)
              : (canAfford ? accent.withValues(alpha: 0.70) : Colors.white24),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: (canAfford && !isMaxed)
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  isMaxed ? AppHugeIcons.check_circle : AppHugeIcons.upgrade,
                  size: 16,
                  color: (canAfford || isMaxed) ? accent : Colors.white38,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.typography.bodyMedium.copyWith(
                    fontSize: 11,
                    color: (canAfford || isMaxed) ? accent : Colors.white38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          AppIcon(icon, size: 14, color: color),
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

class _EraAdvancementPanel extends ConsumerWidget {
  const _EraAdvancementPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
    final advanceLabel =
        l10n?.advanceTo(nextEraLabel) ?? 'ADVANCE TO $nextEraLabel';

    final accent = isReady
        ? colors.primary
        : (isComplete ? Colors.white54 : colors.secondary);
    final helperLabel = !isComplete
        ? (l10n?.researchIncomplete ?? 'RESEARCH INCOMPLETE')
        : (canAfford
              ? (l10n?.systemUpgradesAvailable ?? 'SYSTEM UPGRADES AVAILABLE')
              : (l10n?.needCEToConstruct(costLabel) ??
                    'Need $costLabel CE to construct!'));

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF050A10),
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(child: _PanelAmbientBackground(accent: accent)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
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
                                borderRadius: BorderRadius.circular(999),
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
                                    l10n?.estimatedReward ?? 'ESTIMATED REWARD',
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
                      borderRadius: BorderRadius.circular(8),
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
                            '${l10n?.eraUnlocked ?? 'ERA UNLOCKED'} • $nextEraLabel',
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
                    label: '${l10n?.cost ?? 'COST'}: $costLabel CE',
                    color: canAfford ? colors.success : Colors.white60,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: _buildAdvanceButton(
                      isReady: isReady,
                      accent: accent,
                      label: isReady
                          ? advanceLabel
                          : (isComplete
                                ? (l10n?.insufficientCE ?? 'INSUFFICIENT CE')
                                : (l10n?.researchIncomplete ??
                                      'RESEARCH INCOMPLETE')),
                      onTap: () {
                        ref
                            .read(gameStateProvider.notifier)
                            .advanceEra(nextEraId, cost);
                      },
                      theme: theme,
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

  Widget _buildAdvanceButton({
    required bool isReady,
    required Color accent,
    required String label,
    required VoidCallback onTap,
    required NeonTheme theme,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isReady ? accent.withValues(alpha: 0.75) : Colors.white24,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: isReady
              ? () {
                  HapticFeedback.heavyImpact();
                  onTap();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  isReady
                      ? AppHugeIcons.rocket_launch
                      : AppHugeIcons.lock_outline,
                  size: 16,
                  color: isReady ? accent : Colors.white38,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.typography.buttonText.copyWith(
                      color: isReady ? accent : Colors.white38,
                      fontSize: 12,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatEraLabel(String eraId) {
  final parts = eraId.split('_');
  return parts
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _localizedEffect(BuildContext context, TechType type) {
  final l10n = AppLocalizations.of(context);
  switch (type) {
    case TechType.automation:
      return l10n?.automationEffect ?? 'AUTOMATION';
    case TechType.efficiency:
      return l10n?.efficiencyEffect ?? 'EFFICIENCY';
    case TechType.timeWarp:
      return l10n?.timeWarpEffect ?? 'TIME WARP';
    case TechType.costReduction:
      return l10n?.costReductionEffect ?? 'UPGRADE DISCOUNT';
    case TechType.offline:
      return l10n?.offlineEffect ?? 'OFFLINE';
    case TechType.clickPower:
      return l10n?.clickPowerEffect ?? 'CLICK POWER';
    case TechType.eraUnlock:
      return l10n?.eraUnlockEffect ?? 'ERA UNLOCK';
    case TechType.manhattan:
      return l10n?.manhattanEffect ?? 'MANHATTAN';
  }
}

Color _techAccent(NeonTheme theme, TechType type) {
  return theme.colors.primary;
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
    default:
      return AppHugeIcons.science;
  }
}
