import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/presentation/ui/molecules/tech_card.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/l10n/app_localizations.dart';

import 'package:time_factory/core/constants/tech_data.dart';

/// Full Tech Screen - Neon Futuristic Themed
class TechScreen extends ConsumerWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimization: Only watch the specific list of techs, not the whole game state
    final techs = ref.watch(currentEraTechsProvider);
    const theme = NeonTheme();

    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, theme),

          const SizedBox(height: AppSpacing.md),

          // Tech List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xl, // Normal bottom padding
              ),
              // +1 for the Era Advancement Button
              itemCount: techs.length + 1,
              itemBuilder: (context, index) {
                // If it's the last item, show the Era Button
                if (index == techs.length) {
                  return const _EraAdvancementButton();
                }

                final tech = techs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SmartTechCard(tech: tech),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NeonTheme theme) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hex Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity( 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary.withOpacity( 0.5)),
            ),
            child: Icon(Icons.memory, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, colors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    AppLocalizations.of(context)!.techAugmentation,
                    style: typography.titleLarge.copyWith(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.systemUpgradesAvailable,
                  style: typography.bodyMedium.copyWith(
                    fontSize: 10.0,
                    color: colors.primary.withOpacity( 0.7),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),

          // Version Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.secondary.withOpacity( 0.5),
              ),
              borderRadius: BorderRadius.circular(4),
              color: colors.secondary.withOpacity( 0.1),
            ),
            child: Text(
              'SYS.pV2',
              style: typography.bodyMedium.copyWith(
                fontSize: 9.0,
                color: colors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartTechCard extends ConsumerWidget {
  final TechUpgrade tech;

  const _SmartTechCard({required this.tech});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get Discount Multiplier
    final techLevels = ref.watch(techLevelsProvider);
    final discount = TechData.calculateCostReductionMultiplier(techLevels);

    // 2. Calculate Discounted Cost
    final nextCost = tech.getCost(discountMultiplier: discount);
    final isMaxed = nextCost < BigInt.zero;

    // Only watch if we can afford THIS specific tech
    // This will toggle only when affordability changes for this specific item
    final canAfford = ref.watch(
      gameStateProvider.select((s) => !isMaxed && s.chronoEnergy >= nextCost),
    );

    return TechCard(
      title: tech.name,
      level: tech.level,
      description: tech.description,
      progress: tech.level / tech.maxLevel,
      cost: isMaxed ? 'MAX' : NumberFormatter.formatCE(nextCost),
      icon: _getTechIcon(tech.id),
      effectLabel: tech.type.localizedEffect(context),
      effectDescription: tech.bonusDescription,
      onUpgrade: (canAfford && !isMaxed)
          ? () => ref.read(techProvider.notifier).purchaseUpgrade(tech.id)
          : null,
    );
  }

  IconData _getTechIcon(String techId) {
    switch (techId) {
      // Victorian
      case 'steam_boilers':
        return Icons.water_drop;
      case 'mechanical_arms':
        return Icons.precision_manufacturing;
      case 'pneumatic_hammer':
        return Icons.gavel;
      case 'bessemer_process':
        return Icons.local_fire_department;
      case 'clockwork_mechanism':
        return Icons.watch_later;
      case 'difference_engine':
        return Icons.calculate;

      // Roaring 20s
      case 'radio_broadcast':
        return Icons.radio;
      case 'assembly_line':
        return Icons
            .conveyor_belt; // Material Icons doesn't have conveyor_belt, using similar
      case 'jazz_improvisation':
        return Icons.music_note;
      case 'ticker_tape':
        return Icons.receipt_long;
      case 'jacquard_punchcards':
        return Icons.qr_code; // Close enough
      case 'manhattan_project':
        return Icons.science;

      // Atomic Age
      case 'nuclear_fission':
        return Icons.blur_on;
      case 'transistors':
        return Icons.memory;
      case 'plastic_molding':
        return Icons.dashboard;
      case 'space_race':
        return Icons.rocket_launch;
      case 'arpanet':
        return Icons.lan;
      case 'microchip_revolution':
        return Icons.developer_board;

      default:
        return Icons.science;
    }
  }
}

class _EraAdvancementButton extends ConsumerWidget {
  const _EraAdvancementButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isComplete = ref.watch(isEraCompleteProvider);
    final nextEraId = ref.watch(nextEraIdProvider);

    // If no next era, hide the button completely (end of game)
    if (nextEraId == null) return const SizedBox.shrink();

    final cost = ref.watch(nextEraCostProvider);
    final canAfford = ref.watch(canAffordNextEraProvider);

    // If era is not complete, show LOCKED state
    if (!isComplete) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Container(
            width: double.infinity,
            height: 70,
            margin: const EdgeInsets.only(bottom: 85),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade900.withOpacity( 0.8),
                  Colors.grey.shade800.withOpacity( 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red.withOpacity( 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.red.withOpacity( 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.eraLocked,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.researchIncomplete,
                        style: TextStyle(
                          color: Colors.red.withOpacity( 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // UNLOCKED STATE
    return Column(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              width: double.infinity,
              height: 70,
              margin: const EdgeInsets.only(bottom: 85),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity( 0.2), // Gold
                    const Color(0xFF00FFFF).withOpacity( 0.2), // Cyan
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canAfford ? const Color(0xFFD4AF37) : Colors.grey,
                  width: 2,
                ),
                boxShadow: [
                  if (canAfford)
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity( 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canAfford
                      ? () {
                          HapticFeedback.heavyImpact();
                          ref
                              .read(gameStateProvider.notifier)
                              .advanceEra(nextEraId, cost);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.advanceTo(
                            nextEraId.toUpperCase().replaceAll('_', ' '),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.cost}: ${NumberFormatter.formatCE(cost)} CE',
                          style: TextStyle(
                            color: canAfford
                                ? const Color(0xFFD4AF37)
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
