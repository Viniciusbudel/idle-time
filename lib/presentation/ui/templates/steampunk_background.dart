import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Steampunk Parallax Background with Breathing Animation
///
/// High-performance animated background using a single AnimationController
/// with 3 parallax layers + fog overlay. Optimized for mobile idle games.
class SteampunkBackground extends StatefulWidget {
  /// Optional child to render on top of the background
  final Widget? child;

  const SteampunkBackground({super.key, this.child});

  @override
  State<SteampunkBackground> createState() => _SteampunkBackgroundState();
}

class _SteampunkBackgroundState extends State<SteampunkBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Interactive touch offset
  double _touchOffsetY = 0.0;
  double _animationSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      // Slightly boost animation speed on tap
      _animationSpeed = 1.5;
      // Add small vertical offset based on tap position
      final screenHeight = MediaQuery.of(context).size.height;
      _touchOffsetY = (details.localPosition.dy / screenHeight - 0.5) * 10;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _animationSpeed = 1.0;
      _touchOffsetY = 0.0;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _animationSpeed = 1.0;
      _touchOffsetY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Back (Static or very slow drift)
          const _BackLayer(),

          // Layer 2: Mid (Floating animation)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Sine wave for smooth breathing effect
              final sineValue = math.sin(
                _controller.value * math.pi * 2 * _animationSpeed,
              );
              final offsetY = sineValue * 8 + _touchOffsetY;

              return Transform.translate(
                offset: Offset(0, offsetY),
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/backgrounds/victorian/bg-victorian-mid.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              isAntiAlias: false,
            ),
          ),

          // Layer 3: Front (Subtle scale pulse)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Subtle scale breathing: 1.0 to 1.02
              final scaleValue =
                  1.0 + (math.sin(_controller.value * math.pi * 2) * 0.01);

              return Transform.scale(scale: scaleValue, child: child);
            },
            child: Image.asset(
              'assets/images/backgrounds/victorian/bg-victorian-front.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              isAntiAlias: false,
            ),
          ),

          // Fog/Veil Overlay (Animated opacity)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Opacity pulses between 0.1 and 0.25
              final opacity =
                  0.1 + (math.sin(_controller.value * math.pi * 2) * 0.075);

              return Container(color: Colors.black.withOpacity( opacity));
            },
          ),

          // Child widget (game content)
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

/// Static back layer - separated for optimal rebuild performance
class _BackLayer extends StatelessWidget {
  const _BackLayer();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/backgrounds/victorian/bg-victorian-back.png',
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      isAntiAlias: false,
    );
  }
}
