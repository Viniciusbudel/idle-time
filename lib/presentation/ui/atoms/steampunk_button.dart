import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';

class SteampunkButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isPrimary;
  final IconData? icon;
  final GameTheme? themeOverride;
  final double? width;
  final double? height;

  const SteampunkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isPrimary = false,
    this.icon,
    this.themeOverride,
    this.width,
    this.height,
  });

  @override
  ConsumerState<SteampunkButton> createState() => _SteampunkButtonState();
}
// ... (State class remains mostly same but needs access to widget.themeOverride)

class _SteampunkButtonState extends ConsumerState<SteampunkButton>
    with SingleTickerProviderStateMixin {
  // ... (animation state)
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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

  // ... (tap handlers)
  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    _isPressed = true;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _isPressed = false;
    _controller.reverse();
    widget.onPressed?.call();
    HapticFeedback.mediumImpact();
  }

  void _handleTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeOverride ?? ref.watch(themeProvider);
    final colors = theme!.colors;
    final dimens = theme.dimens;
    final isEnabled = widget.onPressed != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(dimens.cornerRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isEnabled
                      ? (widget.isDestructive
                            ? [Colors.red.shade300, colors.error]
                            : widget.isPrimary
                            ? [colors.accent, colors.primary]
                            : [
                                colors.primary.withValues(alpha: 0.5),
                                colors.surface,
                              ])
                      : [Colors.grey.shade700, Colors.grey.shade900],
                ),
                border: Border.all(
                  color: isEnabled ? colors.glassBorder : Colors.grey.shade600,
                  width: 2.0,
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          offset: _isPressed
                              ? const Offset(2, 2)
                              : const Offset(4, 4),
                          blurRadius: _isPressed ? 2 : 6,
                        ),
                        // Top highlight ("shine")
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          offset: const Offset(-1, -1),
                          blurRadius: 1,
                        ),
                      ]
                    : [],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: dimens.paddingMedium * 1.5,
                vertical: dimens.paddingMedium,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: isEnabled
                          ? colors.textPrimary
                          : Colors.grey.shade500,
                      size: dimens.iconSizeMedium,
                    ),
                    SizedBox(width: dimens.paddingSmall),
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: theme.typography.buttonText.copyWith(
                      color: isEnabled
                          ? colors.textPrimary
                          : Colors.grey.shade500,
                      shadows: isEnabled
                          ? [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
