import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

/// Floating badge that shows the auto-click rate when automation tech is active.
/// Only visible when automationLevel > 0.
class AutoClickIndicator extends ConsumerWidget {
  const AutoClickIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automationLevel = TechData.calculateAutomationLevel(
      ref.watch(gameStateProvider.select((s) => s.techLevels)),
    );
    if (automationLevel <= 0) return const SizedBox.shrink();

    return _AnimatedAutoClickBadge(clicksPerSecond: automationLevel);
  }
}

class _AnimatedAutoClickBadge extends StatefulWidget {
  final double clicksPerSecond;
  const _AnimatedAutoClickBadge({required this.clicksPerSecond});

  @override
  State<_AnimatedAutoClickBadge> createState() =>
      _AnimatedAutoClickBadgeState();
}

class _AnimatedAutoClickBadgeState extends State<_AnimatedAutoClickBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Pulse speed scales with clicks/sec (faster automation = faster pulse)
    final durationMs = (1000 / widget.clicksPerSecond).clamp(300, 2000).toInt();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity( 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TimeFactoryColors.electricCyan.withValues(
                alpha: _pulseAnimation.value * 0.7,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: TimeFactoryColors.electricCyan.withValues(
                  alpha: _pulseAnimation.value * 0.3,
                ),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.precision_manufacturing_rounded,
                size: 14,
                color: TimeFactoryColors.electricCyan.withValues(
                  alpha: 0.5 + _pulseAnimation.value * 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.clicksPerSecond.toStringAsFixed(1)}/s',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: TimeFactoryColors.electricCyan,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: TimeFactoryColors.electricCyan.withValues(
                        alpha: _pulseAnimation.value * 0.5,
                      ),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
