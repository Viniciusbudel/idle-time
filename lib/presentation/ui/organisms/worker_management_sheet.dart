import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/neon_theme.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/constants/colors.dart';
import '../../../domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import '../atoms/merge_effect_overlay.dart';
import '../atoms/worker_tile.dart';
import '../dialogs/fit_worker_dialog.dart';
import '../dialogs/worker_result_dialog.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class WorkerManagementSheet extends ConsumerStatefulWidget {
  const WorkerManagementSheet({super.key});

  @override
  ConsumerState<WorkerManagementSheet> createState() =>
      _WorkerManagementSheetState();
}

class _WorkerManagementSheetState extends ConsumerState<WorkerManagementSheet>
    with SingleTickerProviderStateMixin {
  WorkerRarity? _selectedRarity; // null = ALL
  final Set<String> _selectedWorkerIds = {};
  bool _showMergeEffect = false;
  Worker? _mergedWorkerResult;
  late AnimationController _mergeBarController;
  late Animation<Offset> _mergeBarSlide;

  @override
  void initState() {
    super.initState();
    _mergeBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _mergeBarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _mergeBarController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _mergeBarController.dispose();
    super.dispose();
  }

  void _toggleWorkerSelection(Worker worker) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedWorkerIds.contains(worker.id)) {
        _selectedWorkerIds.remove(worker.id);
      } else {
        // Only allow same era + rarity selection
        if (_selectedWorkerIds.isNotEmpty) {
          final gameState = ref.read(gameStateProvider);
          final firstSelected = gameState.workers[_selectedWorkerIds.first];
          if (firstSelected != null &&
              (worker.era != firstSelected.era ||
                  worker.rarity != firstSelected.rarity)) {
            // Different era/rarity — clear and start fresh
            _selectedWorkerIds.clear();
          }
        }
        if (_selectedWorkerIds.length < 3) {
          _selectedWorkerIds.add(worker.id);
        }
      }
    });

    // Animate merge bar
    bool showBar = false;
    if (_selectedWorkerIds.length >= 3) {
      showBar = true;
    } else if (_selectedWorkerIds.length == 1) {
      // Show for "Fit to Era" if legacy
      final api = ref.read(gameStateProvider);
      final worker = api.workers[_selectedWorkerIds.first];
      if (worker != null && worker.era.id != api.currentEraId) {
        showBar = true;
      }
    }

    if (showBar) {
      _mergeBarController.forward();
    } else {
      _mergeBarController.reverse();
    }
  }

  void _performMerge() {
    if (_selectedWorkerIds.length < 3) return;

    HapticFeedback.heavyImpact();
    final result = ref
        .read(gameStateProvider.notifier)
        .mergeSpecificWorkers(_selectedWorkerIds.toList());

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? AppLocalizations.of(context)!.mergeFailed,
          ),
        ),
      );
      return;
    }

    setState(() {
      _mergedWorkerResult = result.newWorker;
      _showMergeEffect = true;
      _selectedWorkerIds.clear();
    });
    _mergeBarController.reverse();
  }

  void _showMergeResultDialog() {
    if (_mergedWorkerResult == null) return;
    showDialog(
      context: context,
      builder: (context) => WorkerResultDialog(
        worker: _mergedWorkerResult!,
        title: AppLocalizations.of(context)!.mergeSuccessful,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final workers = gameState.workers;
    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    // Filter available (undeployed) workers
    var availableWorkers = workers.values.where((w) => !w.isDeployed).toList();

    // Apply rarity filter
    if (_selectedRarity != null) {
      availableWorkers = availableWorkers
          .where((w) => w.rarity == _selectedRarity)
          .toList();
    }

    // Sort: current era first, then by rarity
    availableWorkers.sort((a, b) {
      // Current era workers first
      final aIsCurrent = a.era.id == gameState.currentEraId ? 0 : 1;
      final bIsCurrent = b.era.id == gameState.currentEraId ? 0 : 1;
      if (aIsCurrent != bIsCurrent) return aIsCurrent.compareTo(bIsCurrent);
      // Then by rarity (higher first)
      final rarityCompare = b.rarity.index.compareTo(a.rarity.index);
      if (rarityCompare != 0) return rarityCompare;
      return a.displayName.compareTo(b.displayName);
    });

    // Count available merges
    final allAvailable = workers.values.where((w) => !w.isDeployed).toList();
    final rarityCount = <WorkerRarity, int>{};
    for (final r in WorkerRarity.values) {
      rarityCount[r] = allAvailable.where((w) => w.rarity == r).length;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: colors.primary, width: 2)),
          ),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.workerManagement,
                        style: typography.titleLarge.copyWith(
                          color: colors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: AppIcon(
                        AppHugeIcons.close,
                        color: colors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: Text(
                  AppLocalizations.of(context)!.mergeInstructions,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rarity Filter Tabs
              _buildRarityTabs(colors, typography, rarityCount),

              const SizedBox(height: 16),

              // Worker Grid
              Expanded(
                child: availableWorkers.isEmpty
                    ? Center(
                        child: Text(
                          _selectedRarity != null
                              ? AppLocalizations.of(context)!.noWorkersByRarity(
                                  _selectedRarity!.localizedName(context),
                                )
                              : AppLocalizations.of(context)!.noIdleWorkers,
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: availableWorkers.length,
                        itemBuilder: (context, index) {
                          final worker = availableWorkers[index];
                          final isLegacy =
                              worker.era.id != gameState.currentEraId;
                          final isSelected = _selectedWorkerIds.contains(
                            worker.id,
                          );

                          return WorkerTile(
                            worker: worker,
                            colors: colors,
                            isSelected: isSelected,
                            isLegacy: isLegacy,
                            onTap: () => _toggleWorkerSelection(worker),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // Merge Action Bar (slides up from bottom)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: _mergeBarSlide,
            child: _buildMergeActionBar(colors, typography),
          ),
        ),

        // Merge Effect Overlay
        if (_showMergeEffect)
          Positioned.fill(
            child: MergeEffectOverlay(
              primaryColor: _mergedWorkerResult != null
                  ? _getRarityColor(_mergedWorkerResult!.rarity, colors)
                  : Colors.white,
              onComplete: () {
                setState(() => _showMergeEffect = false);
                _showMergeResultDialog();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRarityTabs(
    ThemeColors colors,
    ThemeTypography typography,
    Map<WorkerRarity, int> counts,
  ) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // ALL tab
          _buildFilterChip(
            label: AppLocalizations.of(context)!.all,
            isActive: _selectedRarity == null,
            color: colors.primary,
            typography: typography,
            onTap: () => setState(() {
              _selectedRarity = null;
              _selectedWorkerIds.clear();
              _mergeBarController.reverse();
            }),
          ),
          const SizedBox(width: 8),
          // Rarity tabs (exclude paradox — top tier, can't merge)
          ...WorkerRarity.values.where((r) => r != WorkerRarity.paradox).map((
            rarity,
          ) {
            final count = counts[rarity] ?? 0;
            final rarityColor = _getRarityColor(rarity, colors);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label:
                    '${rarity.localizedName(context).toUpperCase()} ($count)',
                isActive: _selectedRarity == rarity,
                color: rarityColor,
                typography: typography,
                onTap: () => setState(() {
                  _selectedRarity = rarity;
                  _selectedWorkerIds.clear();
                  _mergeBarController.reverse();
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required Color color,
    required ThemeTypography typography,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
            width: isActive ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: typography.bodySmall.copyWith(
            color: isActive ? color : color.withOpacity(0.6),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildMergeActionBar(ThemeColors colors, ThemeTypography typography) {
    final gameState = ref.watch(gameStateProvider);
    Worker? firstSelected;
    if (_selectedWorkerIds.isNotEmpty) {
      firstSelected = gameState.workers[_selectedWorkerIds.first];
    }
    final rarityColor = firstSelected != null
        ? _getRarityColor(firstSelected.rarity, colors)
        : colors.primary;
    final nextRarity = firstSelected != null
        ? _getNextRarityName(firstSelected.rarity)
        : '???';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: rarityColor.withOpacity(0.5), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selection indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final filled = i < _selectedWorkerIds.length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? rarityColor : Colors.transparent,
                    border: Border.all(
                      color: rarityColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedWorkerIds.length}/3 selected → $nextRarity',
            style: typography.bodySmall.copyWith(
              color: colors.textSecondary,
              fontSize: 11,
            ),
          ),
          // Fit to Era Button (Single Legacy Worker)
          if (_selectedWorkerIds.length == 1 &&
              gameState.workers[_selectedWorkerIds.first]?.era.id !=
                  gameState.currentEraId)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TimeFactoryColors.voltageYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final worker = gameState.workers[_selectedWorkerIds.first];
                    if (worker != null) {
                      showDialog(
                        context: context,
                        builder: (_) => FitWorkerDialog(worker: worker),
                      ).then(
                        (_) => setState(() {
                          _selectedWorkerIds
                              .clear(); // Clear selection after action
                          _mergeBarController.reverse();
                        }),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(AppHugeIcons.upgrade, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'FIT TO ERA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),
          // Merge Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedWorkerIds.length >= 3
                    ? rarityColor
                    : rarityColor.withOpacity(0.3),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _selectedWorkerIds.length >= 3 ? 8 : 0,
                shadowColor: rarityColor.withOpacity(0.5),
              ),
              onPressed: _selectedWorkerIds.length >= 3 ? _performMerge : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIcon(AppHugeIcons.merge_type, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.merge.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextRarityName(WorkerRarity rarity) {
    switch (rarity) {
      case WorkerRarity.common:
        return WorkerRarity.rare.displayName;
      case WorkerRarity.rare:
        return WorkerRarity.epic.displayName;
      case WorkerRarity.epic:
        return WorkerRarity.legendary.displayName;
      case WorkerRarity.legendary:
        return WorkerRarity.paradox.displayName;
      case WorkerRarity.paradox:
        return 'MAX';
    }
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
