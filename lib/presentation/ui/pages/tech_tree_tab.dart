import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/ui/molecules/tech_card.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class TechTreeTab extends StatelessWidget {
  const TechTreeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for now as per plan
    final l10n = AppLocalizations.of(context)!;
    final upgrades = [
      _MockUpgrade(
        title: l10n.techTreeChronalStabilizer,
        level: 3,
        description: l10n.techTreeChronalStabilizerDescription,
        progress: 0.7,
        cost: l10n.techTreeCostCe('500'),
      ),
      _MockUpgrade(
        title: l10n.techTreeQuantumDrill,
        level: 1,
        description: l10n.techTreeQuantumDrillDescription,
        progress: 0.2,
        cost: l10n.techTreeCostCe('1.2k'),
        icon: AppHugeIcons.api,
        color: TimeFactoryColors.voltageYellow,
      ),
      _MockUpgrade(
        title: l10n.techTreeNeuralNetwork,
        level: 5,
        description: l10n.techTreeNeuralNetworkDescription,
        progress: 1.0,
        cost: l10n.max,
        icon: AppHugeIcons.psychology,
        color: TimeFactoryColors.hotMagenta,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        ...upgrades.map(
          (u) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TechCard(
              title: u.title,
              level: u.level,
              description: u.description,
              progress: u.progress,
              cost: u.cost,
              icon: u.icon,
              color: u.color,
              onUpgrade: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.techAugmentation,
              style: TimeFactoryTextStyles.header.copyWith(fontSize: 20),
            ),
            Text(
              AppLocalizations.of(context)!.systemUpgradesAvailable,
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: TimeFactoryColors.electricCyan,
              ),
            ),
          ],
        ),
        const AppIcon(
          AppHugeIcons.memory,
          color: TimeFactoryColors.electricCyan,
          size: 28,
        ),
      ],
    );
  }
}

class _MockUpgrade {
  final String title;
  final int level;
  final String description;
  final double progress;
  final String cost;
  final AppIconData icon;
  final Color color;

  _MockUpgrade({
    required this.title,
    required this.level,
    required this.description,
    required this.progress,
    required this.cost,
    this.icon = AppHugeIcons.science,
    this.color = TimeFactoryColors.electricCyan,
  });
}
