import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';

/// Animated number display that smoothly transitions between values
/// with scale pulse and color flash effects
class AnimatedNumber extends StatefulWidget {
  final BigInt value;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final Duration duration;
  final bool showPulse;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.prefix,
    this.suffix,
    this.duration = const Duration(milliseconds: 400),
    this.showPulse = true,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isIncreasing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value && widget.showPulse) {
      _isIncreasing = widget.value > oldWidget.value;
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? TimeFactoryTextStyles.numbers;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Determine glow color based on increase/decrease
        final glowColor = _isIncreasing
            ? TimeFactoryColors.acidGreen
            : TimeFactoryColors.hotMagenta;

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: _glowAnimation.value > 0.1
                  ? [
                      BoxShadow(
                        color: glowColor.withValues(
                          alpha: _glowAnimation.value * 0.4,
                        ),
                        blurRadius: 12 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '${widget.prefix ?? ''}${NumberFormatter.format(widget.value)}${widget.suffix ?? ''}',
              style: baseStyle.copyWith(
                color: _glowAnimation.value > 0.3
                    ? Color.lerp(
                        baseStyle.color,
                        glowColor,
                        _glowAnimation.value * 0.5,
                      )
                    : baseStyle.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Chrono-Energy display with icon and glow
class ChronoEnergyDisplay extends StatelessWidget {
  final BigInt amount;
  final BigInt? perSecond;
  final bool showPerSecond;
  final bool large;
  final double? glitchLevel;

  const ChronoEnergyDisplay({
    super.key,
    required this.amount,
    this.perSecond,
    this.showPerSecond = true,
    this.large = false,
    this.glitchLevel,
  });

  @override
  Widget build(BuildContext context) {
    final shouldGlitch = glitchLevel != null && glitchLevel! > 0.7;
    final formattedAmount = shouldGlitch
        ? NumberFormatter.formatWithGlitch(amount, glitchLevel!)
        : NumberFormatter.format(amount);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: TimeFactoryColors.midnightBlue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TimeFactoryColors.electricCyan.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: TimeFactoryColors.neonGlow(
          TimeFactoryColors.electricCyan,
          intensity: 0.3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/icons/chrono_energy_icon.png',
                width: large ? 32 : 24,
                height: large ? 32 : 24,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                formattedAmount,
                style:
                    (large
                            ? TimeFactoryTextStyles.numbersLarge
                            : TimeFactoryTextStyles.numbers)
                        .copyWith(
                          color: shouldGlitch
                              ? TimeFactoryColors.hotMagenta
                              : TimeFactoryColors.acidGreen,
                        ),
              ),
            ],
          ),
          if (showPerSecond && perSecond != null)
            Text(
              '+${NumberFormatter.format(perSecond!)}/sec',
              style: TimeFactoryTextStyles.bodySmall.copyWith(
                color: TimeFactoryColors.electricCyan.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }
}

/// Time Shards display with neon glow
class TimeShardsDisplay extends StatelessWidget {
  final int amount;
  final bool compact;

  const TimeShardsDisplay({
    super.key,
    required this.amount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: compact ? AppSpacing.xxs : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: TimeFactoryColors.midnightBlue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(compact ? 4 : 8),
        border: Border.all(
          color: TimeFactoryColors.deepPurple.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TimeFactoryColors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔮', style: TextStyle(fontSize: compact ? 14 : 16)),
          SizedBox(width: compact ? AppSpacing.xxs : AppSpacing.xs),
          Text(
            amount.toString(),
            style:
                (compact
                        ? TimeFactoryTextStyles.numbersSmall
                        : TimeFactoryTextStyles.numbers)
                    .copyWith(color: TimeFactoryColors.deepPurple),
          ),
        ],
      ),
    );
  }
}
