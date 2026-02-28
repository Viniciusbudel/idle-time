import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Game-style action button with scale press feedback (0.96)
/// and subtle active flicker animation.
class GameActionButton extends StatefulWidget {
  final String label;
  final AppIconData icon;
  final Color color;
  final bool enabled;
  final bool isMaxed;
  final VoidCallback? onTap;
  final double height;

  const GameActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.enabled = true,
    this.isMaxed = false,
    this.onTap,
    this.height = 38,
  });

  @override
  State<GameActionButton> createState() => _GameActionButtonState();
}

class _GameActionButtonState extends State<GameActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _flickerController;
  late final Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _flickerAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 3),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 84),
    ]).animate(_flickerController);

    if (widget.enabled && !widget.isMaxed) {
      _flickerController.repeat();
    }
  }

  @override
  void didUpdateWidget(GameActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !widget.isMaxed) {
      if (!_flickerController.isAnimating) _flickerController.repeat();
    } else {
      _flickerController.stop();
      _flickerController.value = 0;
    }
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.enabled && !widget.isMaxed;
    final accent = widget.color;

    final borderColor = widget.isMaxed
        ? accent.withValues(alpha: 0.45)
        : (isActive ? accent.withValues(alpha: 0.70) : Colors.white24);

    return AnimatedBuilder(
      animation: _flickerAnimation,
      builder: (context, child) {
        return AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Opacity(opacity: _flickerAnimation.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: isActive ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isActive
            ? (_) {
                setState(() => _isPressed = false);
                HapticFeedback.lightImpact();
                widget.onTap?.call();
              }
            : null,
        onTapCancel: isActive ? () => setState(() => _isPressed = false) : null,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isActive ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.20),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  widget.icon,
                  size: 15,
                  color: isActive || widget.isMaxed ? accent : Colors.white38,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    color: isActive || widget.isMaxed ? accent : Colors.white38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
