import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/domain/entities/daily_mission.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

class DailyObjectivePanel extends ConsumerStatefulWidget {
  const DailyObjectivePanel({super.key});

  @override
  ConsumerState<DailyObjectivePanel> createState() =>
      _DailyObjectivePanelState();
}

class _DailyObjectivePanelState extends ConsumerState<DailyObjectivePanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final missions = ref.watch(dailyMissionsProvider);
    if (missions.isEmpty) return const SizedBox.shrink();

    final allClaimed = missions.every((m) => m.claimed);
    final pendingCount = missions.where((m) => !m.claimed).length;

    if (!_expanded) {
      return _CollapsedObjectivesButton(
        pendingCount: pendingCount,
        allClaimed: allClaimed,
        onTap: () => setState(() => _expanded = true),
      );
    }

    return Container(
      width: 240,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TimeFactoryColors.electricCyan.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AppIcon(
                AppHugeIcons.auto_awesome,
                size: 14,
                color: TimeFactoryColors.acidGreen,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'DAILY OBJECTIVES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: TimeFactoryColors.electricCyan,
                  ),
                ),
              ),
              if (allClaimed)
                const AppIcon(
                  AppHugeIcons.check_circle,
                  size: 14,
                  color: TimeFactoryColors.acidGreen,
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _expanded = false),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    size: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...missions.map((mission) => _MissionRow(mission: mission)),
        ],
      ),
    );
  }
}

class _CollapsedObjectivesButton extends StatelessWidget {
  final int pendingCount;
  final bool allClaimed;
  final VoidCallback onTap;

  const _CollapsedObjectivesButton({
    required this.pendingCount,
    required this.allClaimed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = allClaimed
        ? TimeFactoryColors.acidGreen.withValues(alpha: 0.65)
        : TimeFactoryColors.electricCyan.withValues(alpha: 0.65);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.25),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              allClaimed
                  ? AppHugeIcons.check_circle
                  : AppHugeIcons.auto_awesome,
              size: 13,
              color: allClaimed
                  ? TimeFactoryColors.acidGreen
                  : TimeFactoryColors.electricCyan,
            ),
            const SizedBox(width: 6),
            Text(
              allClaimed ? 'OBJECTIVES DONE' : '$pendingCount OBJECTIVES',
              style: TextStyle(
                color: allClaimed
                    ? TimeFactoryColors.acidGreen
                    : TimeFactoryColors.electricCyan,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionRow extends ConsumerWidget {
  final DailyMission mission;

  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressText = '${mission.progress}/${mission.target}';
    final isComplete = mission.isCompleted;
    final icon = _iconForType(mission.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: mission.claimed
              ? TimeFactoryColors.acidGreen.withValues(alpha: 0.45)
              : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          AppIcon(
            icon,
            size: 12,
            color: isComplete
                ? TimeFactoryColors.acidGreen
                : TimeFactoryColors.electricCyan,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progressText,
                  style: TextStyle(
                    fontSize: 9,
                    color: isComplete
                        ? TimeFactoryColors.acidGreen
                        : Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _buildTrailing(ref),
        ],
      ),
    );
  }

  Widget _buildTrailing(WidgetRef ref) {
    if (mission.claimed) {
      return const AppIcon(
        AppHugeIcons.check_circle,
        size: 12,
        color: TimeFactoryColors.acidGreen,
      );
    }

    if (!mission.isCompleted) {
      return Text(
        '+${mission.rewardShards}TS',
        style: const TextStyle(
          fontSize: 8,
          color: TimeFactoryColors.hotMagenta,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        ref.read(gameStateProvider.notifier).claimDailyMission(mission.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: TimeFactoryColors.acidGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: TimeFactoryColors.acidGreen),
        ),
        child: const Text(
          'CLAIM',
          style: TextStyle(
            fontSize: 8,
            color: TimeFactoryColors.acidGreen,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  AppIconData _iconForType(MissionType type) {
    switch (type) {
      case MissionType.hireWorkers:
        return AppHugeIcons.person_add;
      case MissionType.mergeWorkers:
        return AppHugeIcons.merge_type;
      case MissionType.buyTechUpgrades:
        return AppHugeIcons.memory;
    }
  }
}
