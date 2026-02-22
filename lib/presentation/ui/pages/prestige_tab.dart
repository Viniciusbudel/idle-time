import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/prestige_upgrade.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/atoms/cyber_button.dart';
import 'package:time_factory/presentation/ui/dialogs/paradox_confirmation_dialog.dart';
import 'package:time_factory/presentation/ui/molecules/glass_card.dart';
import 'package:time_factory/l10n/app_localizations.dart';

class PrestigeTab extends ConsumerWidget {
  const PrestigeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      children: [
        _buildHeader(context, gameState.availableParadoxPoints),
        const SizedBox(height: 24),

        // Collapse Section
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderGlow: true,
          borderColor: TimeFactoryColors.hotMagenta,
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.timelineCollapse,
                style: TimeFactoryTextStyles.header.copyWith(
                  color: TimeFactoryColors.hotMagenta,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: TimeFactoryColors.hotMagenta.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'REWARD: ',
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '+${gameState.prestigePointsToGain} PP',
                      style: TimeFactoryTextStyles.numbers.copyWith(
                        color: TimeFactoryColors.hotMagenta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CyberButton(
                label: gameState.canPrestige
                    ? AppLocalizations.of(context)!.initiateCollapse
                    : 'Not Enough CE',
                icon: Icons.dangerous,
                isLarge: false,
                primaryColor: gameState.canPrestige
                    ? TimeFactoryColors.hotMagenta
                    : Colors.grey,
                onTap: gameState.canPrestige
                    ? () {
                        ParadoxConfirmationDialog.show(
                          context,
                          onConfirm: () => notifier.prestige(),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Upgrade Shop Header
        Row(
          children: [
            const Icon(
              Icons.shopping_cart,
              color: TimeFactoryColors.electricCyan,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'PARADOX SHOP',
              style: TimeFactoryTextStyles.header.copyWith(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Upgrade Grid
        ...PrestigeUpgradeType.values.map((upgrade) {
          final level = gameState.paradoxPointsSpent[upgrade.id] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUpgradeCard(
              context,
              notifier,
              upgrade,
              level,
              gameState.availableParadoxPoints,
            ),
          );
        }),
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
        return l10n.timekeepersFavorDescription;
      case PrestigeUpgradeType.temporalMemory:
        return l10n.offlineBonusDescription;
    }
  }

  Widget _buildHeader(BuildContext context, int points) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.prestige,
              style: TimeFactoryTextStyles.header.copyWith(fontSize: 20),
            ),
            Text(
              'Legacy Level: 1',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TimeFactoryColors.hotMagenta.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TimeFactoryColors.hotMagenta),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.military_tech,
                color: TimeFactoryColors.hotMagenta,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '$points PP',
                style: TimeFactoryTextStyles.headerSmall.copyWith(
                  color: TimeFactoryColors.hotMagenta,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context,
    GameStateNotifier notifier,
    PrestigeUpgradeType upgrade,
    int level,
    int availablePoints,
  ) {
    final isMaxed = upgrade.maxLevel != null && level >= upgrade.maxLevel!;
    final cost = upgrade.getCost(level);
    final canAfford = !isMaxed && availablePoints >= cost;

    return GlassCard(
      height: 100,
      padding: const EdgeInsets.all(12),
      borderColor: isMaxed
          ? TimeFactoryColors.electricCyan
          : (canAfford ? TimeFactoryColors.acidGreen : Colors.white10),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isMaxed
                    ? TimeFactoryColors.electricCyan
                    : Colors.white10,
              ),
            ),
            child: Icon(
              upgrade.icon,
              color: isMaxed ? TimeFactoryColors.electricCyan : Colors.white70,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getUpgradeName(context, upgrade),
                  style: TimeFactoryTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getUpgradeDescription(context, upgrade),
                  style: TimeFactoryTextStyles.bodySmall.copyWith(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current: ${upgrade.getEffectDescription(level)}',
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: TimeFactoryColors.electricCyan,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Buy Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isMaxed ? 'MAX' : 'Lvl $level',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  color: isMaxed
                      ? TimeFactoryColors.electricCyan
                      : Colors.white38,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              isMaxed
                  ? const Icon(
                      Icons.check_circle,
                      color: TimeFactoryColors.electricCyan,
                    )
                  : SizedBox(
                      width: 80,
                      child: CyberButton(
                        label: '$cost PP',
                        onTap: canAfford
                            ? () => notifier.buyPrestigeUpgrade(upgrade)
                            : null,
                        primaryColor: canAfford
                            ? TimeFactoryColors.acidGreen
                            : Colors.grey,
                        isLarge: false,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
