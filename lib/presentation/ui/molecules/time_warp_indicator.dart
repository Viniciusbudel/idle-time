import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Animated badge that shows the current time warp speed multiplier.
/// Only visible when timeWarpMultiplier > 1.0.
class TimeWarpIndicator extends ConsumerWidget {
  const TimeWarpIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multiplier = ref.watch(timeWarpMultiplierProvider);
    if (multiplier <= 1.0) return const SizedBox.shrink();

    return _AnimatedBadge(multiplier: multiplier);
  }
}

class _AnimatedBadge extends StatefulWidget {
  final double multiplier;
  const _AnimatedBadge({required this.multiplier});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.4,
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
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TimeFactoryColors.acidGreen.withValues(
                alpha: _glowAnimation.value * 0.8,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: TimeFactoryColors.acidGreen.withValues(
                  alpha: _glowAnimation.value * 0.4,
                ),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppHugeIcons.fast_forward_rounded,
                size: 14,
                color: TimeFactoryColors.acidGreen.withValues(
                  alpha: 0.6 + _glowAnimation.value * 0.4,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.multiplier.toStringAsFixed(2)}x',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: TimeFactoryColors.acidGreen,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: TimeFactoryColors.acidGreen.withValues(
                        alpha: _glowAnimation.value * 0.6,
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
