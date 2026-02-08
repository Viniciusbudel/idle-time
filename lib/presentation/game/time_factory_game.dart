import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/game/components/particle_effects/ce_gain_particle.dart';
import 'package:time_factory/presentation/game/components/particle_effects/tap_effect.dart';
import 'package:time_factory/presentation/game/components/reactor_component.dart';
import 'package:time_factory/presentation/game/components/worker_avatar.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/production_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';

class TimeFactoryGame extends FlameGame {
  final WidgetRef ref;

  final Map<String, WorkerAvatar> _workerComponents = {};

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

    // Initial Spawn
    _syncWorkers(ref.read(gameStateProvider).activeWorkers);
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

  /// Process one production tick
  void _processProductionTick(double dt) {
    final gameState = ref.read(gameStateProvider);

    // Calculate production for this tick
    final productionPerSecond = ref.read(productionPerSecondProvider);

    if (productionPerSecond > 0) {
      // Accumulate fractional production
      _fractionalAccumulator += productionPerSecond * dt;

      // When we have at least 1 CE, add to game state
      if (_fractionalAccumulator >= 1.0) {
        final amountToAdd = BigInt.from(_fractionalAccumulator.floor());
        _fractionalAccumulator -= amountToAdd.toDouble();

        ref.read(gameStateProvider.notifier).addChronoEnergy(amountToAdd);

        // Spawn gain effect for significant amounts or occasionally
        if (amountToAdd > BigInt.from(10) || Random().nextDouble() < 0.1) {
          // We can spawn effects here if needed
        }
      }
    }

    // Update paradox level
    final paradoxRate = gameState.paradoxPerSecond;
    if (paradoxRate > 0) {
      ref.read(gameStateProvider.notifier).updateParadox(paradoxRate * dt);
    }

    // Check era unlocks periodically (not every tick for performance)
    if (Random().nextDouble() < 0.1) {
      ref.read(gameStateProvider.notifier).checkEraUnlocks();
    }
  }

  void syncWorkers(List<Worker> activeWorkers) {
    _syncWorkers(activeWorkers);
  }

  void _syncWorkers(List<Worker> activeWorkers) {
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
      if (!_workerComponents.containsKey(worker.id)) {
        // Random position
        final x = size.x * 0.1 + Random().nextDouble() * (size.x * 0.8);
        final y =
            size.y * 0.4 +
            Random().nextDouble() * (size.y * 0.4); // Bottom half mostly

        final component = WorkerAvatar(worker: worker)
          ..position = Vector2(x, y);

        add(component);
        _workerComponents[worker.id] = component;
      }
    }
  }

  void spawnTapEffect(Vector2 position) {
    add(TapEffect(position: position));
  }

  void spawnResourceGainEffect(Vector2 position, BigInt amount) {
    add(CEGainParticle(position: position, amount: amount));
  }
}
