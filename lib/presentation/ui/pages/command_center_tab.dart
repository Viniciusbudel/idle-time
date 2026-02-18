import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/atoms/cyber_button.dart';
import 'package:time_factory/presentation/ui/molecules/holo_worker_card.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/utils/number_formatter.dart';

class CommandCenterTab extends ConsumerWidget {
  const CommandCenterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersMap = ref.watch(workersProvider);
    final workers = workersMap.values.toList();
    workers.sort((a, b) {
      int rarityComp = b.rarity.index.compareTo(a.rarity.index);
      if (rarityComp != 0) return rarityComp;
      return b.level.compareTo(a.level);
    });

    final gameState = ref.watch(gameStateProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildHeader(context, workers.length),
        const SizedBox(height: 16),

        if (workers.isEmpty)
          _buildEmptyState(context)
        else
          ...workers.map(
            (worker) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HoloWorkerCard(
                unitId: 'UNIT-${worker.id.substring(0, 4).toUpperCase()}',
                role: worker.displayName,
                efficiency: _calculateEfficiency(worker),
                status: _getWorkerStatus(worker),
                rarity: worker.rarity,
                onUpgrade: () {
                  final success = ref
                      .read(gameStateProvider.notifier)
                      .upgradeWorker(worker.id);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)!.insufficientCE} (${NumberFormatter.formatCE(worker.upgradeCost)} CE)',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red[900],
                      ),
                    );
                  }
                },
              ),
            ),
          ),

        const SizedBox(height: 24),

        Center(
          child: CyberButton(
            label: AppLocalizations.of(context)!.hireNewUnit,
            subLabel: '50 ${AppLocalizations.of(context)!.shards}',
            icon: Icons.person_add,
            isLarge: true,
            primaryColor: TimeFactoryColors.deepPurple,
            onTap: () {
              final notifier = ref.read(gameStateProvider.notifier);
              if (notifier.spendTimeShards(50)) {
                final worker = WorkerFactory.createRandom(
                  unlockedEras: gameState.unlockedEraEnums,
                );
                notifier.addWorker(worker);
              }
            },
          ),
        ),
      ],
    );
  }

  double _calculateEfficiency(Worker worker) {
    final baseEff = worker.rarity.productionMultiplier;
    final levelBonus = (worker.level - 1) * 0.05;
    return (baseEff + levelBonus).clamp(0.0, 1.0);
  }

  String _getWorkerStatus(Worker worker) {
    if (worker.isDeployed) return 'DEPLOYED';
    return 'IDLE';
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.commandCenter,
              style: TimeFactoryTextStyles.header.copyWith(fontSize: 20),
            ),
            Text(
              '${AppLocalizations.of(context)!.activeUnits}: $count',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: TimeFactoryColors.electricCyan,
              ),
            ),
          ],
        ),
        const Icon(Icons.hub, color: TimeFactoryColors.electricCyan, size: 28),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_off, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noUnitsDetected,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
