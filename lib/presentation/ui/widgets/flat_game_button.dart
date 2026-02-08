import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/era_theme_provider.dart';

class FlatGameButton extends ConsumerStatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final IconData? icon;

  const FlatGameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 50,
    this.icon,
  });

  @override
  ConsumerState<FlatGameButton> createState() => _FlatGameButtonState();
}

class _FlatGameButtonState extends ConsumerState<FlatGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _scaleController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _scaleController.reverse();
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(eraThemeProvider);

    // Determine colors based on Theme if not explicitly provided
    final buttonColor = widget.color ?? theme.primaryColor;
    final labelColor = widget.textColor ?? theme.backgroundColor; // Contrast

    final effectiveColor = widget.isDisabled
        ? Colors.grey.withValues(alpha: 0.2)
        : buttonColor;

    return MouseRegion(
      cursor: widget.isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isDisabled
                    ? null
                    : [
                        BoxShadow(
                          color: effectiveColor.withValues(
                            alpha:
                                (_isHovered ? 0.6 : 0.4) * theme.particleGlow,
                          ),
                          blurRadius:
                              (_isHovered ? 12 : 8) * theme.particleGlow,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          labelColor.withValues(alpha: 0.8),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.isDisabled ? Colors.grey : labelColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TimeFactoryTextStyles.button.copyWith(
                            color: widget.isDisabled ? Colors.grey : labelColor,
                            fontFamily: theme.fontFamily,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                  // Optional: Scanline/Grain overlay for style
                  if (!widget.isDisabled && !widget.isLoading)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
