import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/widgets/cyber_button.dart';
import 'package:time_factory/presentation/ui/widgets/holo_worker_card.dart';

class CommandCenterTab extends ConsumerWidget {
  const CommandCenterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersMap = ref.watch(workersProvider);
    final workers = workersMap.values.toList();
    // Sort by rarity/level
    workers.sort((a, b) {
      int rarityComp = b.rarity.index.compareTo(a.rarity.index);
      if (rarityComp != 0) return rarityComp;
      return b.level.compareTo(a.level);
    });

    final gameState = ref.watch(gameStateProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ), // Bottom padding for dock
      children: [
        // Header
        _buildHeader(context, workers.length),

        const SizedBox(height: 16),

        // Worker List
        if (workers.isEmpty)
          _buildEmptyState()
        else
          ...workers.map(
            (worker) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HoloWorkerCard(
                unitId: 'UNIT-${worker.id.substring(0, 4).toUpperCase()}',
                role: worker.displayName,
                efficiency: 0.75 + (worker.level * 0.05).clamp(0.0, 0.25),
                status: _getWorkerStatus(worker),
                onUpgrade: () {
                  // Upgrade logic
                },
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Hire Button
        Center(
          child: CyberButton(
            label: 'HIRE NEW UNIT',
            subLabel: '50 SHARDS',
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

  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMMAND CENTER',
              style: TimeFactoryTextStyles.header.copyWith(fontSize: 20),
            ),
            Text(
              'ACTIVE UNITS: $count',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: TimeFactoryColors.electricCyan,
              ),
            ),
          ],
        ),
        Icon(Icons.hub, color: TimeFactoryColors.electricCyan, size: 28),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.person_off, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'NO UNITS DETECTED',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  String _getWorkerStatus(Worker worker) {
    // Mock status logic based on rarity?
    return worker.rarity == WorkerRarity.legendary ? "OPTIMAL" : "STABLE";
  }
}
