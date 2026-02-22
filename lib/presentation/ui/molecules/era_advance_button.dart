import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/services/era_progression_service.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class EraAdvanceButton extends ConsumerWidget {
  const EraAdvanceButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final eraService = ref.watch(eraProgressionServiceProvider);
    final isEraComplete = ref.watch(isEraCompleteProvider);

    final currentEraId = gameState.currentEraId;
    final nextEraId = eraService.getNextEra(currentEraId);
    final cost = eraService.getNextEraCost(currentEraId);

    if (nextEraId == null) {
      // Max Era Reached
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.black45,
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.timelineMaximized,
            style: TimeFactoryTextStyles.header.copyWith(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final canAfford = cost != null && gameState.chronoEnergy >= cost;
    final isReady = canAfford && isEraComplete;
    final nextEraName = _getEraDisplayName(context, nextEraId);

    return GestureDetector(
      onTap: isReady
          ? () {
              HapticFeedback.heavyImpact();
              eraService.advanceEra();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isReady
              ? TimeFactoryColors.electricCyan.withOpacity(0.1)
              : Colors.black54,
          border: Border.all(
            color: isReady ? TimeFactoryColors.electricCyan : Colors.white10,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isReady
              ? [
                  BoxShadow(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Era Icon/Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isReady
                    ? TimeFactoryColors.electricCyan.withOpacity(0.2)
                    : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                isEraComplete
                    ? AppHugeIcons.history_edu
                    : AppHugeIcons.lock_clock, // Lock icon if tech not done
                color: isReady
                    ? TimeFactoryColors.electricCyan
                    : Colors.white24,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.advanceTimeline,
                    style: TimeFactoryTextStyles.bodyMono.copyWith(
                      color: isReady
                          ? TimeFactoryColors.electricCyan
                          : Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextEraName,
                    style: TimeFactoryTextStyles.header.copyWith(
                      color: isReady ? Colors.white : Colors.white24,
                      fontSize: 18,
                    ),
                  ),
                  if (!isEraComplete)
                    Text(
                      AppLocalizations.of(context)!.techIncomplete,
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        color: TimeFactoryColors.hotMagenta,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            // Cost
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context)!.requirement,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
                Text(
                  cost != null ? '${NumberFormatter.formatCE(cost)} CE' : 'N/A',
                  style: TimeFactoryTextStyles.numbers.copyWith(
                    color: canAfford
                        ? TimeFactoryColors.acidGreen
                        : TimeFactoryColors.hotMagenta,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEraDisplayName(BuildContext context, String eraId) {
    // Better to use WorkerEra enum mapping
    try {
      final eraEnum = WorkerEra.values.firstWhere((e) => e.id == eraId);
      return eraEnum.localizedName(context).toUpperCase();
    } catch (_) {
      return eraId.toUpperCase().replaceAll('_', ' ');
    }
  }
}
