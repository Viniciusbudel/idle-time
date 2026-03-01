import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/core/utils/expedition_utils.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/presentation/ui/atoms/hud_segmented_progress_bar.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/usecases/claim_expedition_rewards_usecase.dart';
import 'package:time_factory/domain/usecases/resolve_expeditions_usecase.dart';
import 'package:time_factory/domain/usecases/start_expedition_usecase.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/dialogs/expedition_reward_dialog.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';

class ExpeditionsScreen extends ConsumerStatefulWidget {
  const ExpeditionsScreen({super.key});

  @override
  ConsumerState<ExpeditionsScreen> createState() => _ExpeditionsScreenState();
}

enum _ExpeditionPanel { missions, active, completed }

class _ExpeditionsScreenState extends ConsumerState<ExpeditionsScreen> {
  final Map<String, ExpeditionRisk> _selectedRiskBySlotId =
      <String, ExpeditionRisk>{};
  final Map<String, List<String>> _selectedWorkerIdsBySlotId =
      <String, List<String>>{};
  final ResolveExpeditionsUseCase _resolveExpeditionsUseCase =
      ResolveExpeditionsUseCase();
  _ExpeditionPanel _activePanel = _ExpeditionPanel.missions;
  String? _expandedSlotId;
  bool _hasAutoExpanded = false;

  @override
  Widget build(BuildContext context) {
    final GameState gameState = ref.watch(gameStateProvider);
    final List<ExpeditionSlot> slots = ref.watch(expeditionSlotsProvider);
    final List<Expedition> expeditions = ref.watch(expeditionsProvider);
    final List<Expedition> activeExpeditions =
        expeditions.where((expedition) => !expedition.resolved).toList()
          ..sort((a, b) => a.endTime.compareTo(b.endTime));

    final List<Expedition> completedExpeditions =
        expeditions.where((expedition) => expedition.resolved).toList()
          ..sort((a, b) => b.endTime.compareTo(a.endTime));

    final List<Worker> availableWorkers = _availableWorkers(gameState);

    const theme = NeonTheme();
    final colors = theme.colors;
    final typography = theme.typography;

    return Scaffold(
      backgroundColor: TimeFactoryColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: AppIcon(
            AppHugeIcons.arrow_back,
            color: colors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          // 1. System HUD Header
          _OpsHudHeader(
            colors: colors,
            typography: typography,
            idleCount: availableWorkers.length,
            activeCount: activeExpeditions.length,
            completedCount: completedExpeditions.length,
          ),

          // 2. Mission Filter — system-mode selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            child: _buildModeSelector(
              colors,
              typography,
              activeCount: activeExpeditions.length,
              completedCount: completedExpeditions.length,
            ),
          ),

          // 3. Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: <Widget>[
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: _buildPanelBody(
                    key: ValueKey<_ExpeditionPanel>(_activePanel),
                    context: context,
                    gameState: gameState,
                    slots: slots,
                    availableWorkers: availableWorkers,
                    activeExpeditions: activeExpeditions,
                    completedExpeditions: completedExpeditions,
                  ),
                ),
                const SizedBox(height: AppSpacing.bottomSafe + AppSpacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelBody({
    required Key key,
    required BuildContext context,
    required GameState gameState,
    required List<ExpeditionSlot> slots,
    required List<Worker> availableWorkers,
    required List<Expedition> activeExpeditions,
    required List<Expedition> completedExpeditions,
  }) {
    switch (_activePanel) {
      case _ExpeditionPanel.missions:
        // Auto-expand first card if user has idle workers
        if (!_hasAutoExpanded &&
            slots.isNotEmpty &&
            availableWorkers.isNotEmpty &&
            _expandedSlotId == null) {
          _hasAutoExpanded = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _expandedSlotId = slots.first.id);
            }
          });
        }
        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionTitle(
              AppLocalizations.of(context)!.availableMissions(slots.length),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...slots.map(
              (ExpeditionSlot slot) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildSlotCard(
                  context,
                  gameState,
                  availableWorkers,
                  slot,
                ),
              ),
            ),
          ],
        );
      case _ExpeditionPanel.active:
        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionTitle(
              AppLocalizations.of(
                context,
              )!.activeExpeditions(activeExpeditions.length),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (activeExpeditions.isEmpty)
              _EmptyBlock(AppLocalizations.of(context)!.noActiveExpeditions)
            else
              ...activeExpeditions.map(
                (Expedition expedition) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _TickingBuilder(
                    builder: (DateTime now) =>
                        _buildActiveCard(gameState, expedition, now),
                  ),
                ),
              ),
          ],
        );
      case _ExpeditionPanel.completed:
        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCompletedHeader(context, completedExpeditions),
            const SizedBox(height: AppSpacing.sm),
            if (completedExpeditions.isEmpty)
              _EmptyBlock(AppLocalizations.of(context)!.noRewardsWaiting)
            else
              ...completedExpeditions.map(
                (Expedition expedition) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildCompletedCard(context, expedition),
                ),
              ),
          ],
        );
    }
  }

  /// System-mode selector — crisp, technical, no toggle appearance
  Widget _buildModeSelector(
    ThemeColors colors,
    ThemeTypography typography, {
    required int activeCount,
    required int completedCount,
  }) {
    return Row(
      children: <Widget>[
        _buildModeButton(
          panel: _ExpeditionPanel.missions,
          label: 'AVAILABLE',
          badge: null,
          colors: colors,
          typography: typography,
        ),
        const SizedBox(width: 6),
        _buildModeButton(
          panel: _ExpeditionPanel.active,
          label: 'ACTIVE',
          badge: activeCount > 0 ? activeCount : null,
          colors: colors,
          typography: typography,
        ),
        const SizedBox(width: 6),
        _buildModeButton(
          panel: _ExpeditionPanel.completed,
          label: 'COMPLETED',
          badge: completedCount > 0 ? completedCount : null,
          colors: colors,
          typography: typography,
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required _ExpeditionPanel panel,
    required String label,
    required int? badge,
    required ThemeColors colors,
    required ThemeTypography typography,
  }) {
    final bool selected = _activePanel == panel;
    final Color activeColor = colors.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activePanel = panel),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected
                  ? activeColor.withValues(alpha: 0.50)
                  : colors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: typography.bodyMedium.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? activeColor
                          : Colors.white.withValues(alpha: 0.45),
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '$badge',
                        style: typography.bodyMedium.copyWith(
                          fontSize: 8,
                          color: activeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              // Underline glow indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: selected ? 24 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.50),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kept for compatibility — now unused, header moved to _OpsHudHeader

  Widget _buildMissionIdentityChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TimeFactoryTextStyles.bodyMono.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSlotCard(
    BuildContext context,
    GameState gameState,
    List<Worker> availableWorkers,
    ExpeditionSlot slot,
  ) {
    final bool slotHasActiveRun = gameState.expeditions.any(
      (Expedition expedition) =>
          !expedition.resolved && expedition.slotId == slot.id,
    );
    final ExpeditionRisk selectedRisk =
        _selectedRiskBySlotId[slot.id] ?? slot.defaultRisk;
    final EraTheme eraTheme = EraTheme.fromId(slot.eraId);
    final Color eraAccent = eraTheme.primaryColor;
    final Color riskAccent = expeditionRiskColor(selectedRisk);
    final Color combinedAccent =
        Color.lerp(eraAccent, riskAccent, 0.45) ?? riskAccent;

    final bool hasRequiredCrew =
        availableWorkers.length >= slot.requiredWorkers;
    final bool canConfigureSlot = !slotHasActiveRun;
    final bool canStart = hasRequiredCrew && canConfigureSlot;
    final bool shouldShowQuickHire = !hasRequiredCrew && canConfigureSlot;
    final bool isExpanded = _expandedSlotId == slot.id;
    final List<Worker> selectedWorkers = _selectedWorkersForSlot(
      slot.id,
      availableWorkers,
      slot.requiredWorkers,
    );
    final List<Worker> previewWorkers = _previewWorkersForSlot(
      selectedWorkers: selectedWorkers,
      availableWorkers: availableWorkers,
      requiredCount: slot.requiredWorkers,
    );
    final ExpeditionReward? previewReward = _estimateSlotRewardPreview(
      gameState: gameState,
      previewWorkers: previewWorkers,
      requiredWorkers: slot.requiredWorkers,
      duration: slot.duration,
      risk: selectedRisk,
      slotEraId: slot.eraId,
    );
    final double successChance =
        StartExpeditionUseCase.calculateSuccessProbability(
          risk: selectedRisk,
          assignedWorkers: selectedWorkers,
          requiredWorkers: slot.requiredWorkers,
        );

    void autoAssembleCrew() {
      final List<String>? autoSelected = ref
          .read(gameStateProvider.notifier)
          .autoAssembleCrewForExpedition(slot.id);
      if (autoSelected == null) {
        return;
      }
      setState(() {
        _selectedWorkerIdsBySlotId[slot.id] = autoSelected;
      });
    }

    void quickHireCrew() {
      final QuickHireExpeditionCrewResult? hireResult = ref
          .read(gameStateProvider.notifier)
          .quickHireForExpeditionCrew(slot.id);
      if (hireResult == null) {
        return;
      }
      setState(() {
        _selectedWorkerIdsBySlotId[slot.id] = hireResult.crewWorkerIds;
      });

      final String message = hireResult.hiredWorkers > 0
          ? '${AppLocalizations.of(context)!.hireSuccessful} (+${hireResult.hiredWorkers})'
          : AppLocalizations.of(context)!.insufficientCE;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> openWorkerPicker() async {
      final List<String>? pickedWorkerIds = await _pickWorkersForSlot(
        context,
        availableWorkers,
        slot.requiredWorkers,
        initialSelectedIds: selectedWorkers
            .map((Worker worker) => worker.id)
            .toList(),
      );
      if (!mounted || pickedWorkerIds == null) {
        return;
      }
      setState(() {
        _selectedWorkerIdsBySlotId[slot.id] = pickedWorkerIds;
      });
    }

    final t = const NeonTheme().typography;
    final c = const NeonTheme().colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF03070C),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: combinedAccent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header: Mission Name + Class
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(
                AppHugeIcons.rocket_launch,
                color: combinedAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.name.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        _buildMissionIdentityChip(
                          label:
                              (slot.eraId == 'victorian'
                                      ? 'Steampunk Era'
                                      : slot.eraId.replaceAll('_', ' '))
                                  .toUpperCase(),
                          color: eraAccent,
                        ),
                        _buildMissionIdentityChip(
                          label: slot.layoutPreset
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          color: eraTheme.secondaryColor,
                        ),
                        if (slotHasActiveRun)
                          _buildMissionIdentityChip(
                            label: 'ACTIVE RUN',
                            color: TimeFactoryColors.voltageYellow,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  setState(() {
                    _expandedSlotId = isExpanded ? null : slot.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: c.primary.withValues(alpha: 0.2)),
                  ),
                  child: AppIcon(
                    isExpanded
                        ? AppHugeIcons.keyboard_arrow_down
                        : AppHugeIcons.chevron_right,
                    size: 16,
                    color: c.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: c.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 12),

          // Metrics: Duration + Expected Yield
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DURATION',
                    style: t.bodyMedium.copyWith(
                      fontSize: 8,
                      color: c.primary.withValues(alpha: 0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcon(
                        AppHugeIcons.access_time,
                        size: 12,
                        color: c.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(context, slot.duration),
                        style: t.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPECTED YIELD',
                    style: t.bodyMedium.copyWith(
                      fontSize: 8,
                      color: c.primary.withValues(alpha: 0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        previewReward == null
                            ? '---'
                            : NumberFormatter.formatCE(
                                previewReward.chronoEnergy,
                              ),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          color: TimeFactoryColors.electricCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AppIcon(
                        AppHugeIcons.factory,
                        size: 12,
                        color: TimeFactoryColors.electricCyan,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Segmented Progress Bars (Yield & Risk)
          Row(
            children: [
              Expanded(
                flex: 6,
                child: HudSegmentedProgressBar(
                  value: 0.7, // Visual placeholder for yield capacity
                  color: TimeFactoryColors.electricCyan,
                  height: 4,
                  segmentCount: 12,
                  segmentGap: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: HudSegmentedProgressBar(
                  value: 1.0 - successChance,
                  color: expeditionRiskColor(selectedRisk),
                  height: 4,
                  segmentCount: 6,
                  segmentGap: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YIELD PROJECTION',
                style: t.bodyMedium.copyWith(
                  fontSize: 8,
                  color: c.primary.withValues(alpha: 0.3),
                ),
              ),
              Text(
                'RISK: ${100 - (successChance * 100).round()}%',
                style: t.bodyMedium.copyWith(
                  fontSize: 8,
                  color: expeditionRiskColor(selectedRisk),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Crew Sockets Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CREW REQUIRED: ${slot.requiredWorkers}',
                style: t.bodyMedium.copyWith(
                  fontSize: 9,
                  color: c.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'IDLE: ${availableWorkers.length}',
                style: t.bodyMedium.copyWith(
                  fontSize: 9,
                  color: availableWorkers.isNotEmpty
                      ? TimeFactoryColors.acidGreen
                      : Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Sockets list
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(slot.requiredWorkers, (int index) {
              if (index < selectedWorkers.length) {
                return _buildWorkerSocket(
                  worker: selectedWorkers[index],
                  accentColor: combinedAccent,
                  onTap: canConfigureSlot ? openWorkerPicker : null,
                );
              }
              return _buildAddWorkerSocket(
                accentColor: combinedAccent,
                onTap: canConfigureSlot ? openWorkerPicker : null,
              );
            }),
          ),

          const SizedBox(height: 12),

          // Expanded Area
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(height: 1, color: c.primary.withValues(alpha: 0.1)),
                const SizedBox(height: 12),
                Text(
                  'RISK PROTOCOL OVERRIDE',
                  style: t.bodyMedium.copyWith(
                    fontSize: 9,
                    color: c.primary.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ExpeditionRisk.values.map((ExpeditionRisk risk) {
                    final bool selected = selectedRisk == risk;
                    final _RiskProfile profile = _riskProfilePreview(
                      gameState: gameState,
                      workers: previewWorkers,
                      duration: slot.duration,
                      risk: risk,
                      slotEraId: slot.eraId,
                    );
                    return GestureDetector(
                      onTap: canConfigureSlot
                          ? () {
                              setState(() {
                                _selectedRiskBySlotId[slot.id] = risk;
                              });
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? expeditionRiskColor(
                                  risk,
                                ).withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: selected
                                ? expeditionRiskColor(risk)
                                : c.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.expeditionRiskBadge(
                            _riskLabel(risk),
                            profile.ceMultiplierLabel,
                            profile.timeShards,
                            profile.relicChancePercent,
                          ),
                          style: t.bodyMedium.copyWith(
                            fontSize: 9,
                            color: selected
                                ? expeditionRiskColor(risk)
                                : Colors.white60,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            canConfigureSlot && availableWorkers.isNotEmpty
                            ? autoAssembleCrew
                            : null,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: c.primary.withValues(alpha: 0.3),
                          ),
                          foregroundColor: c.primary.withValues(alpha: 0.9),
                        ),
                        icon: AppIcon(AppHugeIcons.groups, size: 14),
                        label: Text(
                          'AUTO ASSIGN',
                          style: TextStyle(fontSize: 10, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                    if (shouldShowQuickHire) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: quickHireCrew,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: TimeFactoryColors.voltageYellow.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            foregroundColor: TimeFactoryColors.voltageYellow,
                          ),
                          icon: AppIcon(AppHugeIcons.person_add, size: 14),
                          label: Text(
                            'HIRE NOW',
                            style: TextStyle(fontSize: 10, letterSpacing: 1.0),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Main Action Button
          GameActionButton(
            onTap: canStart
                ? () {
                    final List<String> selectedIds = selectedWorkers
                        .map((w) => w.id)
                        .toList();
                    final List<String> launchWorkers =
                        selectedIds.length == slot.requiredWorkers
                        ? selectedIds
                        : _pickStrongestWorkerIds(
                            availableWorkers,
                            slot.requiredWorkers,
                          );
                    _startExpedition(
                      context,
                      slot,
                      selectedRisk,
                      launchWorkers,
                    );
                  }
                : null,
            label: 'DEPLOY MISSION',
            icon: AppHugeIcons.rocket_launch,
            color: canStart
                ? expeditionRiskColor(selectedRisk)
                : Colors.white24,
            enabled: canStart,
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedHeader(
    BuildContext context,
    List<Expedition> completedExpeditions,
  ) {
    final bool hasCompleted = completedExpeditions.isNotEmpty;

    return Row(
      children: <Widget>[
        _SectionTitle(AppLocalizations.of(context)!.completed),
        const Spacer(),
        OutlinedButton(
          onPressed: hasCompleted
              ? () {
                  final List<String> ids = completedExpeditions
                      .map((Expedition e) => e.id)
                      .toList();
                  var claimed = 0;
                  for (final String expeditionId in ids) {
                    final bool ok = ref
                        .read(gameStateProvider.notifier)
                        .claimExpeditionReward(expeditionId);
                    if (ok) {
                      claimed++;
                    }
                  }
                  if (claimed > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.claimedRewardsCount(claimed),
                        ),
                      ),
                    );
                  }
                }
              : null,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: TimeFactoryColors.acidGreen),
            foregroundColor: TimeFactoryColors.acidGreen,
            disabledForegroundColor: Colors.white38,
          ),
          child: Text(AppLocalizations.of(context)!.claimAll),
        ),
      ],
    );
  }

  Widget _buildActiveCard(
    GameState gameState,
    Expedition expedition,
    DateTime now,
  ) {
    final Duration total = expedition.endTime.difference(expedition.startTime);
    final Duration elapsed = now.difference(expedition.startTime);
    final Duration remaining = expedition.endTime.difference(now);

    final int totalMs = total.inMilliseconds <= 0 ? 1 : total.inMilliseconds;
    final int elapsedMs = elapsed.inMilliseconds.clamp(0, totalMs);
    final double progress = elapsedMs / totalMs;
    final int progressPercent = (progress * 100).round();
    final List<Worker> assignedWorkers = expedition.workerIds
        .map((String workerId) => gameState.workers[workerId])
        .whereType<Worker>()
        .toList();

    final c = const NeonTheme().colors;
    final t = const NeonTheme().typography;
    final riskColor = expeditionRiskColor(expedition.risk);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF03070C),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: riskColor.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: riskColor.withValues(alpha: 0.1), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIcon(AppHugeIcons.access_time, size: 14, color: riskColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_slotName(expedition.slotId).toUpperCase()} // ${_riskLabel(expedition.risk).toUpperCase()}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TimeFactoryColors.voltageYellow.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: TimeFactoryColors.voltageYellow.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Text(
                  _formatDuration(context, remaining),
                  style: t.bodyMedium.copyWith(
                    color: TimeFactoryColors.voltageYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: c.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: assignedWorkers
                .map(
                  (Worker worker) => _buildWorkerSocket(
                    worker: worker,
                    accentColor: riskColor,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _ShimmerProgressBar(progress: progress, color: riskColor),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS: $progressPercent%',
                style: t.bodyMedium.copyWith(
                  color: riskColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'SUCCESS CHANCE: ${(expedition.successProbability * 100).round()}%',
                style: t.bodyMedium.copyWith(
                  color: c.primary.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, Expedition expedition) {
    final ExpeditionReward reward =
        expedition.resolvedReward ?? ExpeditionReward.zero;
    final bool failed = expedition.wasSuccessful == false;
    final baseColor = failed ? Colors.redAccent : TimeFactoryColors.acidGreen;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF03070C),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: baseColor.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: baseColor.withValues(alpha: 0.1), blurRadius: 12),
        ],
      ),
      child: Row(
        children: <Widget>[
          AppIcon(
            failed ? AppHugeIcons.warning_amber : AppHugeIcons.check_circle,
            size: 18,
            color: failed ? Colors.redAccent : TimeFactoryColors.acidGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  failed
                      ? AppLocalizations.of(
                          context,
                        )!.expeditionFailedTitle(_slotName(expedition.slotId))
                      : AppLocalizations.of(context)!.expeditionCompletedTitle(
                          _slotName(expedition.slotId),
                          NumberFormatter.formatCE(reward.chronoEnergy),
                          reward.timeShards,
                        ),
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  failed
                      ? AppLocalizations.of(context)!.expeditionFailureLoss(
                          expedition.lostWorkerIds.length,
                          expedition.lostArtifactCount,
                        )
                      : AppLocalizations.of(context)!.artifactRollChance(
                          (reward.artifactDropChance * 100).round(),
                        ),
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: failed ? Colors.redAccent : Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (BuildContext context, double scale, Widget? child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: ElevatedButton(
              onPressed: () =>
                  _claimExpeditionWithPresentation(context, expedition),
              style: ElevatedButton.styleFrom(
                backgroundColor: failed
                    ? Colors.redAccent
                    : TimeFactoryColors.acidGreen,
                foregroundColor: failed ? Colors.white : Colors.black,
              ),
              child: Text(
                failed
                    ? AppLocalizations.of(context)!.ack
                    : AppLocalizations.of(context)!.claim,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startExpedition(
    BuildContext context,
    ExpeditionSlot slot,
    ExpeditionRisk risk,
    List<String> workerIds,
  ) async {
    final bool success = ref
        .read(gameStateProvider.notifier)
        .startExpedition(slotId: slot.id, risk: risk, workerIds: workerIds);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unableStartExpedition),
        ),
      );
      return;
    }

    setState(() {
      _expandedSlotId = null;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const AppIcon(
              AppHugeIcons.rocket_launch,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.expeditionStarted(
                  slot.name,
                  _riskLabel(risk),
                  workerIds.length,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: expeditionRiskColor(risk).withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Brief delay before switching to ACTIVE tab for launch sequence feel
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _activePanel = _ExpeditionPanel.active);
    }
  }

  Future<void> _claimExpeditionWithPresentation(
    BuildContext context,
    Expedition expedition,
  ) async {
    final bool failed = expedition.wasSuccessful == false;
    final ClaimExpeditionRewardsResult? result = ref
        .read(gameStateProvider.notifier)
        .claimExpeditionRewardWithResult(expedition.id);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unableClaimExpedition),
        ),
      );
      return;
    }

    if (failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failureReportAcknowledged,
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => ExpeditionRewardDialog(
        slotName: _slotName(expedition.slotId),
        risk: expedition.risk,
        reward: result.reward,
      ),
    );
  }

  List<Worker> _availableWorkers(GameState gameState) {
    final Set<String> activeExpeditionWorkerIds = <String>{};
    for (final Expedition expedition in gameState.expeditions) {
      if (expedition.resolved) {
        continue;
      }
      activeExpeditionWorkerIds.addAll(expedition.workerIds);
    }

    return gameState.workers.values
        .where(
          (Worker worker) => !activeExpeditionWorkerIds.contains(worker.id),
        )
        .toList();
  }

  List<Worker> _selectedWorkersForSlot(
    String slotId,
    List<Worker> availableWorkers,
    int requiredCount,
  ) {
    final Map<String, Worker> availableById = <String, Worker>{
      for (final Worker worker in availableWorkers) worker.id: worker,
    };

    final List<String> configured =
        _selectedWorkerIdsBySlotId[slotId] ?? <String>[];
    final List<Worker> selected = <Worker>[];
    for (final String workerId in configured) {
      final Worker? worker = availableById[workerId];
      if (worker == null) {
        continue;
      }
      selected.add(worker);
      if (selected.length >= requiredCount) {
        break;
      }
    }
    return selected;
  }

  Widget _buildWorkerSocket({
    required Worker worker,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    final Widget socket = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: WorkerIconHelper.buildIcon(
          worker.era,
          worker.rarity,
          fit: BoxFit.contain,
        ),
      ),
    );
    if (onTap == null) {
      return socket;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: socket,
    );
  }

  Widget _buildAddWorkerSocket({
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    final Widget socket = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.55)),
      ),
      child: Center(
        child: AppIcon(
          AppHugeIcons.add,
          size: 18,
          color: accentColor.withValues(alpha: 0.85),
        ),
      ),
    );
    if (onTap == null) {
      return socket;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: socket,
    );
  }

  List<String> _pickStrongestWorkerIds(
    List<Worker> workers,
    int requiredCount,
  ) {
    final List<Worker> sorted = List<Worker>.from(workers)
      ..sort((a, b) => b.currentProduction.compareTo(a.currentProduction));
    return sorted.take(requiredCount).map((Worker w) => w.id).toList();
  }

  List<Worker> _previewWorkersForSlot({
    required List<Worker> selectedWorkers,
    required List<Worker> availableWorkers,
    required int requiredCount,
  }) {
    final List<Worker> preview = List<Worker>.from(selectedWorkers);
    if (preview.length >= requiredCount) {
      return preview.take(requiredCount).toList(growable: false);
    }

    final Set<String> selectedIds = preview
        .map((Worker worker) => worker.id)
        .toSet();
    final List<Worker> sorted = List<Worker>.from(availableWorkers)
      ..sort((a, b) => b.currentProduction.compareTo(a.currentProduction));
    for (final Worker worker in sorted) {
      if (preview.length >= requiredCount) {
        break;
      }
      if (selectedIds.add(worker.id)) {
        preview.add(worker);
      }
    }

    return preview;
  }

  ExpeditionReward? _estimateSlotRewardPreview({
    required GameState gameState,
    required List<Worker> previewWorkers,
    required int requiredWorkers,
    required Duration duration,
    required ExpeditionRisk risk,
    required String slotEraId,
  }) {
    if (previewWorkers.length < requiredWorkers) {
      return null;
    }

    return _resolveExpeditionsUseCase.estimateRewardPreview(
      gameState,
      workers: previewWorkers.take(requiredWorkers).toList(growable: false),
      duration: duration,
      risk: risk,
      succeeded: true,
      eraId: slotEraId,
    );
  }

  _RiskProfile _riskProfilePreview({
    required GameState gameState,
    required List<Worker> workers,
    required Duration duration,
    required ExpeditionRisk risk,
    String? slotEraId,
  }) {
    final ExpeditionReward reward = _resolveExpeditionsUseCase
        .estimateRewardPreview(
          gameState,
          workers: workers,
          duration: duration,
          risk: risk,
          succeeded: true,
          eraId: slotEraId,
        );

    final int safeDurationSeconds = duration.inSeconds.clamp(1, 60 * 60 * 24);
    BigInt totalWorkerPower = BigInt.zero;
    for (final Worker worker in workers) {
      totalWorkerPower += worker.currentProduction;
    }
    final BigInt baseUnits =
        totalWorkerPower * BigInt.from(safeDurationSeconds);

    String ceMultiplierLabel = '0.0';
    if (baseUnits > BigInt.zero) {
      final BigInt scaled10 =
          reward.chronoEnergy * BigInt.from(10) ~/ baseUnits;
      final BigInt whole = scaled10 ~/ BigInt.from(10);
      final BigInt tenth = scaled10.remainder(BigInt.from(10));
      ceMultiplierLabel = '$whole.$tenth';
    }

    return _RiskProfile(
      ceMultiplierLabel: ceMultiplierLabel,
      timeShards: reward.timeShards,
      relicChancePercent: (reward.artifactDropChance * 100).round(),
    );
  }

  String _riskLabel(ExpeditionRisk risk) {
    switch (risk) {
      case ExpeditionRisk.safe:
        return 'SAFE';
      case ExpeditionRisk.risky:
        return 'RISK';
      case ExpeditionRisk.volatile:
        return 'VOLATILE';
    }
  }

  Future<List<String>?> _pickWorkersForSlot(
    BuildContext context,
    List<Worker> candidates,
    int requiredCount, {
    List<String> initialSelectedIds = const <String>[],
  }) async {
    if (candidates.length < requiredCount) {
      return null;
    }

    final Set<String> selectedIds = initialSelectedIds.toSet();
    final List<Worker> sortedCandidates = List<Worker>.from(candidates)
      ..sort((a, b) => b.currentProduction.compareTo(a.currentProduction));
    final Set<String> candidateIds = sortedCandidates
        .map((Worker worker) => worker.id)
        .toSet();
    selectedIds.removeWhere(
      (String workerId) => !candidateIds.contains(workerId),
    );
    if (selectedIds.length > requiredCount) {
      final List<String> trimmed = selectedIds.take(requiredCount).toList();
      selectedIds
        ..clear()
        ..addAll(trimmed);
    }

    return showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setLocalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.72,
              ),
              decoration: BoxDecoration(
                color: TimeFactoryColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border.all(
                  color: TimeFactoryColors.electricCyan.withValues(alpha: 0.3),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
                      child: Row(
                        children: <Widget>[
                          const AppIcon(
                            AppHugeIcons.person_add,
                            color: TimeFactoryColors.electricCyan,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.selectWorkers(requiredCount),
                                  style: TimeFactoryTextStyles.bodyMono
                                      .copyWith(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.selectedWorkers(
                                    selectedIds.length,
                                    requiredCount,
                                  ),
                                  style: TimeFactoryTextStyles.bodyMono
                                      .copyWith(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setLocalState(() {
                                selectedIds
                                  ..clear()
                                  ..addAll(
                                    _pickStrongestWorkerIds(
                                      sortedCandidates,
                                      requiredCount,
                                    ),
                                  );
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.auto),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const AppIcon(
                              AppHugeIcons.close,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: Colors.white12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        itemCount: sortedCandidates.length,
                        itemBuilder: (BuildContext _, int index) {
                          final Worker worker = sortedCandidates[index];
                          final bool selected = selectedIds.contains(worker.id);
                          final bool canToggleOn =
                              selected || selectedIds.length < requiredCount;

                          return GestureDetector(
                            onTap: canToggleOn
                                ? () {
                                    setLocalState(() {
                                      if (selected) {
                                        selectedIds.remove(worker.id);
                                      } else {
                                        selectedIds.add(worker.id);
                                      }
                                    });
                                  }
                                : null,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? TimeFactoryColors.electricCyan.withValues(
                                        alpha: 0.12,
                                      )
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? TimeFactoryColors.electricCyan
                                      : Colors.white24,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 42,
                                    height: 42,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: TimeFactoryColors.electricCyan
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: WorkerIconHelper.buildIcon(
                                      worker.era,
                                      worker.rarity,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          worker.displayName,
                                          style: TimeFactoryTextStyles.bodyMono
                                              .copyWith(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${worker.era.localizedName(context)} | ${worker.rarity.displayName} | ${NumberFormatter.formatPerSecond(worker.currentProduction)}${worker.isDeployed ? ' | CHAMBER' : ''}',
                                          style: TimeFactoryTextStyles.bodyMono
                                              .copyWith(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AppIcon(
                                    selected
                                        ? AppHugeIcons.check_circle
                                        : AppHugeIcons.add,
                                    color: selected
                                        ? TimeFactoryColors.acidGreen
                                        : (canToggleOn
                                              ? TimeFactoryColors.electricCyan
                                              : Colors.white30),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                foregroundColor: Colors.white70,
                              ),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedIds.length == requiredCount
                                  ? () =>
                                        Navigator.pop(ctx, selectedIds.toList())
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TimeFactoryColors.electricCyan,
                                foregroundColor: Colors.black,
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.confirmSelectedWorkers(
                                  selectedIds.length,
                                  requiredCount,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _slotName(String slotId) {
    for (final ExpeditionSlot slot in ExpeditionSlot.defaults) {
      if (slot.id == slotId) {
        return slot.name;
      }
    }
    return slotId;
  }

  String _formatDuration(BuildContext context, Duration duration) {
    final Duration safeDuration = duration.isNegative
        ? Duration.zero
        : duration;
    final int hours = safeDuration.inHours;
    final int minutes = safeDuration.inMinutes % 60;
    final int seconds = safeDuration.inSeconds % 60;

    if (hours > 0) {
      return AppLocalizations.of(context)!.durationHoursMinutes(hours, minutes);
    }
    if (minutes > 0) {
      return AppLocalizations.of(
        context,
      )!.durationMinutesSeconds(minutes, seconds);
    }
    return AppLocalizations.of(context)!.durationSeconds(seconds);
  }
}

class _RiskProfile {
  final String ceMultiplierLabel;
  final int timeShards;
  final int relicChancePercent;

  const _RiskProfile({
    required this.ceMultiplierLabel,
    required this.timeShards,
    required this.relicChancePercent,
  });
}

/// Isolates 1-second timer rebuilds so only the child tree is updated,
/// instead of rebuilding the entire ExpeditionsScreen widget tree.
class _TickingBuilder extends StatefulWidget {
  final Widget Function(DateTime now) builder;
  const _TickingBuilder({required this.builder});

  @override
  State<_TickingBuilder> createState() => _TickingBuilderState();
}

class _TickingBuilderState extends State<_TickingBuilder> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_now);
}

/// Adds a subtle pulsing glow effect around its child when [enabled].
class _PulsingGlow extends StatefulWidget {
  final bool enabled;
  final Color color;
  final Widget child;
  const _PulsingGlow({
    required this.enabled,
    required this.color,
    required this.child,
  });

  @override
  State<_PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<_PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && oldWidget.enabled) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.color.withValues(alpha: 0.15 + (t * 0.2)),
                blurRadius: 8 + (t * 8),
                spreadRadius: t * 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Progress bar with a sweeping shimmer highlight for active expeditions.
class _ShimmerProgressBar extends StatefulWidget {
  final double progress;
  final Color color;
  const _ShimmerProgressBar({required this.progress, required this.color});

  @override
  State<_ShimmerProgressBar> createState() => _ShimmerProgressBarState();
}

class _ShimmerProgressBarState extends State<_ShimmerProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (BuildContext context, Widget? child) {
        final double pos = _shimmer.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: ShaderMask(
            shaderCallback: (Rect bounds) => LinearGradient(
              colors: <Color>[
                Colors.white,
                Colors.white.withValues(alpha: 0.5),
                Colors.white,
              ],
              stops: <double>[
                (pos - 0.2).clamp(0.0, 1.0),
                pos.clamp(0.0, 1.0),
                (pos + 0.2).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            blendMode: BlendMode.modulate,
            child: LinearProgressIndicator(
              value: widget.progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: TimeFactoryColors.electricCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label.toUpperCase(),
          style: TimeFactoryTextStyles.label.copyWith(
            color: Colors.white70,
            letterSpacing: 1.6,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String label;

  const _EmptyBlock(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: TimeFactoryColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TimeFactoryColors.smokeGray.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: <Widget>[
          const AppIcon(
            AppHugeIcons.rocket_launch,
            size: 32,
            color: Colors.white24,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white38,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _OpsHudHeader — 3-line system telemetry header
// ---------------------------------------------------------------------------
class _OpsHudHeader extends StatefulWidget {
  final ThemeColors colors;
  final ThemeTypography typography;
  final int idleCount;
  final int activeCount;
  final int completedCount;

  const _OpsHudHeader({
    required this.colors,
    required this.typography,
    required this.idleCount,
    required this.activeCount,
    required this.completedCount,
  });

  @override
  State<_OpsHudHeader> createState() => _OpsHudHeaderState();
}

class _OpsHudHeaderState extends State<_OpsHudHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final t = widget.typography;
    final status = widget.activeCount > 0 ? 'ACTIVE' : 'STANDBY';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF050A10),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: c.primary.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(color: c.primary.withValues(alpha: 0.06), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line 1: System identity
            Row(
              children: [
                // Pulsing online indicator
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, _) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.primary.withValues(
                        alpha: 0.45 + 0.55 * _pulseCtrl.value,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.primary.withValues(
                            alpha: 0.30 * _pulseCtrl.value,
                          ),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'TEMPORAL OPERATIONS',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    color: c.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.6,
                  ),
                ),
                Text(
                  ' // MISSION CONTROL',
                  style: t.bodyMedium.copyWith(
                    fontSize: 9,
                    color: c.primary.withValues(alpha: 0.45),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  'OPS_03',
                  style: t.bodyMedium.copyWith(
                    fontSize: 8,
                    color: c.primary.withValues(alpha: 0.35),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Container(height: 1, color: c.primary.withValues(alpha: 0.10)),
            const SizedBox(height: 8),

            // Line 2: System status
            Row(
              children: [
                _hudLabel(t, c, 'SYS STATUS:'),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    color: widget.activeCount > 0
                        ? c.accent
                        : c.primary.withValues(alpha: 0.55),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                _hudLabel(t, c, 'ACTIVE MISSIONS:'),
                const SizedBox(width: 4),
                Text(
                  '${widget.activeCount}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    color: widget.activeCount > 0
                        ? c.accent
                        : c.primary.withValues(alpha: 0.55),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Container(height: 1, color: c.primary.withValues(alpha: 0.06)),
            const SizedBox(height: 8),

            // Line 3: Crew Status Matrix
            Row(
              children: [
                _hudLabel(t, c, 'CREW STATUS MATRIX'),
                const Spacer(),
                _statusCell(t, c, 'IDLE', widget.idleCount, c.primary),
                const SizedBox(width: 12),
                _statusCell(t, c, 'DEPLOYED', widget.activeCount, c.accent),
                const SizedBox(width: 12),
                _statusCell(
                  t,
                  c,
                  'READY',
                  widget.completedCount,
                  TimeFactoryColors.acidGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _hudLabel(ThemeTypography t, ThemeColors c, String text) {
    return Text(
      text,
      style: t.bodyMedium.copyWith(
        fontSize: 8,
        color: c.primary.withValues(alpha: 0.40),
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _statusCell(
    ThemeTypography t,
    ThemeColors c,
    String label,
    int value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value > 0 ? color : color.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: t.bodyMedium.copyWith(
            fontSize: 8,
            color: value > 0 ? color : color.withValues(alpha: 0.40),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
