import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/core/ui/app_icons.dart';

/// Filter states for the artifact inventory
enum _RarityFilter { all, common, rare, epic, legendary, paradox }

class ArtifactInventoryDialog extends ConsumerStatefulWidget {
  final String workerId;

  const ArtifactInventoryDialog({super.key, required this.workerId});

  static Future<void> show(BuildContext context, String workerId) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ArtifactInventoryDialog(workerId: workerId),
    );
  }

  @override
  ConsumerState<ArtifactInventoryDialog> createState() =>
      _ArtifactInventoryDialogState();
}

class _ArtifactInventoryDialogState
    extends ConsumerState<ArtifactInventoryDialog> {
  String _searchQuery = '';
  _RarityFilter _activeFilter = _RarityFilter.all;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final worker = gameState.workers[widget.workerId];

    if (worker == null) return const SizedBox.shrink();

    final isFull = worker.equippedArtifacts.length >= worker.maxArtifactSlots;

    final inventory = gameState.inventory.where((artifact) {
      // Rarity filter
      final matchesRarity =
          _activeFilter == _RarityFilter.all ||
          _rarityFromFilter(_activeFilter) == artifact.rarity;
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          artifact.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesRarity && matchesSearch;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1520),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: TimeFactoryColors.electricCyan.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARTIFACT INVENTORY',
                      style: TimeFactoryTextStyles.header.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${gameState.inventory.length}/100 SLOTS',
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const AppIcon(
                    AppHugeIcons.close,
                    color: Colors.white54,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── SLOT-FULL WARNING ─────────────────────────────────────────
          if (isFull)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.6)),
                ),
                child: Row(
                  children: [
                    const AppIcon(
                      AppHugeIcons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ALL ${worker.maxArtifactSlots} SLOTS FILLED — Unequip an artifact first.',
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (isFull) const SizedBox(height: AppSpacing.sm),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TimeFactoryTextStyles.body.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'SEARCH ARTIFACTS...',
                hintStyle: TimeFactoryTextStyles.bodyMono.copyWith(
                  color: Colors.white24,
                  fontSize: 12,
                ),
                prefixIcon: const AppIcon(
                  AppHugeIcons.search,
                  color: TimeFactoryColors.electricCyan,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: TimeFactoryColors.electricCyan,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── RARITY FILTER CHIPS ──────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: _RarityFilter.values.map((filter) {
                final isSelected = _activeFilter == filter;
                final chipColor = _filterColor(filter);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? chipColor.withOpacity(0.25)
                            : Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? chipColor : Colors.white24,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _filterLabel(filter),
                        style: TimeFactoryTextStyles.bodyMono.copyWith(
                          fontSize: 11,
                          color: isSelected ? chipColor : Colors.white54,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(color: Colors.white12, height: 1),

          // ── INVENTORY GRID ────────────────────────────────────────────
          Flexible(
            child: inventory.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final artifact = inventory[index];
                      return _buildArtifactCard(
                        context,
                        artifact,
                        worker.equippedArtifacts.length,
                        isFull,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            AppHugeIcons.inventory_2_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'INVENTORY EMPTY',
            style: TimeFactoryTextStyles.header.copyWith(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _activeFilter == _RarityFilter.all
                ? 'Find artifacts from Temporal Anomalies.'
                : 'No ${_filterLabel(_activeFilter)} artifacts in inventory.',
            style: TimeFactoryTextStyles.body.copyWith(color: Colors.white38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactCard(
    BuildContext context,
    WorkerArtifact artifact,
    int equippedCount,
    bool isFull,
  ) {
    final rarityColor = artifact.rarity.color;
    final isEquippable = !isFull;

    return GestureDetector(
      // ── SHORT TAP: equip ────────────────────────────────────────────
      onTap: isEquippable
          ? () {
              HapticFeedback.lightImpact();
              ref
                  .read(gameStateProvider.notifier)
                  .equipArtifact(widget.workerId, artifact.id);
              Navigator.pop(context);
            }
          : null,
      // ── LONG PRESS: stat tooltip ────────────────────────────────────
      onLongPress: () {
        HapticFeedback.selectionClick();
        _showStatTooltip(context, artifact);
      },
      child: Container(
        decoration: BoxDecoration(
          color: rarityColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rarityColor.withOpacity(isFull ? 0.15 : 0.3),
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Icon area
                Expanded(
                  flex: 3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AppIcon(
                        _rarityIcon(artifact.rarity),
                        color: rarityColor.withValues(
                          alpha: isFull ? 0.4 : 1.0,
                        ),
                        size: 32,
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: AppIcon(
                            AppHugeIcons.touch_app_outlined,
                            color: rarityColor.withOpacity(0.7),
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info area
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(11),
                      ),
                      border: Border(
                        top: BorderSide(color: rarityColor.withOpacity(0.3)),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          artifact.name,
                          style: TimeFactoryTextStyles.bodyMono.copyWith(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Equip button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isEquippable
                                ? TimeFactoryColors.electricCyan.withValues(
                                    alpha: 0.2,
                                  )
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isEquippable
                                  ? TimeFactoryColors.electricCyan
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            isFull ? 'FULL' : 'EQUIP',
                            style: TimeFactoryTextStyles.bodyMono.copyWith(
                              fontSize: 9,
                              color: isEquippable
                                  ? TimeFactoryColors.electricCyan
                                  : Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Dimming overlay when full
            if (isFull)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── STAT TOOLTIP ──────────────────────────────────────────────────────
  void _showStatTooltip(BuildContext context, WorkerArtifact artifact) {
    final rarityColor = artifact.rarity.color;
    final hasProdBonus = artifact.productionMultiplier > 0;
    final hasEraMatch = artifact.eraMatch != null;
    final baseBonus = artifact.basePowerBonus;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1520),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: rarityColor.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(color: rarityColor.withOpacity(0.2), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  AppIcon(
                    _rarityIcon(artifact.rarity),
                    color: rarityColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artifact.name.toUpperCase(),
                          style: TimeFactoryTextStyles.header.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            artifact.rarity.displayName.toUpperCase(),
                            style: TimeFactoryTextStyles.bodyMono.copyWith(
                              fontSize: 9,
                              color: rarityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const AppIcon(
                      AppHugeIcons.close,
                      color: Colors.white54,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const Divider(color: Colors.white12, height: 20),

              // Stats
              _tooltipStat(
                AppHugeIcons.flash_on,
                'Base Power',
                '+$baseBonus',
                baseBonus > BigInt.zero
                    ? TimeFactoryColors.acidGreen
                    : Colors.white38,
              ),
              const SizedBox(height: 8),
              _tooltipStat(
                AppHugeIcons.trending_up,
                'Production Bonus',
                hasProdBonus
                    ? '+${(artifact.productionMultiplier * 100).toStringAsFixed(0)}%'
                    : 'None',
                hasProdBonus ? TimeFactoryColors.electricCyan : Colors.white38,
              ),
              const SizedBox(height: 8),
              _tooltipStat(
                AppHugeIcons.public,
                'Era Synergy',
                hasEraMatch
                    ? '${artifact.eraMatch!.displayName} (+10% if matched)'
                    : 'None',
                hasEraMatch ? TimeFactoryColors.voltageYellow : Colors.white38,
              ),

              const Divider(color: Colors.white12, height: 20),
              Text(
                'Hold-press to inspect · Tap to equip',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 10,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tooltipStat(
    AppIconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        AppIcon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TimeFactoryTextStyles.body.copyWith(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            fontSize: 12,
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── HELPER METHODS ────────────────────────────────────────────────────

  WorkerRarity? _rarityFromFilter(_RarityFilter f) {
    switch (f) {
      case _RarityFilter.all:
        return null;
      case _RarityFilter.common:
        return WorkerRarity.common;
      case _RarityFilter.rare:
        return WorkerRarity.rare;
      case _RarityFilter.epic:
        return WorkerRarity.epic;
      case _RarityFilter.legendary:
        return WorkerRarity.legendary;
      case _RarityFilter.paradox:
        return WorkerRarity.paradox;
    }
  }

  String _filterLabel(_RarityFilter f) {
    switch (f) {
      case _RarityFilter.all:
        return 'ALL';
      case _RarityFilter.common:
        return '★ COMMON';
      case _RarityFilter.rare:
        return '★★ RARE';
      case _RarityFilter.epic:
        return '★★★ EPIC';
      case _RarityFilter.legendary:
        return '★★★★ LEGENDARY';
      case _RarityFilter.paradox:
        return '✦ PARADOX';
    }
  }

  Color _filterColor(_RarityFilter f) {
    switch (f) {
      case _RarityFilter.all:
        return TimeFactoryColors.electricCyan;
      case _RarityFilter.common:
        return WorkerRarity.common.color;
      case _RarityFilter.rare:
        return WorkerRarity.rare.color;
      case _RarityFilter.epic:
        return WorkerRarity.epic.color;
      case _RarityFilter.legendary:
        return WorkerRarity.legendary.color;
      case _RarityFilter.paradox:
        return WorkerRarity.paradox.color;
    }
  }

  AppIconData _rarityIcon(WorkerRarity rarity) {
    switch (rarity) {
      case WorkerRarity.common:
        return AppHugeIcons.settings;
      case WorkerRarity.rare:
        return AppHugeIcons.electric_bolt;
      case WorkerRarity.epic:
        return AppHugeIcons.auto_fix_high;
      case WorkerRarity.legendary:
        return AppHugeIcons.diamond_outlined;
      case WorkerRarity.paradox:
        return AppHugeIcons.blur_circular;
    }
  }
}
