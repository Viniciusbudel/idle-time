import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/domain/entities/achievement.dart';
import 'package:time_factory/presentation/state/achievement_provider.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/atoms/achievement_toast.dart';

/// Wraps a child widget and shows achievement toasts when milestones unlock
class AchievementListener extends ConsumerStatefulWidget {
  final Widget child;

  const AchievementListener({super.key, required this.child});

  @override
  ConsumerState<AchievementListener> createState() =>
      _AchievementListenerState();
}

class _AchievementListenerState extends ConsumerState<AchievementListener> {
  final List<AchievementType> _toastQueue = [];
  AchievementType? _currentToast;

  @override
  Widget build(BuildContext context) {
    // Listen for newly unlocked achievements
    ref.listen(achievementCheckerProvider, (previous, newlyUnlocked) {
      for (final achievement in newlyUnlocked) {
        // Unlock and grant rewards
        ref
            .read(gameStateProvider.notifier)
            .unlockAchievement(
              achievement.id,
              rewardCE: achievement.rewardCE,
              rewardShards: achievement.rewardShards,
            );
        // Queue the toast
        _toastQueue.add(achievement);
      }
      _showNextToast();
    });

    return Stack(
      children: [
        widget.child,
        if (_currentToast != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AchievementToast(
              key: ValueKey(_currentToast!.id),
              achievement: _currentToast!,
              onDismiss: () {
                setState(() {
                  _currentToast = null;
                });
                // Show next queued toast
                Future.delayed(
                  const Duration(milliseconds: 300),
                  _showNextToast,
                );
              },
            ),
          ),
      ],
    );
  }

  void _showNextToast() {
    if (_currentToast != null || _toastQueue.isEmpty) return;
    setState(() {
      _currentToast = _toastQueue.removeAt(0);
    });
  }
}
