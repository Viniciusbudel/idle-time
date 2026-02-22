import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/ui/atoms/cyber_button.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class TechCard extends StatelessWidget {
  final String title;
  final int level;
  final String description;
  final double progress;
  final String cost;
  final VoidCallback? onUpgrade;
  final AppIconData icon;
  final Color color;
  final String? effectLabel;
  final String? effectDescription;

  const TechCard({
    super.key,
    required this.title,
    required this.level,
    required this.description,
    required this.progress,
    required this.cost,
    this.onUpgrade,
    this.icon = AppHugeIcons.science,
    this.color = TimeFactoryColors.electricCyan,
    this.effectLabel,
    this.effectDescription,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TechCardClipper(),
      child: Container(
        padding: const EdgeInsets.all(1), // Border width
        decoration: BoxDecoration(
          color: color.withOpacity(0.3), // Border color
        ),
        child: ClipPath(
          clipper: _TechCardClipper(),
          child: Container(
            color: TimeFactoryColors.surfaceDark.withOpacity(0.9),
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
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: AppIcon(icon, color: color),
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
                              Expanded(
                                child: Text(
                                  title.toUpperCase(),
                                  style: TimeFactoryTextStyles.headerSmall
                                      .copyWith(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
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
                            color: color.withOpacity(0.5),
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
                      effectDescription ??
                          AppLocalizations.of(context)!.nextEffect(
                            effectLabel ??
                                AppLocalizations.of(context)!.efficiency,
                            (progress * 100).toInt().toString(),
                          ),
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    CyberButton(
                      label: AppLocalizations.of(context)!.upgrade,
                      subLabel: cost,
                      icon: AppHugeIcons.upgrade,
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

extension TechTypeLocalization on TechType {
  String localizedEffect(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case TechType.automation:
        return l10n.automationEffect;
      case TechType.efficiency:
        return l10n.efficiencyEffect;
      case TechType.timeWarp:
        return l10n.timeWarpEffect;
      case TechType.costReduction:
        return l10n.costReductionEffect;
      case TechType.offline:
        return l10n.offlineEffect;
      case TechType.clickPower:
        return l10n.clickPowerEffect;
      case TechType.eraUnlock:
        return l10n.eraUnlockEffect;
      case TechType.manhattan:
        return l10n.manhattanEffect;
    }
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
