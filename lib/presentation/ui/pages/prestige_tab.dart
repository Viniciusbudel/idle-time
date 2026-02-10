import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/atoms/cyber_button.dart';
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
        _buildHeader(context),
        const SizedBox(height: 32),

        GlassCard(
          padding: const EdgeInsets.all(24),
          borderGlow: true,
          borderColor: TimeFactoryColors.hotMagenta,
          child: Column(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 64,
                color: TimeFactoryColors.hotMagenta,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.timelineCollapse,
                style: TimeFactoryTextStyles.header.copyWith(
                  color: TimeFactoryColors.hotMagenta,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.prestigeDescription,
                textAlign: TextAlign.center,
                style: TimeFactoryTextStyles.body.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TimeFactoryColors.hotMagenta),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.estimatedReward,
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${gameState.prestigePointsToGain} PP',
                      style: TimeFactoryTextStyles.numbersHuge.copyWith(
                        color: TimeFactoryColors.hotMagenta,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              CyberButton(
                label: AppLocalizations.of(context)!.initiateCollapse,
                icon: Icons.dangerous,
                isLarge: true,
                primaryColor: TimeFactoryColors.hotMagenta,
                onTap: gameState.canPrestige ? () => notifier.prestige() : null,
              ),

              if (!gameState.canPrestige)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    AppLocalizations.of(context)!.prestigeRequirement,
                    style: TimeFactoryTextStyles.bodySmall.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.prestige.toUpperCase(),
          style: TimeFactoryTextStyles.header,
        ),
        const Icon(
          Icons.military_tech,
          color: TimeFactoryColors.hotMagenta,
          size: 28,
        ),
      ],
    );
  }
}
