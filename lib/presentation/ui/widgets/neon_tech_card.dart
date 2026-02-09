import 'package:flutter/material.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';

class NeonTechCard extends StatefulWidget {
  final TechUpgrade tech;
  final VoidCallback? onUpgrade;
  final bool canAfford;
  final bool isMaxed;

  const NeonTechCard({
    super.key,
    required this.tech,
    this.onUpgrade,
    this.canAfford = false,
    this.isMaxed = false,
  });

  @override
  State<NeonTechCard> createState() => _NeonTechCardState();
}

class _NeonTechCardState extends State<NeonTechCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final nextCost = widget.tech.nextCost;
    final progress = (widget.tech.level / widget.tech.maxLevel).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black, // Cyber Void
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.primary.withValues(alpha: widget.canAfford ? 0.6 : 0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Tech Details
          Positioned.fill(
            child: CustomPaint(
              painter: _TechBackgroundPainter(
                color: colors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon + Title + Level
                Row(
                  children: [
                    // Hex Icon Container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getTechIcon(widget.tech.type),
                          color: colors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tech.name.toUpperCase(),
                            style: typography.bodyMedium.copyWith(
                              fontFamily: 'Orbitron',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.tech.description,
                            style: typography.bodyMedium.copyWith(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // LeveL Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: colors.secondary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.isMaxed ? 'MAX' : 'LVL ${widget.tech.level}',
                        style: typography.bodyMedium.copyWith(
                          fontSize: 10,
                          color: colors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar (Holographic)
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Scanline on progress bar
                      if (!widget.isMaxed)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: progress,
                                child: ClipRect(
                                  child: CustomPaint(
                                    painter: _ProgressBarScanPainter(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      offset: _controller.value,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Footer: Effect & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Current Effect
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT MODULE EFFECT',
                          style: typography.bodyMedium.copyWith(
                            fontSize: 8,
                            color: colors.primary.withValues(alpha: 0.7),
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          widget.tech.bonusDescription,
                          style: typography.bodyMedium.copyWith(
                            fontSize: 11,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),

                    // Action Button
                    _buildActionButton(colors, typography, nextCost),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    ThemeColors colors,
    ThemeTypography typography,
    BigInt cost,
  ) {
    if (widget.isMaxed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Text(
          'MAXIMIZED',
          style: typography.bodyMedium.copyWith(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final bool enabled = widget.canAfford;

    return GestureDetector(
      onTap: enabled ? widget.onUpgrade : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? colors.primary.withValues(alpha: 0.2) : Colors.black,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: enabled
                ? colors.primary
                : colors.error.withValues(alpha: 0.5),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              'UPGRADE',
              style: typography.buttonText.copyWith(
                fontSize: 10,
                color: enabled ? colors.primary : colors.error,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '${NumberFormatter.formatCE(cost)} CE',
              style: typography.bodyMedium.copyWith(
                fontSize: 9,
                color: enabled
                    ? Colors.white
                    : colors.error.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTechIcon(TechType type) {
    switch (type) {
      case TechType.automation:
        return Icons.precision_manufacturing;
      case TechType.efficiency:
        return Icons.bolt;
      case TechType.timeWarp:
        return Icons.shutter_speed;
      case TechType.costReduction:
        return Icons.price_change;
      case TechType.offline:
        return Icons.bedtime;
      case TechType.clickPower:
        return Icons.touch_app;
      case TechType.eraUnlock:
        return Icons.vpn_key;
    }
  }
}

class _TechBackgroundPainter extends CustomPainter {
  final Color color;
  _TechBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    // decorative lines
    path.moveTo(size.width - 20, 0);
    path.lineTo(size.width, 20);

    path.moveTo(0, size.height - 20);
    path.lineTo(20, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressBarScanPainter extends CustomPainter {
  final Color color;
  final double offset;

  _ProgressBarScanPainter({required this.color, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0;

    final x = offset * size.width;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }

  @override
  bool shouldRepaint(_ProgressBarScanPainter oldDelegate) =>
      offset != oldDelegate.offset || color != oldDelegate.color;
}
