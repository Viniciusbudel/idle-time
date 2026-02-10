import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/neon_theme.dart';
import '../../../core/theme/game_theme.dart';
import '../../../domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/worker_icon_helper.dart';
import '../atoms/merge_effect_overlay.dart';

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
    final gameState = ref.watch(gameStateProvider);
    final workers = gameState.workers;
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
                    AppLocalizations.of(context)!.workerManagement,
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
                AppLocalizations.of(context)!.mergeInstructions,
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Legacy Units Section (Refit)
              if (availableWorkers.any(
                (w) => w.era.id != gameState.currentEraId,
              ))
                _buildLegacySection(
                  ref,
                  theme,
                  availableWorkers,
                  gameState.currentEraId,
                ),

              const SizedBox(height: 16),

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

  Widget _buildLegacySection(
    WidgetRef ref,
    NeonTheme theme,
    List<Worker> availableWorkers,
    String currentEraId,
  ) {
    final legacyWorkers = availableWorkers
        .where((w) => w.era.id != currentEraId)
        .toList();
    final colors = theme.colors;
    final typography = theme.typography;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.5),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.legacyUnitsDetected,
                style: typography.titleMedium.copyWith(
                  color: const Color(0xFFD4AF37),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.legacyUnitsDescription,
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          // Horizontal list of legacy workers
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: legacyWorkers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final worker = legacyWorkers[index];
                final refitCost = worker.upgradeCost * BigInt.from(10);
                final canAfford =
                    ref.watch(gameStateProvider).chronoEnergy >= refitCost;

                return Container(
                  width: 140,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.background,
                    border: Border.all(
                      color: _getRarityColor(
                        worker.rarity,
                        colors,
                      ).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        worker.displayName,
                        style: typography.bodySmall.copyWith(
                          color: _getRarityColor(worker.rarity, colors),
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFD4AF37,
                          ).withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 30),
                        ),
                        onPressed: canAfford
                            ? () => ref
                                  .read(gameStateProvider.notifier)
                                  .refitWorkerEra(worker.id)
                            : null,
                        child: Text(
                          AppLocalizations.of(context)!.refit,
                          style: typography.bodySmall.copyWith(
                            color: const Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${NumberFormatter.formatCE(refitCost)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: canAfford ? colors.textPrimary : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
                  color: rarityColor.withOpacity(0.2),
                  border: Border.all(color: rarityColor.withOpacity(0.5)),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      WorkerIconHelper.getIconPath(WorkerEra.victorian, rarity),
                      colorFilter: ColorFilter.mode(
                        rarityColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rarity.localizedName(context).toUpperCase(),
                  style: typography.titleMedium.copyWith(color: rarityColor),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.available(workers.length),
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
                              content: Text(
                                result.error ??
                                    AppLocalizations.of(context)!.mergeFailed,
                              ),
                            ),
                          );
                        } else {
                          // Success! Trigger animation
                          _triggerMergeEffect(result.newWorker);
                        }
                      },
                      child: Text(
                        '${AppLocalizations.of(context)!.merge} ($mergesPossible)',
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
              AppLocalizations.of(context)!.needMoreToMerge,
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
              AppLocalizations.of(context)!.mergeSuccessful,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    WorkerIconHelper.getIconPath(worker.era, worker.rarity),
                    colorFilter: ColorFilter.mode(rarityColor, BlendMode.srcIn),
                  ),
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
              AppLocalizations.of(
                context,
              )!.unit(worker.rarity.localizedName(context)),
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.production}: ${worker.baseProduction}',
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rarityColor,
                foregroundColor: Colors.black, // Contrast
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.excellent),
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
