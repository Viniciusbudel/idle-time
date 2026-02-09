import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/game/components/particle_effects/ce_gain_particle.dart';
import 'package:time_factory/presentation/game/components/particle_effects/tap_effect.dart';
import 'package:time_factory/presentation/game/components/reactor_component.dart';
import 'package:time_factory/presentation/game/components/worker_avatar.dart';
import 'package:time_factory/presentation/game/components/hiring_effect_component.dart';
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
      add(await ReactorComponent.create(300)); // Size 300x300
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

    // Check era unlocks periodically (visual check or tooltip updates?)
    // Logic is handled in provider, so we don't need to trigger checkEraUnlocks here
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
}
