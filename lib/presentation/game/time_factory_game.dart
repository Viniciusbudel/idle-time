import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/utils/app_log.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/presentation/state/artifact_drop_event_provider.dart';
import 'package:time_factory/presentation/game/components/particle_effects/ce_gain_particle.dart';
import 'package:time_factory/presentation/game/components/particle_effects/tap_effect.dart';
import 'package:time_factory/presentation/game/components/reactor_component.dart';
import 'package:time_factory/presentation/game/components/worker_avatar.dart';
import 'package:time_factory/presentation/game/components/hiring_effect_component.dart';
import 'package:time_factory/presentation/game/components/temporal_anomaly_component.dart';
import 'package:time_factory/domain/usecases/roll_artifact_drop_usecase.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/production_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';

class TimeFactoryGame extends FlameGame {
  final WidgetRef ref;

  final Map<String, WorkerAvatar> _workerComponents = {};
  final Set<String> _pendingWorkerIds = {};
  final List<VoidCallback> _pendingGameMutations = [];
  bool _lowPerformanceMode = false;
  bool _isApplyingMutations = false;
  int _reactorSwapRequestId = 0;

  // Production tick system
  double _accumulator = 0.0;
  double _fractionalAccumulator = 0.0;
  double _autoClickAccumulator = 0.0;
  static const double _tickRate = 1.0 / 30.0; // 30 ticks per second

  // Anomaly Drop System
  double _anomalySpawnTimer = 0.0;
  double _anomalyNextSpawnTarget = 120.0;

  TimeFactoryGame(this.ref);

  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add atmospheric effects
    // add(CyberpunkRain());

    // Add Reactor (Centered)
    try {
      final currentEraId = ref.read(gameStateProvider).currentEraId;
      add(
        await ReactorComponent.create(300, eraId: currentEraId),
      ); // Size 300x300
    } catch (e, stack) {
      AppLog.debug('Reactor failed to load', error: e, stackTrace: stack);
      //add(await FallbackReactor.create(300));
    }

    // Initial Spawn (No animation)
    _syncWorkers(ref.read(gameStateProvider).activeWorkers, animate: false);
  }

  void handleReactorTap() {
    // OLD: final strength = ref.read(tapStrengthProvider);
    // OLD: ref.read(gameStateProvider.notifier).addChronoEnergy(strength);

    // NEW: Centralized logic with Tech multipliers
    final strength = ref.read(gameStateProvider.notifier).manualClick();

    // Visual Effects
    spawnTapEffect(size / 2);
    spawnResourceGainEffect(size / 2, strength);
  }

  @override
  void update(double dt) {
    // Apply Time Warp
    final timeWarp = ref.read(timeWarpMultiplierProvider);
    final warpedDt = dt * timeWarp;

    super.update(warpedDt);
    _flushQueuedMutations();

    // Fixed timestep production tick
    _accumulator += warpedDt;

    while (_accumulator >= _tickRate) {
      _accumulator -= _tickRate;
      _processProductionTick(_tickRate);
    }

    // Auto-Clicker Logic
    final automationLevel = ref.read(automationLevelProvider);
    if (automationLevel > 0) {
      _autoClickAccumulator += warpedDt;
      // Visual-only auto-click feedback. Economy production is handled in
      // GameStateNotifier to avoid duplicate CE writes and state churn.
      final interval = 1.0 / automationLevel;

      if (_autoClickAccumulator >= interval) {
        final clicks = (_autoClickAccumulator / interval).floor();
        _autoClickAccumulator -= clicks * interval;

        // Clamp burst visuals so high automation does not overwhelm frame time.
        final visualBursts = clicks.clamp(1, 3);
        for (var i = 0; i < visualBursts; i++) {
          _performAutoClickVisual();
        }
      }

      // Prevent long catch-up spirals after frame drops.
      if (_autoClickAccumulator > 1.0) _autoClickAccumulator = 0;
    }

    _processAnomalySpawner(warpedDt);
  }

  @override
  void updateTree(double dt) {
    processLifecycleEvents();
    if (parent != null) {
      update(dt);
    }

    final snapshot = children.toList(growable: false);
    for (final component in snapshot) {
      try {
        component.updateTree(dt);
      } on ConcurrentModificationError catch (error, stackTrace) {
        AppLog.debug(
          'Concurrent modification in ${component.runtimeType}; '
          'children=${component.children.length}',
          error: error,
          stackTrace: stackTrace,
        );
        final childSnapshot = component.children.toList(growable: false);
        for (final child in childSnapshot) {
          AppLog.debug(
            '  child=${child.runtimeType} '
            'mounted=${child.isMounted} removing=${child.isRemoving}',
          );
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
  }

  void _enqueueGameMutation(VoidCallback mutation) {
    _pendingGameMutations.add(mutation);
  }

  void _flushQueuedMutations() {
    if (_isApplyingMutations || _pendingGameMutations.isEmpty) return;

    _isApplyingMutations = true;
    try {
      while (_pendingGameMutations.isNotEmpty) {
        final mutations = List<VoidCallback>.from(_pendingGameMutations);
        _pendingGameMutations.clear();
        for (final mutation in mutations) {
          mutation();
        }
      }
    } finally {
      _isApplyingMutations = false;
    }
  }

  void _processAnomalySpawner(double dt) {
    // Check if an anomaly already exists
    if (children.whereType<TemporalAnomalyComponent>().isNotEmpty) {
      return;
    }

    _anomalySpawnTimer += dt;
    final paradoxLevel = ref.read(gameStateProvider).paradoxLevel;

    // Adjust target based on paradox (if high paradox, spawn faster)
    double target = _anomalyNextSpawnTarget;
    if (paradoxLevel > 0.8) {
      target /= 2.0; // Halve the interval
    }

    if (_anomalySpawnTimer >= target) {
      _spawnAnomaly(paradoxLevel);
      _anomalySpawnTimer = 0.0;
      // Next spawn between 120s and 300s (2 to 5 mins) real-time equivalent
      _anomalyNextSpawnTarget = 120.0 + Random().nextDouble() * 180.0;
    }
  }

  void _spawnAnomaly(double paradoxLevel) {
    // Random position avoiding edges
    final x = size.x * 0.2 + Random().nextDouble() * (size.x * 0.6);
    final y = size.y * 0.2 + Random().nextDouble() * (size.y * 0.6);

    final anomaly = TemporalAnomalyComponent(
      position: Vector2(x, y),
      onTapped: () => _handleAnomalyTap(paradoxLevel),
    );

    add(anomaly);
  }

  void _handleAnomalyTap(double paradoxLevel) {
    final useCase = RollArtifactDropUseCase();
    final rarity = useCase.execute(paradoxLevel);
    // Use current era for generation (legendary/epic might get a match bonus)
    final currentEra = ref.read(gameStateProvider).currentEraId;
    // We need the WorkerEra enum instance, or just use the first era if not found
    final currentWorkerEra = WorkerEra.values.firstWhere(
      (e) => e.id == currentEra,
      orElse: () => WorkerEra.victorian,
    );

    final artifact = WorkerArtifact.generate(rarity, currentWorkerEra);

    // Attempt to add to inventory
    final added = ref
        .read(gameStateProvider.notifier)
        .addArtifactToInventory(artifact);

    if (added) {
      ref.read(artifactDropEventProvider.notifier).notifyDrop(artifact);
      spawnResourceGainEffect(size / 2, BigInt.zero); // Visual feedback
    }
  }

  void _performAutoClickVisual() {
    // Visuals only (no resource writes).
    if (Random().nextDouble() < 0.3) {
      // Random position near center
      final center = size / 2;
      final offset = Vector2(
        (Random().nextDouble() - 0.5) * 100,
        (Random().nextDouble() - 0.5) * 100,
      );
      spawnTapEffect(center + offset);
    }
  }

  /// Process one production tick (Visuals only)
  void _processProductionTick(double dt) {
    // Note: Actual CE addition is now handled globally in GameStateNotifier
    // We only use this for visual feedback if needed (e.g. particles)

    final productionPerSecond = ref.read(productionPerSecondProvider);

    if (productionPerSecond > 0) {
      // Accumulate for visual spawn rate?
      _fractionalAccumulator += productionPerSecond * dt;

      // When we "visually" produce enough, maybe spawn a particle?
      if (_fractionalAccumulator >= 1.0) {
        final amountVisual = BigInt.from(_fractionalAccumulator.floor());
        _fractionalAccumulator -= amountVisual.toDouble();

        // Spawn gain effect for significant amounts or occasionally
        if (amountVisual > BigInt.from(10) || Random().nextDouble() < 0.1) {
          // We can spawn effects here if needed
          // spawnResourceGainEffect(size / 2, amountVisual);
        }
      }
    }

    // Era advancement is explicitly player-driven via the Tech screen.
  }

  void syncWorkers(List<Worker> activeWorkers, {bool animate = false}) {
    final workersSnapshot = List<Worker>.from(activeWorkers);
    _enqueueGameMutation(() {
      if (!isMounted) return;
      _syncWorkers(workersSnapshot, animate: animate);
    });
  }

  void setLowPerformanceMode(bool enabled) {
    if (_lowPerformanceMode == enabled) return;
    _lowPerformanceMode = enabled;

    _enqueueGameMutation(() {
      if (!isMounted) return;

      for (final component in _workerComponents.values.toList(
        growable: false,
      )) {
        component.removeFromParent();
      }
      _workerComponents.clear();
      _pendingWorkerIds.clear();

      final activeWorkers = ref
          .read(gameStateProvider)
          .workers
          .values
          .where((worker) => worker.isDeployed)
          .toList();
      _syncWorkers(activeWorkers, animate: false);
    });
  }

  void _syncWorkers(List<Worker> activeWorkers, {bool animate = false}) {
    final activeIds = activeWorkers.map((w) => w.id).toSet();

    // Remove workers no longer active
    _workerComponents.removeWhere((id, component) {
      if (!activeIds.contains(id)) {
        component.removeFromParent();
        return true;
      }
      return false;
    });

    // Add new workers
    for (final worker in activeWorkers) {
      // Skip if already exists or is currently animating
      if (_workerComponents.containsKey(worker.id) ||
          _pendingWorkerIds.contains(worker.id)) {
        continue;
      }

      // Random position
      final x = size.x * 0.1 + Random().nextDouble() * (size.x * 0.8);
      final y =
          size.y * 0.4 +
          Random().nextDouble() * (size.y * 0.4); // Bottom half mostly
      final position = Vector2(x, y);

      if (animate) {
        _pendingWorkerIds.add(worker.id);
        add(
          HiringEffectComponent(
            worker: worker,
            position: position,
            onSpawnWorker: () {
              _pendingWorkerIds.remove(worker.id);
              _addWorkerAvatar(worker, position);
            },
          ),
        );
      } else {
        _addWorkerAvatar(worker, position);
      }
    }
  }

  void _addWorkerAvatar(Worker worker, Vector2 position) {
    if (_workerComponents.containsKey(worker.id)) return; // Safety check

    final reducedEffects = _lowPerformanceMode || _workerComponents.length >= 8;
    final component = WorkerAvatar(
      worker: worker,
      lowPerformanceMode: reducedEffects,
    )..position = position;
    add(component);
    _workerComponents[worker.id] = component;
  }

  void spawnTapEffect(Vector2 position) {
    add(TapEffect(position: position));
  }

  void spawnResourceGainEffect(Vector2 position, BigInt amount) {
    add(CEGainParticle(position: position, amount: amount));
  }

  /// Change the reactor visual based on era
  Future<void> updateEra(String eraId) async {
    final requestId = ++_reactorSwapRequestId;
    _enqueueGameMutation(() {
      if (!isMounted || requestId != _reactorSwapRequestId) return;
      final reactors = children.whereType<ReactorComponent>().toList(
        growable: false,
      );
      for (final reactor in reactors) {
        reactor.removeFromParent();
      }
    });

    // Add new reactor
    try {
      final reactor = await ReactorComponent.create(300, eraId: eraId);
      _enqueueGameMutation(() {
        if (!isMounted || requestId != _reactorSwapRequestId) return;
        add(reactor);
      });
    } catch (e) {
      AppLog.debug('Failed to load new era reactor', error: e);
      // Fallback to default if needed, or retry logic
    }
  }
}
