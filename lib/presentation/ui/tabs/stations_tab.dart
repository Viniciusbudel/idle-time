import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/widgets/cyber_button.dart';
import 'package:time_factory/presentation/ui/widgets/glass_card.dart';

class StationsTab extends ConsumerWidget {
  const StationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final stations = gameState.stations.values.toList();
    // Sort stations? They usually are added in order.

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildHeader(stations.length),

        const SizedBox(height: 16),

        if (stations.isEmpty)
          _buildEmptyState(notifier)
        else
          ...stations.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StationCard(station: s),
            ),
          ),

        const SizedBox(height: 12),

        // Paradox Button
        if (gameState.paradoxLevel >= 0.5)
          CyberButton(
            label: 'EMBRACE CHAOS',
            icon: Icons.flash_on,
            primaryColor: TimeFactoryColors.hotMagenta,
            onTap: () => notifier.triggerParadoxEvent(),
          ),

        // Build New Station Button (Always visible at bottom?)
        if (stations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CyberButton(
              label: 'BUILD LOOP',
              subLabel: '500 CE', // Dynamic cost?
              icon: Icons.add,
              primaryColor: TimeFactoryColors.electricCyan,
              onTap: () => _buildStation(notifier),
            ),
          ),
      ],
    );
  }

  void _buildStation(GameStateNotifier notifier) {
    final cost = BigInt.from(500); // Should be dynamic
    if (notifier.spendChronoEnergy(cost)) {
      notifier.addStation(
        StationFactory.create(type: StationType.basicLoop, gridX: 0, gridY: 0),
      );
    }
  }

  Widget _buildHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRODUCTION LINES',
              style: TimeFactoryTextStyles.header.copyWith(fontSize: 20),
            ),
            Text(
              'ACTIVE LOOPS: $count',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: TimeFactoryColors.electricCyan,
              ),
            ),
          ],
        ),
        Icon(Icons.factory, color: TimeFactoryColors.electricCyan, size: 28),
      ],
    );
  }

  Widget _buildEmptyState(GameStateNotifier notifier) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.factory_outlined, size: 48, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'NO STATIONS ACTIVE',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CyberButton(
          label: 'BUILD FIRST LOOP',
          subLabel: '500 CE',
          icon: Icons.add,
          isLarge: true,
          onTap: () => _buildStation(notifier),
        ),
      ],
    );
  }
}

class _StationCard extends ConsumerWidget {
  final Station station;

  const _StationCard({required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final canAfford = gameState.chronoEnergy >= station.upgradeCost;
    final production = gameState.getStationProduction(station.id);

    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderGlow: false,
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TimeFactoryColors.surfaceDark,
              border: Border.all(
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.change_circle,
              color: TimeFactoryColors.electricCyan,
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      station.name.toUpperCase(),
                      style: TimeFactoryTextStyles.headerSmall.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: TimeFactoryColors.electricCyan.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LVL ${station.level}',
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          fontSize: 10,
                          color: TimeFactoryColors.electricCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '+${NumberFormatter.formatCE(production)}/s',
                  style: TimeFactoryTextStyles.numbersSmall.copyWith(
                    color: TimeFactoryColors.acidGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Upgrade Btn
          CyberButton(
            label: 'UPG',
            subLabel: NumberFormatter.formatCE(station.upgradeCost),
            icon: Icons.keyboard_arrow_up,
            primaryColor: canAfford
                ? TimeFactoryColors.electricCyan
                : Colors.grey,
            onTap: canAfford ? () => notifier.upgradeStation(station.id) : null,
          ),
        ],
      ),
    );
  }
}
