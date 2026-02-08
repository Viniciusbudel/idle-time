import 'package:flutter/material.dart';

class SteampunkPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SteampunkPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // Metallic Gradient Background
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF42382F), // Dark Bronze Light
            Color(0xFF231E19), // Dark Bronze Shadow
            Color(0xFF1A1612), // Deep Iron
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFF8B5A2B), // Copper/Rust border
          width: 2,
        ),
        boxShadow: [
          // Outer Drop Shadow (Elevation)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          // Inner Highlight (Inset effect via light border alignment)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner Bolts
          const Positioned(top: 2, left: 2, child: _Bolt()),
          const Positioned(top: 2, right: 2, child: _Bolt()),
          const Positioned(bottom: 2, left: 2, child: _Bolt()),
          const Positioned(bottom: 2, right: 2, child: _Bolt()),

          // Content
          Padding(
            padding: const EdgeInsets.all(4.0), // Space for bolts
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Bolt extends StatelessWidget {
  const _Bolt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFE0C097), // Brass Light
            Color(0xFF5D4037), // Brass Dark
          ],
          center: Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}
