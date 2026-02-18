import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/core/theme/era_theme_provider.dart';

class AnimatedReactor extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  final double size;

  const AnimatedReactor({super.key, required this.onTap, this.size = 200});

  @override
  ConsumerState<AnimatedReactor> createState() => _AnimatedReactorState();
}

class _AnimatedReactorState extends ConsumerState<AnimatedReactor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Spin speed
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    HapticFeedback.mediumImpact();
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(eraThemeProvider);

    return GestureDetector(
      onTapDown: (_) => _handleTap(),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Spinning Reactor SVG
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * pi,
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  GameAssets.temporalReactor,
                  width: widget.size,
                  height: widget.size,
                  // Apply theme color filter if needed, or keep original colors
                  // colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
                ),
              ),

              // Optional: Inner glow or overlay based on theme
              Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
