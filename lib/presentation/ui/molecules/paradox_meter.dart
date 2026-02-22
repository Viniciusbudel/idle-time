import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Paradox meter showing temporal instability level
class ParadoxMeter extends StatelessWidget {
  final double level; // 0.0 to 1.0
  final bool showLabel;
  final bool compact;

  const ParadoxMeter({
    super.key,
    required this.level,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = level >= 0.7;
    final isCritical = level >= 0.9;

    final barColor = isCritical
        ? TimeFactoryColors.voltageYellow
        : isWarning
        ? TimeFactoryColors.hotMagenta
        : TimeFactoryColors.deepPurple;

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: TimeFactoryColors.midnightBlue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: barColor.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppIcon(
                      isCritical
                          ? AppHugeIcons.warning_amber
                          : isWarning
                          ? AppHugeIcons.error_outline
                          : AppHugeIcons.access_time,
                      color: barColor,
                      size: compact ? 16 : 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PARADOX',
                      style: TimeFactoryTextStyles.body.copyWith(
                        color: barColor,
                        fontSize: compact ? 10 : 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  NumberFormatter.formatPercent(level),
                  style: TimeFactoryTextStyles.numbersSmall.copyWith(
                    color: barColor,
                  ),
                ),
              ],
            ),
          if (showLabel) SizedBox(height: compact ? 4 : 8),
          _ParadoxProgressBar(
            level: level,
            color: barColor,
            height: compact ? 6 : 10,
            isGlitching: isWarning,
          ),
          if (showLabel && isCritical)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '⚠ REALITY FRACTURE IMMINENT',
                style: TimeFactoryTextStyles.glitch.copyWith(fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParadoxProgressBar extends StatefulWidget {
  final double level;
  final Color color;
  final double height;
  final bool isGlitching;

  const _ParadoxProgressBar({
    required this.level,
    required this.color,
    required this.height,
    required this.isGlitching,
  });

  @override
  State<_ParadoxProgressBar> createState() => _ParadoxProgressBarState();
}

class _ParadoxProgressBarState extends State<_ParadoxProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    if (widget.isGlitching) {
      _glitchController.repeat();
    }
  }

  @override
  void didUpdateWidget(_ParadoxProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlitching && !_glitchController.isAnimating) {
      _glitchController.repeat();
    } else if (!widget.isGlitching && _glitchController.isAnimating) {
      _glitchController.stop();
    }
  }

  @override
  void dispose() {
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        final glitchOffset = widget.isGlitching
            ? ((_glitchController.value * 10).toInt() % 3 - 1) * 2.0
            : 0.0;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: TimeFactoryColors.voidBlack,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(color: widget.color.withOpacity(0.3), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: Transform.translate(
              offset: Offset(glitchOffset, 0),
              child: FractionallySizedBox(
                widthFactor: widget.level.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.color.withOpacity(0.8), widget.color],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact inline paradox indicator
class ParadoxIndicator extends StatelessWidget {
  final double level;

  const ParadoxIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isWarning = level >= 0.7;
    final color = isWarning
        ? TimeFactoryColors.hotMagenta
        : TimeFactoryColors.deepPurple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            isWarning ? AppHugeIcons.warning_amber : AppHugeIcons.access_time,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            NumberFormatter.formatPercent(level, decimals: 0),
            style: TimeFactoryTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
