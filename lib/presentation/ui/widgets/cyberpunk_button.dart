import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';

/// Cyberpunk-styled button with neon glow effects
class CyberpunkButton extends StatefulWidget {
  final String label;
  final String? subLabel;
  final VoidCallback? onPressed;
  final Color color;
  final bool isGlitching;
  final IconData? icon;
  final bool isLarge;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double? height;
  final double? fontSize;

  const CyberpunkButton({
    super.key,
    required this.label,
    this.subLabel,
    this.onPressed,
    this.color = TimeFactoryColors.electricCyan,
    this.isGlitching = false,
    this.icon,
    this.isLarge = false,
    this.isLoading = false,
    this.isPrimary = false,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  State<CyberpunkButton> createState() => _CyberpunkButtonState();
}

class _CyberpunkButtonState extends State<CyberpunkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final effectiveColor = isEnabled
        ? widget.color
        : TimeFactoryColors.smokeGray;

    // Primary buttons have solid background
    final baseBg = widget.isPrimary
        ? effectiveColor.withValues(alpha: 0.2)
        : TimeFactoryColors.voidBlack;

    final pressBg = widget.isPrimary
        ? effectiveColor.withValues(alpha: 0.4)
        : effectiveColor.withValues(alpha: 0.1);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        if (isEnabled) {
          HapticFeedback.mediumImpact();
          widget.onPressed!();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isLarge
                    ? 32
                    : (widget.width != null ? 0 : 24),
                vertical: widget.isLarge
                    ? 16
                    : (widget.height != null ? 0 : 12),
              ),
              decoration: BoxDecoration(
                color: _isPressed ? pressBg : baseBg,
                border: Border.all(
                  color: effectiveColor,
                  width: widget.isPrimary ? 2 : 1, // Thicker border for primary
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isEnabled
                    ? TimeFactoryColors.neonGlow(
                        effectiveColor,
                        intensity: _isPressed
                            ? 1.5
                            : (widget.isPrimary ? 1.2 : 1.0),
                      )
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(effectiveColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: effectiveColor,
                        size: widget.isLarge ? 24 : 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label.toUpperCase(),
                          style: TimeFactoryTextStyles.button.copyWith(
                            fontSize:
                                widget.fontSize ?? (widget.isLarge ? 18 : 14),
                            color: effectiveColor,
                            fontWeight: widget.isPrimary
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (widget.subLabel != null)
                          Text(
                            widget.subLabel!,
                            style: TimeFactoryTextStyles.numbersSmall.copyWith(
                              fontSize: (widget.fontSize ?? 14) * 0.8,
                              color: effectiveColor.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small icon-only cyberpunk button
class CyberpunkIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;

  const CyberpunkIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = TimeFactoryColors.electricCyan,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final effectiveColor = isEnabled ? color : TimeFactoryColors.smokeGray;

    return GestureDetector(
      onTap: () {
        if (isEnabled) {
          HapticFeedback.lightImpact();
          onPressed!();
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: effectiveColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isEnabled
              ? TimeFactoryColors.neonGlow(effectiveColor, intensity: 0.5)
              : null,
        ),
        child: Icon(icon, color: effectiveColor, size: size * 0.5),
      ),
    );
  }
}
