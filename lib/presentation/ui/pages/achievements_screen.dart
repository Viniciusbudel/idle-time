import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/achievement.dart';
import 'package:time_factory/presentation/state/achievement_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(allAchievementsProvider);
    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.emoji_events,
              color: TimeFactoryColors.voltageYellow,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'ACHIEVEMENTS',
              style: TimeFactoryTextStyles.header.copyWith(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: TimeFactoryColors.voltageYellow.withOpacity( 0.2),
                  border: Border.all(
                    color: TimeFactoryColors.voltageYellow.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unlockedCount / ${achievements.length}',
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    fontSize: 12,
                    color: TimeFactoryColors.voltageYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = achievements[index];
          return _AchievementCard(
            achievement: item.type,
            unlocked: item.unlocked,
            progress: item.progress,
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementType achievement;
  final bool unlocked;
  final double progress;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = unlocked
        ? TimeFactoryColors.voltageYellow
        : Colors.white24;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked
            ? TimeFactoryColors.voltageYellow.withOpacity( 0.05)
            : Colors.white.withOpacity( 0.03),
        border: Border.all(color: accentColor.withOpacity( 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity( 0.15),
              border: Border.all(color: accentColor.withOpacity( 0.4)),
            ),
            child: Icon(
              unlocked ? achievement.icon : Icons.lock_outline,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.displayName.toUpperCase(),
                  style: TimeFactoryTextStyles.header.copyWith(
                    fontSize: 13,
                    color: unlocked ? Colors.white : Colors.white38,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    fontSize: 10,
                    color: unlocked ? Colors.white60 : Colors.white24,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity( 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      unlocked
                          ? TimeFactoryColors.voltageYellow
                          : TimeFactoryColors.electricCyan.withValues(
                              alpha: 0.5,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Reward badge
          if (unlocked)
            const Icon(
              Icons.check_circle,
              color: TimeFactoryColors.voltageYellow,
              size: 24,
            )
          else
            _buildRewardBadge(),
        ],
      ),
    );
  }

  Widget _buildRewardBadge() {
    final hasCE = achievement.rewardCE > 0;
    final hasShards = achievement.rewardShards > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasCE)
          Text(
            '+${achievement.rewardCE}',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 9,
              color: TimeFactoryColors.electricCyan.withOpacity( 0.5),
            ),
          ),
        if (hasShards)
          Text(
            '+${achievement.rewardShards}💎',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 9,
              color: TimeFactoryColors.hotMagenta.withOpacity( 0.5),
            ),
          ),
      ],
    );
  }
}
