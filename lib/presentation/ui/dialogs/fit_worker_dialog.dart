import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/usecases/fit_worker_to_era_usecase.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';

class FitWorkerDialog extends ConsumerWidget {
  final Worker worker;
  final FitWorkerToEraUseCase useCase = FitWorkerToEraUseCase();

  FitWorkerDialog({super.key, required this.worker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
          color: const Color(0xFF03070C),
          border: Border.all(color: TimeFactoryColors.voltageYellow, width: 2),
          borderRadius: BorderRadius.circular(4),
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
              l10n.retrofitProtocol.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: TimeFactoryColors.voltageYellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.upgradeLegacyUnitPrompt,
              textAlign: TextAlign.center,
              style: TimeFactoryTextStyles.body.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // Comparison Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  l10n.current,
                  worker.currentProduction,
                  Colors.white54,
                ),
                const AppIcon(
                  AppHugeIcons.arrow_forward,
                  color: Colors.white24,
                ),
                _buildStatColumn(
                  l10n.upgraded,
                  newWorker.currentProduction,
                  TimeFactoryColors.electricCyan,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Cost & Action
            Text(
              '${l10n.cost}: ${NumberFormatter.formatCE(cost)} CE',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: canAfford ? Colors.white : Colors.redAccent,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GameActionButton(
                    onTap: () => Navigator.pop(context),
                    label: l10n.cancel.toUpperCase(),
                    color: Colors.white54,
                    icon: AppHugeIcons.close,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GameActionButton(
                    onTap: canAfford
                        ? () {
                            ref
                                .read(gameStateProvider.notifier)
                                .fitWorkerToEra(worker.id);
                            Navigator.pop(context);
                          }
                        : null,
                    label: AppLocalizations.of(
                      context,
                    )!.confirmUpgrade.toUpperCase(),
                    color: TimeFactoryColors.voltageYellow,
                    icon: AppHugeIcons.check_circle,
                    height: 48,
                  ),
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
