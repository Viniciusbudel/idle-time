import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/ui/widgets/tech_card.dart';

class TechTreeTab extends StatelessWidget {
  const TechTreeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for now as per plan
    final upgrades = [
      _MockUpgrade(
        title: "Chronal Stabilizer",
        level: 3,
        description: "Reduces paradox buildup by 15%",
        progress: 0.7,
        cost: "500 CE",
      ),
      _MockUpgrade(
        title: "Quantum Drill",
        level: 1,
        description: "Increases mining efficiency by 25%",
        progress: 0.2,
        cost: "1.2k CE",
        icon: Icons.api,
        color: TimeFactoryColors.voltageYellow,
      ),
      _MockUpgrade(
        title: "Neural Network",
        level: 5,
        description: "Workers automate tasks 10% faster",
        progress: 1.0,
        cost: "MAX",
        icon: Icons.psychology,
        color: TimeFactoryColors.hotMagenta,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildHeader(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TECH AUGMENTATION',
              style: TimeFactoryTextStyles.header.copyWith(fontSize: 20),
            ),
            Text(
              'SYSTEM UPGRADES AVAILABLE',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: TimeFactoryColors.electricCyan,
              ),
            ),
          ],
        ),
        const Icon(Icons.memory, color: TimeFactoryColors.electricCyan, size: 28),
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
  final IconData icon;
  final Color color;

  _MockUpgrade({
    required this.title,
    required this.level,
    required this.description,
    required this.progress,
    required this.cost,
    this.icon = Icons.science,
    this.color = TimeFactoryColors.electricCyan,
  });
}
