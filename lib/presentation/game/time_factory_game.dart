import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      debugPrint('CRITICAL: Lottie Reactor failed to load!');
      debugPrint('Error: $e');
      debugPrint('Stack: $stack');
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
      // Cap rate to avoid freezing if level is huge, max 60 clicks/sec logic frame
      // Actual logic: 1 click per (1/level) seconds
      final interval = 1.0 / automationLevel;

      // Limit processing per frame to avoid infinite loops on lag
      int clicksProcessed = 0;
      while (_autoClickAccumulator >= interval && clicksProcessed < 10) {
        _autoClickAccumulator -= interval;
        _performAutoClick();
        clicksProcessed++;
      }

      // If we still have accumulator left (lag), just add bulk?
      // For now, just discard excess to prevent catch-up lag spiral
      if (_autoClickAccumulator > 1.0) _autoClickAccumulator = 0;
    }

    _processAnomalySpawner(warpedDt);
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

  void _performAutoClick() {
    // OLD: final strength = ref.read(tapStrengthProvider);
    // OLD: ref.read(gameStateProvider.notifier).addChronoEnergy(strength);

    // NEW: Use manualClick calculation so Piston buffs automation too
    ref.read(gameStateProvider.notifier).manualClick();

    // Visuals: Throttle to avoid clutter.
    // Always show if rate is low (< 5/sec), otherwise random chance
    // automationLevel is available here but let's just use random for simplicity
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
    _syncWorkers(activeWorkers, animate: animate);
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

    final component = WorkerAvatar(worker: worker)..position = position;
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
    // Remove old reactor
    children.whereType<ReactorComponent>().forEach((c) => c.removeFromParent());

    // Add new reactor
    try {
      add(await ReactorComponent.create(300, eraId: eraId));
    } catch (e) {
      debugPrint('Failed to load new era reactor: $e');
      // Fallback to default if needed, or retry logic
    }
  }
}
