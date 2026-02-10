import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';

/// A scrolling cyberpunk grid background based on HTML reference
/// CSS:
/// background-image:
///     linear-gradient(rgba(13, 227, 242, 0.1) 1px, transparent 1px),
///     linear-gradient(90deg, rgba(13, 227, 242, 0.1) 1px, transparent 1px);
/// background-size: 40px 40px;
class CyberGridBackground extends StatefulWidget {
  final double scrollSpeed;

  const CyberGridBackground({super.key, this.scrollSpeed = 0.5});

  @override
  State<CyberGridBackground> createState() => _CyberGridBackgroundState();
}

class _CyberGridBackgroundState extends State<CyberGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Dark Void Base
        Container(color: TimeFactoryColors.voidBlack),

        // 2. Animated Grid
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _GridPainter(
                offset: _controller.value * 40.0, // Move by one grid cell
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.1),
              ),
            );
          },
        ),

        // 3. Vignette / Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TimeFactoryColors.voidBlack.withValues(alpha: 0.0),
                TimeFactoryColors.voidBlack.withValues(alpha: 0.5),
                TimeFactoryColors.voidBlack,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final double offset;
  final Color color;

  _GridPainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const gridSize = 40.0;

    // Draw Vertical Lines
    // Add offset for parallax/scrolling effect if desired, standard is static or slow move
    // Here we scroll vertically (like moving forward)

    // Horizontal Lines (Moving down)
    double y = (offset % gridSize) - gridSize;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += gridSize;
    }

    // Vertical Lines (Static)
    // Optional: perspective transform could be done here, but sticking to 2D grid for now
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += gridSize;
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return offset != oldDelegate.offset || color != oldDelegate.color;
  }
}
