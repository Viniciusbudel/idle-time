import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/ui/atoms/cyber_button.dart';
import 'package:time_factory/l10n/app_localizations.dart';

class TechCard extends StatelessWidget {
  final String title;
  final int level;
  final String description;
  final double progress;
  final String cost;
  final VoidCallback? onUpgrade;
  final IconData icon;
  final Color color;

  const TechCard({
    super.key,
    required this.title,
    required this.level,
    required this.description,
    required this.progress,
    required this.cost,
    this.onUpgrade,
    this.icon = Icons.science,
    this.color = TimeFactoryColors.electricCyan,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TechCardClipper(),
      child: Container(
        padding: const EdgeInsets.all(1), // Border width
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3), // Border color
        ),
        child: ClipPath(
          clipper: _TechCardClipper(),
          child: Container(
            color: TimeFactoryColors.surfaceDark.withValues(alpha: 0.9),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Tech Icon Box
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),

                    // Header
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title.toUpperCase(),
                                style: TimeFactoryTextStyles.headerSmall
                                    .copyWith(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'LVL $level',
                                  style: TimeFactoryTextStyles.bodyMono
                                      .copyWith(
                                        fontSize: 10,
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TimeFactoryTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Upgrade Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.nextEffect((progress * 100).toInt().toString()),
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    CyberButton(
                      label: AppLocalizations.of(context)!.upgrade,
                      subLabel: cost,
                      icon: Icons.upgrade,
                      onTap: onUpgrade,
                      primaryColor: color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TechCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const bevel = 10.0;
    // Top Left Bevel
    path.moveTo(0, bevel);
    path.lineTo(bevel, 0);
    // Top Right
    path.lineTo(size.width, 0);
    // Bottom Right Bevel
    path.lineTo(size.width, size.height - bevel);
    path.lineTo(size.width - bevel, size.height);
    // Bottom Left
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
