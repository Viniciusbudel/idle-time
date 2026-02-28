import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class CyberButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final AppIconData? icon;
  final VoidCallback? onTap;
  final Color primaryColor;
  final Color textColor;
  final bool isLarge;

  const CyberButton({
    super.key,
    required this.label,
    this.subLabel,
    this.icon,
    this.onTap,
    this.primaryColor = TimeFactoryColors.electricCyan,
    this.textColor = Colors.black,
    this.isLarge = false,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.onTap != null;
    final backgroundColor = isActive
        ? widget.primaryColor.withValues(alpha: _isPressed ? 0.8 : 1.0)
        : const Color(0xFF1E242B); // Dark grey

    return GestureDetector(
      onTapDown: isActive ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isActive
          ? (_) {
              setState(() => _isPressed = false);
              HapticFeedback.mediumImpact();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isActive ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: CustomPaint(
          painter: _CyberButtonPainter(
            fillColor: backgroundColor,
            borderColor: isActive
                ? widget.primaryColor.withValues(alpha: 0.5)
                : Colors.white24,
            isPressed: _isPressed,
          ),
          child: Container(
            height: widget.isLarge ? 48 : 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  AppIcon(widget.icon!, size: 16, color: widget.textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: widget.textColor,
                    fontSize: widget.isLarge ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                if (widget.subLabel != null) ...[
                  Container(
                    width: 1,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: widget.textColor.withValues(alpha: 0.2),
                  ),
                  Text(
                    widget.subLabel!,
                    style: TimeFactoryTextStyles.bodyMono.copyWith(
                      fontSize: 10,
                      color: widget.textColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberButtonPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final bool isPressed;

  _CyberButtonPainter({
    required this.fillColor,
    required this.borderColor,
    required this.isPressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width - (size.height * 0.3), size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    if (!isPressed && fillColor != const Color(0xFF1E242B)) {
      canvas.drawShadow(path, fillColor.withValues(alpha: 0.5), 4.0, false);
    }

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberButtonPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        isPressed != oldDelegate.isPressed;
  }
}
