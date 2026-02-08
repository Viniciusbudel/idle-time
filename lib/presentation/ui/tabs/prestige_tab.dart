import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/widgets/cyber_button.dart';
import 'package:time_factory/presentation/ui/widgets/glass_card.dart';

class PrestigeTab extends ConsumerWidget {
  const PrestigeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      children: [
        _buildHeader(),
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
                'TIMELINE COLLAPSE',
                style: TimeFactoryTextStyles.header.copyWith(
                  color: TimeFactoryColors.hotMagenta,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reset your timeline to gain Prestige Points (PP).\nPP increases production by 10% per point.',
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
                      'ESTIMATED REWARD',
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
                label: 'INITIATE COLLAPSE',
                icon: Icons.dangerous,
                isLarge: true,
                primaryColor: TimeFactoryColors.hotMagenta,
                onTap: gameState.canPrestige ? () => notifier.prestige() : null,
              ),

              if (!gameState.canPrestige)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Require more lifetime earnings to collapse.',
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('PRESTIGE', style: TimeFactoryTextStyles.header),
        const Icon(
          Icons.military_tech,
          color: TimeFactoryColors.hotMagenta,
          size: 28,
        ),
      ],
    );
  }
}
