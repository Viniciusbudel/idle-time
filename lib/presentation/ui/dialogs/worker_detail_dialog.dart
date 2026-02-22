import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/presentation/ui/atoms/cyber_button.dart';
import 'package:time_factory/presentation/ui/dialogs/artifact_inventory_dialog.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class WorkerDetailDialog extends ConsumerStatefulWidget {
  final Worker worker;

  const WorkerDetailDialog({super.key, required this.worker});

  static Future<void> show(BuildContext context, Worker worker) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WorkerDetailDialog(worker: worker),
    );
  }

  @override
  ConsumerState<WorkerDetailDialog> createState() => _WorkerDetailDialogState();
}

class _WorkerDetailDialogState extends ConsumerState<WorkerDetailDialog> {
  /// Index of the slot that is currently flashing green after equip
  int? _flashingSlotIndex;

  void _triggerEquipFlash(int slotIndex) {
    setState(() => _flashingSlotIndex = slotIndex);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _flashingSlotIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final currentWorker = gameState.workers[widget.worker.id] ?? widget.worker;
    final rarityColor = currentWorker.rarity.color;

    // inventoryLength observed for reactivity

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1520),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: rarityColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── TOP ACCENT LINE ───────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      rarityColor.withOpacity(0.0),
                      rarityColor.withOpacity(0.8),
                      rarityColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
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

              // Header / ID
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${currentWorker.id.substring(0, 10)}...',
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
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

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar Section
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rarityColor.withOpacity(0.1),
                            border: Border.all(
                              color: rarityColor.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: rarityColor.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: WorkerIconHelper.buildIcon(
                                currentWorker.era,
                                currentWorker.rarity,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Name and Tags
                      Text(
                        currentWorker.displayName.toUpperCase(),
                        style: TimeFactoryTextStyles.header.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTag(
                            currentWorker.rarity
                                .localizedName(context)
                                .toUpperCase(),
                            currentWorker.rarity.color,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildTag(
                            currentWorker.era
                                .localizedName(context)
                                .toUpperCase(),
                            TimeFactoryColors.voltageYellow,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildTag(
                            currentWorker.isDeployed ? 'DEPLOYED' : 'IDLE',
                            currentWorker.isDeployed
                                ? TimeFactoryColors.electricCyan
                                : Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Stats Area
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(
                              'Total Production',
                              '${NumberFormatter.format(currentWorker.currentProduction)}/s',
                              TimeFactoryColors.acidGreen,
                              icon: AppHugeIcons.bolt,
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            _buildStatRow(
                              'Chronal Attunement',
                              '${(currentWorker.chronalAttunement * 100).toStringAsFixed(0)}%',
                              currentWorker.chronalAttunement >= 1.0
                                  ? TimeFactoryColors.electricCyan
                                  : Colors.orangeAccent,
                              icon: AppHugeIcons.auto_awesome_motion,
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            _buildStatRow(
                              'Base Power',
                              NumberFormatter.formatCompactDouble(
                                currentWorker.totalBasePower,
                              ),
                              Colors.white70,
                              icon: AppHugeIcons.flash_on,
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            _buildStatRow(
                              'Total Multiplier',
                              '${currentWorker.totalMultiplier.toStringAsFixed(2)}x',
                              TimeFactoryColors.voltageYellow,
                              icon: AppHugeIcons.trending_up,
                            ),
                            if (currentWorker.maxArtifactSlots > 0 ||
                                currentWorker.equippedArtifacts.isNotEmpty) ...[
                              const Divider(color: Colors.white12, height: 24),
                              _buildStatRow(
                                'Artifact Slots',
                                '${currentWorker.equippedArtifacts.length} / ${currentWorker.maxArtifactSlots}',
                                currentWorker.equippedArtifacts.length >=
                                        currentWorker.maxArtifactSlots
                                    ? TimeFactoryColors.hotMagenta
                                    : TimeFactoryColors.voltageYellow,
                                icon: AppHugeIcons.auto_awesome,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      _buildArtifactsSection(context, currentWorker),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),

              // ── FIXED ACTION BAR ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B22),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CyberButton(
                        label: currentWorker.isDeployed
                            ? AppLocalizations.of(context)!.unassign
                            : AppLocalizations.of(context)!.manage,
                        icon: currentWorker.isDeployed
                            ? AppHugeIcons.logout
                            : AppHugeIcons.settings,
                        primaryColor: currentWorker.isDeployed
                            ? TimeFactoryColors.voltageYellow
                            : TimeFactoryColors.electricCyan,
                        onTap: () {
                          if (currentWorker.isDeployed &&
                              currentWorker.deployedStationId != null) {
                            ref
                                .read(gameStateProvider.notifier)
                                .removeWorkerFromStation(
                                  currentWorker.id,
                                  currentWorker.deployedStationId!,
                                );
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TimeFactoryTextStyles.bodyMono.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color valueColor, {
    AppIconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          AppIcon(icon, size: 16, color: Colors.white24),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: TimeFactoryTextStyles.body.copyWith(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TimeFactoryTextStyles.numbers.copyWith(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildArtifactsSection(BuildContext context, Worker worker) {
    if (worker.maxArtifactSlots == 0 && worker.equippedArtifacts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TEMPORAL ARTIFACTS',
                style: TimeFactoryTextStyles.header.copyWith(
                  color: TimeFactoryColors.electricCyan,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '0/0 EQUIP',
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              'COMMON WORKERS CANNOT EQUIP ARTIFACTS',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: Colors.white54,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    final slotsCount = worker.maxArtifactSlots > worker.equippedArtifacts.length
        ? worker.maxArtifactSlots
        : worker.equippedArtifacts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TEMPORAL ARTIFACTS',
              style: TimeFactoryTextStyles.header.copyWith(
                color: TimeFactoryColors.electricCyan,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${worker.equippedArtifacts.length}/${worker.maxArtifactSlots} EQUIP',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: slotsCount,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index < worker.equippedArtifacts.length) {
                return _buildFilledSlot(
                  context,
                  worker,
                  worker.equippedArtifacts[index],
                  index,
                );
              } else {
                return _buildEmptySlot(context, worker, index);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlot(BuildContext context, Worker worker, int index) {
    return GestureDetector(
      onTap: () async {
        await ArtifactInventoryDialog.show(context, worker.id);
        // After returning, check if the slot at this index is now filled
        if (mounted) {
          final updatedWorker = ref.read(gameStateProvider).workers[worker.id];
          if (updatedWorker != null &&
              updatedWorker.equippedArtifacts.length > index) {
            _triggerEquipFlash(index);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        decoration: BoxDecoration(
          color: _flashingSlotIndex == index
              ? TimeFactoryColors.acidGreen.withOpacity(0.3)
              : Colors.black12,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _flashingSlotIndex == index
                ? TimeFactoryColors.acidGreen
                : TimeFactoryColors.electricCyan.withOpacity(0.3),
            width: _flashingSlotIndex == index ? 2 : 1,
          ),
          boxShadow: _flashingSlotIndex == index
              ? [
                  BoxShadow(
                    color: TimeFactoryColors.acidGreen.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AppIcon(
            _flashingSlotIndex == index ? AppHugeIcons.check : AppHugeIcons.add,
            color: _flashingSlotIndex == index
                ? TimeFactoryColors.acidGreen
                : TimeFactoryColors.electricCyan,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFilledSlot(
    BuildContext context,
    Worker worker,
    WorkerArtifact artifact,
    int index,
  ) {
    final rarityColor = artifact.rarity.color;
    final isFlashing = _flashingSlotIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: TimeFactoryColors.voidBlack,
            title: Text(
              'UNEQUIP ARTIFACT?',
              style: TimeFactoryTextStyles.header.copyWith(color: Colors.white),
            ),
            content: Text(
              'Remove ${artifact.name} from ${worker.displayName}?\nIt will be returned to your inventory.',
              style: TimeFactoryTextStyles.body.copyWith(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(gameStateProvider.notifier)
                      .unequipArtifact(worker.id, artifact.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'UNEQUIP',
                  style: TextStyle(color: TimeFactoryColors.electricCyan),
                ),
              ),
            ],
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        decoration: BoxDecoration(
          color: isFlashing
              ? TimeFactoryColors.acidGreen.withOpacity(0.3)
              : rarityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFlashing ? TimeFactoryColors.acidGreen : rarityColor,
            width: isFlashing ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFlashing
                  ? TimeFactoryColors.acidGreen.withOpacity(0.5)
                  : rarityColor.withOpacity(0.2),
              blurRadius: isFlashing ? 16 : 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              _rarityIcon(artifact.rarity),
              color: isFlashing ? TimeFactoryColors.acidGreen : rarityColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              artifact.rarity.displayName.substring(0, 3).toUpperCase(),
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
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
