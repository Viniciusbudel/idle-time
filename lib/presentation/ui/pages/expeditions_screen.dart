import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/core/utils/expedition_utils.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
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

    return Scaffold(
      backgroundColor: TimeFactoryColors.background,
      appBar: AppBar(
        backgroundColor: TimeFactoryColors.background,
        title: Text(
          AppLocalizations.of(context)!.missionControl,
          style: TimeFactoryTextStyles.header.copyWith(
            color: TimeFactoryColors.electricCyan,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          _buildMissionControlHeader(
            context,
            gameState,
            availableWorkers,
            activeExpeditions,
            completedExpeditions,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPanelSwitcher(
            context: context,
            activeCount: activeExpeditions.length,
            completedCount: completedExpeditions.length,
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
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

  Widget _buildPanelSwitcher({
    required BuildContext context,
    required int activeCount,
    required int completedCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: <Widget>[
          _buildPanelButton(
            _ExpeditionPanel.missions,
            AppLocalizations.of(context)!.missions,
            null,
          ),
          _buildPanelButton(
            _ExpeditionPanel.active,
            AppLocalizations.of(context)!.active,
            activeCount,
          ),
          _buildPanelButton(
            _ExpeditionPanel.completed,
            AppLocalizations.of(context)!.completed,
            completedCount,
          ),
        ],
      ),
    );
  }

  Widget _buildPanelButton(_ExpeditionPanel panel, String label, int? badge) {
    final bool selected = _activePanel == panel;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activePanel = panel;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? TimeFactoryColors.electricCyan.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? TimeFactoryColors.electricCyan
                      : Colors.white60,
                  letterSpacing: 1,
                ),
              ),
              if (badge != null) ...<Widget>[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge.toString(),
                    style: TimeFactoryTextStyles.bodyMono.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? TimeFactoryColors.electricCyan
                          : Colors.white70,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionControlHeader(
    BuildContext context,
    GameState gameState,
    List<Worker> availableWorkers,
    List<Expedition> activeExpeditions,
    List<Expedition> completedExpeditions,
  ) {
    BigInt queuedCe = BigInt.zero;
    int queuedShards = 0;
    for (final Expedition expedition in completedExpeditions) {
      final ExpeditionReward reward =
          expedition.resolvedReward ?? ExpeditionReward.zero;
      queuedCe += reward.chronoEnergy;
      queuedShards += reward.timeShards;
    }

    final Expedition? nextCompletion = activeExpeditions.isNotEmpty
        ? activeExpeditions.first
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            TimeFactoryColors.surface,
            TimeFactoryColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TimeFactoryColors.electricCyan.withValues(alpha: 0.35),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TimeFactoryColors.electricCyan.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AppIcon(
                AppHugeIcons.rocket_launch,
                color: TimeFactoryColors.electricCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.expeditionStatus,
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  fontSize: 11,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _infoChip(
                context: context,
                icon: AppHugeIcons.groups,
                label: AppLocalizations.of(context)!.idleTitle,
                value: availableWorkers.length.toString(),
                color: TimeFactoryColors.electricCyan,
              ),
              _infoChip(
                context: context,
                icon: AppHugeIcons.access_time,
                label: AppLocalizations.of(context)!.activeTitle,
                value: activeExpeditions.length.toString(),
                color: TimeFactoryColors.voltageYellow,
              ),
              _infoChip(
                context: context,
                icon: AppHugeIcons.check_circle,
                label: AppLocalizations.of(context)!.readyTitle,
                value: completedExpeditions.length.toString(),
                color: TimeFactoryColors.acidGreen,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(
              context,
            )!.queuedRewards(NumberFormatter.formatCE(queuedCe), queuedShards),
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          if (nextCompletion != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.nextCompletion(
                _slotName(nextCompletion.slotId),
                _formatDuration(
                  context,
                  nextCompletion.endTime.difference(DateTime.now()),
                ),
              ),
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 10,
                color: TimeFactoryColors.voltageYellow,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip({
    required BuildContext context,
    required AppIconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppIcon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context)!.labelValue(label, value),
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

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
    final Color cardTextColor =
        Color.lerp(eraTheme.textColor, Colors.white, 0.55) ?? Colors.white;
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
    );
    final double successChance =
        StartExpeditionUseCase.calculateSuccessProbability(
          risk: selectedRisk,
          assignedWorkers: selectedWorkers,
          requiredWorkers: slot.requiredWorkers,
        );
    final int successPercent = (successChance * 100).round();

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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            eraTheme.surfaceColor.withValues(alpha: 0.28),
            TimeFactoryColors.surface,
            TimeFactoryColors.background.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: combinedAccent.withValues(alpha: 0.45)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: eraAccent.withValues(alpha: 0.12), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIcon(AppHugeIcons.rocket_launch, color: eraAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  slot.name,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: cardTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _formatDuration(context, slot.duration),
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _expandedSlotId = isExpanded ? null : slot.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppIcon(
                    isExpanded
                        ? AppHugeIcons.keyboard_arrow_down
                        : AppHugeIcons.chevron_right,
                    size: 16,
                    color: eraAccent.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            slot.headline,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: cardTextColor.withValues(alpha: 0.78),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _buildMissionIdentityChip(
                label: slot.eraId.replaceAll('_', ' ').toUpperCase(),
                color: eraAccent,
              ),
              _buildMissionIdentityChip(
                label: slot.layoutPreset.replaceAll('_', ' ').toUpperCase(),
                color: eraTheme.secondaryColor,
              ),
              if (slotHasActiveRun)
                _buildMissionIdentityChip(
                  label: 'ACTIVE RUN',
                  color: TimeFactoryColors.voltageYellow,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.successProbabilityLabel(successPercent),
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: expeditionRiskColor(selectedRisk),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  previewReward == null
                      ? AppLocalizations.of(context)!.resourceYieldUnavailable
                      : AppLocalizations.of(context)!.resourceYieldLabel(
                          NumberFormatter.formatCE(previewReward.chronoEnergy),
                        ),
                  textAlign: TextAlign.right,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: successChance,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                expeditionRiskColor(selectedRisk),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 8),
          Text(
            'Idle: ${availableWorkers.length} | Required: ${slot.requiredWorkers}',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: cardTextColor.withValues(alpha: 0.74),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            slotHasActiveRun
                ? 'This expedition type already has an active run.'
                : hasRequiredCrew
                ? AppLocalizations.of(context)!.expeditionWorkersReady(
                    slot.requiredWorkers,
                    availableWorkers.length,
                  )
                : AppLocalizations.of(
                    context,
                  )!.expeditionWorkersReadyInsufficient(
                    slot.requiredWorkers,
                    availableWorkers.length,
                  ),
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: slotHasActiveRun
                  ? TimeFactoryColors.voltageYellow
                  : hasRequiredCrew
                  ? Colors.white60
                  : Colors.redAccent,
              fontSize: 10,
              fontWeight: slotHasActiveRun
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 2),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
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
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? expeditionRiskColor(
                                  risk,
                                ).withValues(alpha: 0.22)
                              : Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? expeditionRiskColor(risk)
                                : Colors.white24,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.expeditionRiskBadge(
                            _riskLabel(risk),
                            profile.ceMultiplierLabel,
                            profile.timeShards,
                            profile.relicChancePercent,
                          ),
                          style: TimeFactoryTextStyles.bodyMono.copyWith(
                            fontSize: 9,
                            color: selected
                                ? expeditionRiskColor(risk)
                                : Colors.white60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.tapWorkerIconsHint,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: canConfigureSlot && availableWorkers.isNotEmpty
                          ? autoAssembleCrew
                          : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: combinedAccent.withValues(alpha: 0.55),
                        ),
                        foregroundColor: combinedAccent,
                      ),
                      icon: AppIcon(
                        AppHugeIcons.groups,
                        size: 14,
                        color: combinedAccent,
                      ),
                      label: const Text('Auto Assemble Crew'),
                    ),
                    if (shouldShowQuickHire)
                      ElevatedButton.icon(
                        onPressed: quickHireCrew,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: expeditionRiskColor(
                            selectedRisk,
                          ).withValues(alpha: 0.88),
                          foregroundColor: Colors.black,
                        ),
                        icon: const AppIcon(
                          AppHugeIcons.person_add,
                          size: 14,
                          color: Colors.black,
                        ),
                        label: const Text('Hire Now'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: canStart
                      ? () {
                          final List<String> selectedIds = selectedWorkers
                              .map((Worker worker) => worker.id)
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
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: canStart
                          ? LinearGradient(
                              colors: <Color>[
                                expeditionRiskColor(
                                  selectedRisk,
                                ).withValues(alpha: 0.95),
                                expeditionRiskColor(
                                  selectedRisk,
                                ).withValues(alpha: 0.55),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: canStart ? null : Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: canStart
                            ? expeditionRiskColor(selectedRisk)
                            : Colors.white24,
                      ),
                      boxShadow: canStart
                          ? <BoxShadow>[
                              BoxShadow(
                                color: expeditionRiskColor(
                                  selectedRisk,
                                ).withValues(alpha: 0.35),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : const <BoxShadow>[],
                    ),
                    child: _PulsingGlow(
                      enabled: canStart,
                      color: expeditionRiskColor(selectedRisk),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AppIcon(
                            AppHugeIcons.rocket_launch,
                            color: canStart ? Colors.black : Colors.white54,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.initiateExpedition,
                            style: TimeFactoryTextStyles.bodyMono.copyWith(
                              color: canStart ? Colors.black : Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    final _RiskProfile activeProfile = _riskProfilePreview(
      gameState: gameState,
      workers: assignedWorkers,
      duration: total,
      risk: expedition.risk,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            TimeFactoryColors.surface,
            TimeFactoryColors.background.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expeditionRiskColor(expedition.risk).withValues(alpha: 0.6),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: expeditionRiskColor(expedition.risk).withValues(alpha: 0.1),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIcon(
                AppHugeIcons.access_time,
                size: 18,
                color: expeditionRiskColor(expedition.risk),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_slotName(expedition.slotId)} | ${_riskLabel(expedition.risk)}',
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                _formatDuration(context, remaining),
                style: TimeFactoryTextStyles.bodyMono.copyWith(
                  color: TimeFactoryColors.voltageYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: assignedWorkers
                .map(
                  (Worker worker) => _buildWorkerSocket(
                    worker: worker,
                    accentColor: expeditionRiskColor(expedition.risk),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          _ShimmerProgressBar(
            progress: progress,
            color: expeditionRiskColor(expedition.risk),
          ),
          const SizedBox(height: 6),
          Text(
            'Progress: $progressPercent% | success chance ${(expedition.successProbability * 100).round()}%',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: expeditionRiskColor(expedition.risk),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.expeditionWorkersAssigned(
              expedition.workerIds.length,
              activeProfile.ceMultiplierLabel,
              activeProfile.timeShards,
              activeProfile.relicChancePercent,
            ),
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, Expedition expedition) {
    final ExpeditionReward reward =
        expedition.resolvedReward ?? ExpeditionReward.zero;
    final bool failed = expedition.wasSuccessful == false;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            TimeFactoryColors.surface,
            TimeFactoryColors.background.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: failed
              ? Colors.redAccent.withValues(alpha: 0.7)
              : TimeFactoryColors.acidGreen.withValues(alpha: 0.6),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (failed ? Colors.redAccent : TimeFactoryColors.acidGreen)
                .withValues(alpha: 0.08),
            blurRadius: 12,
          ),
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
    );
  }

  _RiskProfile _riskProfilePreview({
    required GameState gameState,
    required List<Worker> workers,
    required Duration duration,
    required ExpeditionRisk risk,
  }) {
    final ExpeditionReward reward = _resolveExpeditionsUseCase
        .estimateRewardPreview(
          gameState,
          workers: workers,
          duration: duration,
          risk: risk,
          succeeded: true,
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
