import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/usecases/fit_worker_to_era_usecase.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

class FitWorkerDialog extends ConsumerWidget {
  final Worker worker;
  final FitWorkerToEraUseCase useCase = FitWorkerToEraUseCase();

  FitWorkerDialog({super.key, required this.worker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final currentEraId = state.currentEraId;
    final currentEra = WorkerEra.values.firstWhere((e) => e.id == currentEraId);

    // Calculate cost
    final cost = useCase.calculateCost(worker, currentEra);
    final canAfford = state.chronoEnergy >= cost;

    // Simulate new worker
    final newWorker = worker.copyWith(era: currentEra);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1520),
          border: Border.all(color: TimeFactoryColors.voltageYellow, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TimeFactoryColors.voltageYellow.withValues(alpha: 0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RETROFIT PROTCOL',
              style: TimeFactoryTextStyles.header.copyWith(
                color: TimeFactoryColors.voltageYellow,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade legacy unit to current temporal standards?',
              textAlign: TextAlign.center,
              style: TimeFactoryTextStyles.body.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // Comparison Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  'CURRENT',
                  worker.currentProduction,
                  Colors.white54,
                ),
                const Icon(Icons.arrow_forward, color: Colors.white24),
                _buildStatColumn(
                  'UPGRADED',
                  newWorker.currentProduction,
                  TimeFactoryColors.electricCyan,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Cost & Action
            Text(
              'COST: ${NumberFormatter.formatCE(cost)} CE',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: canAfford ? Colors.white : Colors.redAccent,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TimeFactoryColors.voltageYellow,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: canAfford
                      ? () {
                          // Execute fitting
                          // We need a provider method exposed or logic injected
                          // For now, let's assume we add a method to GameStateNotifier
                          // or handle it here via state update if possible (but we need notifier access)
                          ref
                              .read(gameStateProvider.notifier)
                              .fitWorkerToEra(worker.id);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('CONFIRM UPGRADE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, BigInt value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            color: Colors.white24,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${NumberFormatter.formatCE(value)}/s',
          style: TimeFactoryTextStyles.headerSmall.copyWith(
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
