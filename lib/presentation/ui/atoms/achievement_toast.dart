import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/achievement.dart';

/// Animated toast that slides in when an achievement unlocks
class AchievementToast extends StatefulWidget {
  final AchievementType achievement;
  final VoidCallback onDismiss;

  const AchievementToast({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final hasShards = a.rewardShards > 0;
    final hasCE = a.rewardCE > 0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1520),
                  border: Border.all(
                    color: TimeFactoryColors.voltageYellow,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: TimeFactoryColors.voltageYellow.withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Trophy icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TimeFactoryColors.voltageYellow.withValues(
                          alpha: 0.2,
                        ),
                        border: Border.all(
                          color: TimeFactoryColors.voltageYellow.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      child: Icon(
                        a.icon,
                        color: TimeFactoryColors.voltageYellow,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🏆 ACHIEVEMENT UNLOCKED',
                            style: TimeFactoryTextStyles.bodyMono.copyWith(
                              fontSize: 9,
                              color: TimeFactoryColors.voltageYellow,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.displayName.toUpperCase(),
                            style: TimeFactoryTextStyles.header.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (hasCE) ...[
                                const Icon(
                                  Icons.bolt,
                                  color: TimeFactoryColors.electricCyan,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '+${a.rewardCE} CE',
                                  style: TimeFactoryTextStyles.bodyMono
                                      .copyWith(
                                        fontSize: 10,
                                        color: TimeFactoryColors.electricCyan,
                                      ),
                                ),
                              ],
                              if (hasCE && hasShards) const SizedBox(width: 8),
                              if (hasShards) ...[
                                const Icon(
                                  Icons.diamond_outlined,
                                  color: TimeFactoryColors.hotMagenta,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '+${a.rewardShards} Shards',
                                  style: TimeFactoryTextStyles.bodyMono
                                      .copyWith(
                                        fontSize: 10,
                                        color: TimeFactoryColors.hotMagenta,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
