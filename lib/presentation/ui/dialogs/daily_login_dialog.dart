import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/daily_reward.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/molecules/glass_card.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class DailyLoginDialog extends ConsumerWidget {
  const DailyLoginDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DailyLoginDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(
      gameStateProvider.select(
        (s) => ref.read(gameStateProvider.notifier).currentStreak,
      ),
    );
    final isAvailable = ref.watch(
      gameStateProvider.select(
        (s) => ref.read(gameStateProvider.notifier).isDailyRewardAvailable,
      ),
    );

    // Determine which day is "active" (next to claim)
    final activeIndex = streak % 7;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'DAILY REWARDS',
              style: TimeFactoryTextStyles.header.copyWith(
                color: TimeFactoryColors.voltageYellow,
                fontSize: 24,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log in consecutive days to earn better rewards!',
              style: TimeFactoryTextStyles.body.copyWith(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Grid of 7 days
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(7, (index) {
                final reward = DailyReward.weekRewards[index];
                final isClaimed =
                    index < activeIndex; // Past days in current cycle
                final isCurrent = index == activeIndex;

                return _DayCard(
                  reward: reward,
                  state: isClaimed
                      ? _DayState.claimed
                      : isCurrent
                      ? (isAvailable ? _DayState.ready : _DayState.waiting)
                      : _DayState.locked,
                );
              }),
            ),

            const SizedBox(height: 24),

            // Claim Button
            if (isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TimeFactoryColors.voltageYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _claim(context, ref),
                  child: Text(
                    'CLAIM REWARD',
                    style: TimeFactoryTextStyles.header.copyWith(fontSize: 16),
                  ),
                ),
              )
            else
              Text(
                'Come back tomorrow for the next reward!',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _claim(BuildContext context, WidgetRef ref) {
    final result = ref.read(gameStateProvider.notifier).claimDailyReward();
    if (result != null) {
      // Close dialog
      Navigator.pop(context);

      if (result.unlockedWorker != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: TimeFactoryColors.paradoxPurple,
            content: Text(
              'Unlocked: ${result.unlockedWorker!.name} (${result.unlockedWorker!.rarity.displayName})!',
              style: TimeFactoryTextStyles.body,
            ),
          ),
        );
      }
    }
  }
}

enum _DayState { locked, ready, waiting, claimed }

class _DayCard extends StatelessWidget {
  final DailyReward reward;
  final _DayState state;

  const _DayCard({required this.reward, required this.state});

  @override
  Widget build(BuildContext context) {
    final isParadox = reward.type == DailyRewardType.worker;
    final size = isParadox ? 80.0 : 70.0;

    Color borderColor;
    Color bgColor;
    double opacity = 1.0;

    switch (state) {
      case _DayState.locked:
        borderColor = Colors.white10;
        bgColor = Colors.black26;
        opacity = 0.5;
        break;
      case _DayState.waiting:
        borderColor = TimeFactoryColors.electricCyan.withAlpha(100);
        bgColor = TimeFactoryColors.electricCyan.withAlpha(20);
        break;
      case _DayState.ready:
        borderColor = TimeFactoryColors.voltageYellow;
        bgColor = TimeFactoryColors.voltageYellow.withAlpha(40);
        break;
      case _DayState.claimed:
        borderColor = Colors.green;
        bgColor = Colors.green.withAlpha(20);
        break;
    }

    if (isParadox) {
      borderColor = TimeFactoryColors.paradoxPurple;
      if (state == _DayState.ready) {
        bgColor = TimeFactoryColors.paradoxPurple.withAlpha(60);
      }
    }

    return Container(
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: state == _DayState.ready ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: state == _DayState.ready
            ? [BoxShadow(color: borderColor.withAlpha(100), blurRadius: 8)]
            : null,
      ),
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DAY ${reward.day}',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(child: Center(child: _buildIcon())),
            if (state == _DayState.claimed)
              const AppIcon(AppHugeIcons.check, color: Colors.green, size: 16)
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildLabel(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (reward.type) {
      case DailyRewardType.chronoEnergy:
        return const AppIcon(
          AppHugeIcons.flash_on,
          color: TimeFactoryColors.electricCyan,
          size: 24,
        );
      case DailyRewardType.timeShard:
        return const AppIcon(
          AppHugeIcons.auto_awesome,
          color: TimeFactoryColors.hotMagenta,
          size: 24,
        );
      case DailyRewardType.worker:
        return const AppIcon(
          AppHugeIcons.person,
          color: TimeFactoryColors.paradoxPurple,
          size: 32,
        );
    }
  }

  Widget _buildLabel() {
    String text = '';
    Color color = Colors.white;

    switch (reward.type) {
      case DailyRewardType.chronoEnergy:
        text = '${reward.amountCE} CE';
        color = TimeFactoryColors.electricCyan;
        break;
      case DailyRewardType.timeShard:
        text = '${reward.amountShards} TS';
        color = TimeFactoryColors.hotMagenta;
        break;
      case DailyRewardType.worker:
        text = 'PARADOX';
        color = TimeFactoryColors.paradoxPurple;
        break;
    }

    return Text(
      text,
      style: TimeFactoryTextStyles.bodyMono.copyWith(fontSize: 9, color: color),
      textAlign: TextAlign.center,
    );
  }
}
