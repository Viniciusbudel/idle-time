import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/core/utils/number_formatter.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/usecases/claim_expedition_rewards_usecase.dart';
import 'package:time_factory/domain/usecases/start_expedition_usecase.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';

class ExpeditionsScreen extends ConsumerStatefulWidget {
  const ExpeditionsScreen({super.key});

  @override
  ConsumerState<ExpeditionsScreen> createState() => _ExpeditionsScreenState();
}

enum _ExpeditionPanel { missions, active, completed }

class _ExpeditionsScreenState extends ConsumerState<ExpeditionsScreen> {
  Timer? _timer;
  final Map<String, ExpeditionRisk> _selectedRiskBySlotId =
      <String, ExpeditionRisk>{};
  final Map<String, List<String>> _selectedWorkerIdsBySlotId =
      <String, List<String>>{};
  _ExpeditionPanel _activePanel = _ExpeditionPanel.missions;
  String? _expandedSlotId;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameState gameState = ref.watch(gameStateProvider);
    final List<ExpeditionSlot> slots = ref.watch(expeditionSlotsProvider);
    final List<Expedition> expeditions = ref.watch(expeditionsProvider);
    final DateTime now = DateTime.now();

    final List<Expedition> activeExpeditions =
        expeditions.where((expedition) => !expedition.resolved).toList()
          ..sort((a, b) => a.endTime.compareTo(b.endTime));

    final List<Expedition> completedExpeditions =
        expeditions.where((expedition) => expedition.resolved).toList()
          ..sort((a, b) => b.endTime.compareTo(a.endTime));

    final List<Worker> availableWorkers = _availableWorkers(gameState);

    return Scaffold(
      backgroundColor: const Color(0xFF050A10),
      appBar: AppBar(
        backgroundColor: Colors.black,
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
            now,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPanelSwitcher(
            context: context,
            activeCount: activeExpeditions.length,
            completedCount: completedExpeditions.length,
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _buildPanelBody(
              key: ValueKey<_ExpeditionPanel>(_activePanel),
              context: context,
              gameState: gameState,
              slots: slots,
              availableWorkers: availableWorkers,
              activeExpeditions: activeExpeditions,
              completedExpeditions: completedExpeditions,
              now: now,
            ),
          ),
          const SizedBox(height: 90),
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
    required DateTime now,
  }) {
    switch (_activePanel) {
      case _ExpeditionPanel.missions:
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
                child: _buildSlotCard(context, availableWorkers, slot),
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
                  child: _buildActiveCard(gameState, expedition, now),
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
    DateTime now,
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
          colors: <Color>[Color(0xFF081A25), Color(0xFF11110B)],
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
                  nextCompletion.endTime.difference(now),
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

  Widget _buildSlotCard(
    BuildContext context,
    List<Worker> availableWorkers,
    ExpeditionSlot slot,
  ) {
    final ExpeditionRisk selectedRisk =
        _selectedRiskBySlotId[slot.id] ?? slot.defaultRisk;
    final bool canStart = availableWorkers.length >= slot.requiredWorkers;
    final bool isExpanded = _expandedSlotId == slot.id;
    final List<Worker> selectedWorkers = _selectedWorkersForSlot(
      slot.id,
      availableWorkers,
      slot.requiredWorkers,
    );
    final ExpeditionReward? previewReward = _estimateSlotRewardPreview(
      availableWorkers: availableWorkers,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TimeFactoryColors.electricCyan.withValues(alpha: 0.35),
        ),
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
              Expanded(
                child: Text(
                  slot.name,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: Colors.white,
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppIcon(
                    isExpanded
                        ? AppHugeIcons.keyboard_arrow_down
                        : AppHugeIcons.chevron_right,
                    size: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.successProbabilityLabel(successPercent),
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: _riskColor(selectedRisk),
                    fontSize: 9,
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
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: successChance,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                _riskColor(selectedRisk),
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
                  accentColor: _riskColor(selectedRisk),
                  onTap: openWorkerPicker,
                );
              }
              return _buildAddWorkerSocket(
                accentColor: _riskColor(selectedRisk),
                onTap: openWorkerPicker,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            canStart
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
              color: canStart ? Colors.white60 : Colors.redAccent,
              fontSize: 10,
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
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRiskBySlotId[slot.id] = risk;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? _riskColor(risk).withValues(alpha: 0.22)
                              : Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected ? _riskColor(risk) : Colors.white24,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.expeditionRiskBadge(
                            risk.name.toUpperCase(),
                            risk.ceMultiplier.toStringAsFixed(1),
                            risk.shardReward,
                            (risk.artifactDropChance * 100).round(),
                          ),
                          style: TimeFactoryTextStyles.bodyMono.copyWith(
                            fontSize: 9,
                            color: selected ? _riskColor(risk) : Colors.white60,
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
                                _riskColor(
                                  selectedRisk,
                                ).withValues(alpha: 0.95),
                                _riskColor(
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
                            ? _riskColor(selectedRisk)
                            : Colors.white24,
                      ),
                      boxShadow: canStart
                          ? <BoxShadow>[
                              BoxShadow(
                                color: _riskColor(
                                  selectedRisk,
                                ).withValues(alpha: 0.35),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : const <BoxShadow>[],
                    ),
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

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _riskColor(expedition.risk).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIcon(
                AppHugeIcons.access_time,
                size: 18,
                color: _riskColor(expedition.risk),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_slotName(expedition.slotId)} | ${expedition.risk.name.toUpperCase()}',
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
                    accentColor: _riskColor(expedition.risk),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                _riskColor(expedition.risk),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Progress: $progressPercent% | success chance ${(expedition.successProbability * 100).round()}%',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: _riskColor(expedition.risk),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.expeditionWorkersAssigned(
              expedition.workerIds.length,
              expedition.risk.ceMultiplier.toStringAsFixed(1),
              expedition.risk.shardReward,
              (expedition.risk.artifactDropChance * 100).round(),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: failed
              ? Colors.redAccent.withValues(alpha: 0.7)
              : TimeFactoryColors.acidGreen.withValues(alpha: 0.6),
        ),
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
          ElevatedButton(
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
        ],
      ),
    );
  }

  void _startExpedition(
    BuildContext context,
    ExpeditionSlot slot,
    ExpeditionRisk risk,
    List<String> workerIds,
  ) {
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
      _activePanel = _ExpeditionPanel.active;
      _expandedSlotId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.expeditionStarted(
            slot.name,
            risk.name.toUpperCase(),
            workerIds.length,
          ),
        ),
      ),
    );
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
      builder: (BuildContext dialogContext) => _ExpeditionRewardDialog(
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
        .where((Worker worker) => !worker.isDeployed)
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
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: accentColor.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: accentColor.withValues(alpha: 0.55)),
        ),
        child: Center(
          child: AppIcon(
            AppHugeIcons.add,
            size: 16,
            color: accentColor.withValues(alpha: 0.85),
          ),
        ),
      ),
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

  ExpeditionReward? _estimateSlotRewardPreview({
    required List<Worker> availableWorkers,
    required int requiredWorkers,
    required Duration duration,
    required ExpeditionRisk risk,
  }) {
    if (availableWorkers.length < requiredWorkers) {
      return null;
    }

    final List<Worker> selected = List<Worker>.from(availableWorkers)
      ..sort((a, b) => b.currentProduction.compareTo(a.currentProduction));

    BigInt totalWorkerPower = BigInt.zero;
    for (final Worker worker in selected.take(requiredWorkers)) {
      totalWorkerPower += worker.currentProduction;
    }

    final int durationSeconds = duration.inSeconds.clamp(1, 60 * 60 * 24);
    final double weighted =
        totalWorkerPower.toDouble() * durationSeconds * risk.ceMultiplier;

    return ExpeditionReward(
      chronoEnergy: BigInt.from(weighted.round()),
      timeShards: risk.shardReward,
      artifactDropChance: risk.artifactDropChance,
    );
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
                color: const Color(0xFF0A1520),
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
                                          '${worker.era.localizedName(context)} | ${worker.rarity.displayName} | ${NumberFormatter.formatPerSecond(worker.currentProduction)}',
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

  Color _riskColor(ExpeditionRisk risk) {
    switch (risk) {
      case ExpeditionRisk.safe:
        return TimeFactoryColors.electricCyan;
      case ExpeditionRisk.risky:
        return TimeFactoryColors.voltageYellow;
      case ExpeditionRisk.volatile:
        return TimeFactoryColors.hotMagenta;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TimeFactoryTextStyles.bodyMono.copyWith(
        color: Colors.white70,
        letterSpacing: 1.6,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String label;

  const _EmptyBlock(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: TimeFactoryTextStyles.bodyMono.copyWith(
          color: Colors.white54,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ExpeditionRewardDialog extends StatefulWidget {
  final String slotName;
  final ExpeditionRisk risk;
  final ExpeditionReward reward;

  const _ExpeditionRewardDialog({
    required this.slotName,
    required this.risk,
    required this.reward,
  });

  @override
  State<_ExpeditionRewardDialog> createState() =>
      _ExpeditionRewardDialogState();
}

class _ExpeditionRewardDialogState extends State<_ExpeditionRewardDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flameController;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentColor(widget.risk);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF10171F), Color(0xFF090D13)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent, width: 1.2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedBuilder(
              animation: _flameController,
              builder: (BuildContext context, Widget? child) {
                final double t = _flameController.value;
                final double pulse = 0.9 + (t * 0.3);
                return SizedBox(
                  height: 84,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Transform.scale(
                        scale: 1.2 + (t * 0.35),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: pulse,
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: TimeFactoryColors.voltageYellow,
                          size: 42,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: accent.withValues(alpha: 0.75),
                          size: 22,
                        ),
                      ),
                      Positioned(
                        right: 12,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: TimeFactoryColors.hotMagenta.withValues(
                            alpha: 0.75,
                          ),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.expeditionReward,
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                color: accent,
                fontSize: 11,
                letterSpacing: 1.8,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.slotName.toUpperCase(),
              style: TimeFactoryTextStyles.header.copyWith(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: <Widget>[
                  _rewardRow(
                    label: AppLocalizations.of(context)!.chronoEnergyUpper,
                    value:
                        '+${NumberFormatter.formatCE(widget.reward.chronoEnergy)}',
                    color: TimeFactoryColors.electricCyan,
                  ),
                  const SizedBox(height: 8),
                  _rewardRow(
                    label: AppLocalizations.of(context)!.timeShardsUpper,
                    value: '+${widget.reward.timeShards}',
                    color: TimeFactoryColors.voltageYellow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.awesome),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              color: Colors.white70,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Text(
          value,
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _accentColor(ExpeditionRisk risk) {
    switch (risk) {
      case ExpeditionRisk.safe:
        return TimeFactoryColors.electricCyan;
      case ExpeditionRisk.risky:
        return TimeFactoryColors.voltageYellow;
      case ExpeditionRisk.volatile:
        return TimeFactoryColors.hotMagenta;
    }
  }
}
