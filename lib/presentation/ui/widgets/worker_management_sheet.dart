import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neon_theme.dart';
import '../../../core/theme/game_theme.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/worker.dart';
import '../../state/game_state_provider.dart';
import 'merge_effect_overlay.dart';

class WorkerManagementSheet extends ConsumerStatefulWidget {
  const WorkerManagementSheet({super.key});

  @override
  ConsumerState<WorkerManagementSheet> createState() =>
      _WorkerManagementSheetState();
}

class _WorkerManagementSheetState extends ConsumerState<WorkerManagementSheet> {
  bool _showMergeEffect = false;
  Worker? _mergedWorkerResult;

  void _triggerMergeEffect(Worker? newWorker) {
    setState(() {
      _mergedWorkerResult = newWorker;
      _showMergeEffect = true;
    });
  }

  void _showMergeResultDialog() {
    if (_mergedWorkerResult == null) return;

    showDialog(
      context: context,
      builder: (context) => _MergeResultDialog(worker: _mergedWorkerResult!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workers = ref.watch(workersProvider);
    // TODO: Get theme from provider eventually
    final theme = const NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    // Group available (undeployed) workers by Rarity
    final availableWorkers = workers.values
        .where((w) => !w.isDeployed)
        .toList();
    final grouped = <WorkerRarity, List<Worker>>{};

    for (var rarity in WorkerRarity.values) {
      grouped[rarity] = availableWorkers
          .where((w) => w.rarity == rarity)
          .toList();
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: colors.primary, width: 2)),
          ),
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WORKER MANAGEMENT',
                    style: typography.titleLarge.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Merge 3 workers of the same rarity to create 1 of higher rarity.',
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // List of Rarities
              Expanded(
                child: ListView.separated(
                  itemCount:
                      WorkerRarity.values.length -
                      1, // Exclude Paradox (top tier)
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final rarity = WorkerRarity.values[index];
                    final tierWorkers = grouped[rarity] ?? [];
                    return _buildRaritySection(ref, theme, rarity, tierWorkers);
                  },
                ),
              ),
            ],
          ),
        ),
        if (_showMergeEffect)
          Positioned.fill(
            child: MergeEffectOverlay(
              primaryColor: _mergedWorkerResult != null
                  ? _getRarityColor(_mergedWorkerResult!.rarity, colors)
                  : Colors.white,
              onComplete: () {
                setState(() {
                  _showMergeEffect = false;
                });
                _showMergeResultDialog();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRaritySection(
    WidgetRef ref,
    NeonTheme theme,
    WorkerRarity rarity,
    List<Worker> workers,
  ) {
    final colors = theme.colors;
    final typography = theme.typography;

    // Group by Era to check for merge candidates
    final byEra = <WorkerEra, List<Worker>>{};
    for (var w in workers) {
      byEra.putIfAbsent(w.era, () => []).add(w);
    }

    final mergeableSets = byEra.entries
        .where((e) => e.value.length >= 3)
        .toList();
    final canMergeAny = mergeableSets.isNotEmpty;

    // Rarity Color
    final rarityColor = _getRarityColor(rarity, colors);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: rarityColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: rarityColor.withOpacity(0.5)),
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/workers/worker_victorian_${rarity.id}.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rarity.displayName.toUpperCase(),
                  style: typography.titleMedium.copyWith(color: rarityColor),
                ),
              ),
              Text(
                '${workers.length} Available',
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),

          if (canMergeAny) ...[
            const SizedBox(height: 12),
            ...mergeableSets.map((entry) {
              final era = entry.key;
              final count = entry.value.length;
              final mergesPossible = count ~/ 3;

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${era.displayName}: $count',
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rarityColor.withOpacity(0.2),
                        side: BorderSide(color: rarityColor),
                      ),
                      onPressed: () {
                        // Try merging 1 set
                        final result = ref
                            .read(gameStateProvider.notifier)
                            .mergeWorkers(era, rarity);

                        if (!result.success) {
                          ScaffoldMessenger.of(ref.context).showSnackBar(
                            SnackBar(
                              content: Text(result.error ?? 'Merge failed'),
                            ),
                          );
                        } else {
                          // Success! Trigger animation
                          _triggerMergeEffect(result.newWorker);
                        }
                      },
                      child: Text(
                        'MERGE ($mergesPossible)',
                        style: typography.buttonText.copyWith(
                          color: rarityColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else if (workers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Need 3 of same era to merge",
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRarityColor(WorkerRarity rarity, ThemeColors colors) {
    switch (rarity) {
      case WorkerRarity.common:
        return colors.rarityCommon;
      case WorkerRarity.rare:
        return colors.rarityRare;
      case WorkerRarity.epic:
        return colors.rarityEpic;
      case WorkerRarity.legendary:
        return colors.rarityLegendary;
      case WorkerRarity.paradox:
        return colors.rarityParadox;
    }
  }
}

class _MergeResultDialog extends StatelessWidget {
  final Worker worker;

  const _MergeResultDialog({required this.worker});

  @override
  Widget build(BuildContext context) {
    // TODO: Use provider for theme
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    final rarityColor = _getRarityColor(worker.rarity, colors);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: rarityColor, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MERGE SUCCESSFUL!',
              style: typography.titleLarge.copyWith(color: colors.accent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rarityColor.withValues(alpha: 0.2),
                border: Border.all(color: rarityColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/workers/worker_victorian_${worker.rarity.id}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, color: rarityColor, size: 40);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              worker.displayName.toUpperCase(),
              style: typography.titleLarge.copyWith(color: rarityColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${worker.rarity.displayName} Unit',
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PROD: ${worker.baseProduction}',
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rarityColor,
                foregroundColor: Colors.black, // Contrast
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('EXCELLENT'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(WorkerRarity rarity, ThemeColors colors) {
    switch (rarity) {
      case WorkerRarity.common:
        return colors.rarityCommon;
      case WorkerRarity.rare:
        return colors.rarityRare;
      case WorkerRarity.epic:
        return colors.rarityEpic;
      case WorkerRarity.legendary:
        return colors.rarityLegendary;
      case WorkerRarity.paradox:
        return colors.rarityParadox;
    }
  }
}
